#!/usr/bin/env python3
"""
Integration tests for tmux-forwarder and tmux-receiver

Starts the receiver as a subprocess, sends payloads over TCP, and asserts the
ACK/NAK response added in the response-byte protocol extension.
"""

import os
import socket
import struct
import subprocess
import sys
import tempfile
import time
import unittest
import zlib

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TMUX_DIR = os.path.dirname(SCRIPT_DIR)
sys.path.insert(0, TMUX_DIR)

from protocol import DtTmfConfig, DtTmfResponse

RECEIVER = os.path.join(TMUX_DIR, "tmux-receiver")
FORWARDER = os.path.join(TMUX_DIR, "tmux-forwarder")

cfg = DtTmfConfig()

TEST_PORT = None

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------


def _pick_free_port():
    """Bind-and-release to get an OS-assigned ephemeral port"""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("localhost", 0))
        return s.getsockname()[1]


def pack_valid(payload):
    """Build a well-formed protocol message"""
    crc = zlib.crc32(payload) & 0xFFFFFFFF
    header = struct.pack(cfg.STRF, cfg.MAGIC, cfg.VERS, len(payload), crc)
    return header + payload


def pack_header(payload, *, magic=cfg.MAGIC, version=cfg.VERS, length=None, crc=None):
    """Build a message with arbitrary header field overrides"""
    if length is None:
        length = len(payload)
    if crc is None:
        crc = zlib.crc32(payload) & 0xFFFFFFFF
    header = struct.pack(cfg.STRF, magic, version, length, crc)
    return header + payload


def send_raw(data, timeout=5):
    """Send raw bytes to the receiver and return the response byte"""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        sock.connect(("localhost", TEST_PORT))
        sock.sendall(data)
        sock.shutdown(socket.SHUT_WR)
        resp = sock.recv(1)
        return resp[0] if resp else None


def wait_for_port(port, timeout=5):
    """Block until a server is accepting connections on port"""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(1)
                s.connect(("localhost", port))
                return True
        except (ConnectionRefusedError, OSError):
            time.sleep(0.1)
    return False


def _test_env(clipboard="true"):
    """Build an env dict for test subprocesses with default clipboard of /usr/bin/true"""
    env = os.environ.copy()
    env["DEVTOOLS_TMUX_PORT"] = str(TEST_PORT)
    env["DEVTOOLS_TMUX_CLIPBOARD"] = clipboard
    env.pop("TMUX", None)
    return env


def start_receiver(env=None):
    """Start tmux-receiver on TEST_PORT and wait till it's listening"""
    if env is None:
        env = _test_env()
    proc = subprocess.Popen(
        [sys.executable, RECEIVER],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
    )
    if not wait_for_port(TEST_PORT):
        proc.kill()
        raise RuntimeError("Receiver did not start within timeout")
    return proc


def stop_receiver(proc):
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
    stdout = proc.stdout.read().decode(errors="replace")
    stderr = proc.stderr.read().decode(errors="replace")
    proc.stdout.close()
    proc.stderr.close()
    return stdout, stderr


# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------


class TestProtocolResponses(unittest.TestCase):
    """Verify the receiver returns the correct response byte for each case"""

    @classmethod
    def setUpClass(cls):
        cls.receiver = start_receiver()

    @classmethod
    def tearDownClass(cls):
        stdout, stderr = stop_receiver(cls.receiver)
        # Dump receiver output for debugging
        if stderr.strip():
            print(f"\nReceiver stderr: \n{stderr.strip()}", file=sys.stderr)

    def test_valid_payload(self):
        resp = send_raw(pack_valid(b"hello clipboard"))
        self.assertEqual(resp, DtTmfResponse.ACCEPTED)

    def test_bad_magic(self):
        resp = send_raw(pack_header(b"test", magic=b"NOPE"))
        self.assertEqual(resp, DtTmfResponse.REJECTED)

    def test_bad_version(self):
        resp = send_raw(pack_header(b"test", version=99))
        self.assertEqual(resp, DtTmfResponse.REJECTED)

    def test_crc_mismatch(self):
        resp = send_raw(pack_header(b"test", crc=0xDEADBEEF))
        self.assertEqual(resp, DtTmfResponse.REJECTED)

    def test_truncated_header(self):
        resp = send_raw(b"TMX")
        self.assertEqual(resp, DtTmfResponse.REJECTED)

    def test_truncated_payload(self):
        payload = b"some payload here"
        msg = pack_valid(payload)
        # Send header intact but chop the payload short
        truncated = msg[: cfg.hsize + 5]
        resp = send_raw(truncated)
        self.assertEqual(resp, DtTmfResponse.REJECTED)

    def test_oversized_length(self):
        resp = send_raw(pack_header(b"small", length=cfg.PMAX + 1))
        self.assertEqual(resp, DtTmfResponse.REJECTED)


class TestClipboardFailure(unittest.TestCase):
    """Verify the receiver returns CLIPERR when the clipboard command fails"""

    def test_clipboard_command_fails(self):
        receiver = start_receiver(env=_test_env(clipboard="false"))
        try:
            resp = send_raw(pack_valid(b"should fail clipboard"))
            self.assertEqual(resp, DtTmfResponse.CLIPERR)
        finally:
            stdout, stderr = stop_receiver(receiver)
            if stderr.strip():
                print(f"\nReceiver stderr:\n{stderr.strip()}", file=sys.stderr)


class TestForwarderEndToEnd(unittest.TestCase):
    """Send a payload through the forwarder script and verify it arrives"""

    @classmethod
    def setUpClass(cls):
        cls.receiver = start_receiver()

    @classmethod
    def tearDownClass(cls):
        stop_receiver(cls.receiver)

    def _forwarder_env(self):
        return _test_env()

    def test_forwarder_exits_zero(self):
        result = subprocess.run(
            [sys.executable, FORWARDER],
            input=b"forwarder e2e test",
            capture_output=True,
            timeout=5,
            env=self._forwarder_env(),
        )
        self.assertEqual(result.returncode, 0)

    def test_forwarder_rejects_oversized(self):
        """Forwarder must refuse to send payloads exceeding max_payload"""
        oversized = b"x" * (cfg.PMAX + 1)
        result = subprocess.run(
            [sys.executable, FORWARDER],
            input=oversized,
            capture_output=True,
            timeout=5,
            env=self._forwarder_env(),
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn(b"too large", result.stderr)

    def test_max_payload_end_to_end(self):
        """A payload at exactly max_payload bytes survives the full pipeline"""
        payload = os.urandom(cfg.PMAX)
        result = subprocess.run(
            [sys.executable, FORWARDER],
            input=payload,
            capture_output=True,
            timeout=10,
            env=self._forwarder_env(),
        )
        self.assertEqual(result.returncode, 0)


class TestForwarderPayload(unittest.TestCase):
    """Verify the exact payload bytes reach the clipboard command"""

    def test_forwarder_payload_arrives(self):
        with tempfile.NamedTemporaryFile(delete=False, suffix=".clip") as tmp:
            clip_file = tmp.name

        try:
            receiver = start_receiver(env=_test_env(clipboard=f"tee {clip_file}"))
            try:
                result = subprocess.run(
                    [sys.executable, FORWARDER],
                    input=b"e2e clipboard check",
                    capture_output=True,
                    timeout=5,
                    env=_test_env(clipboard=f"tee {clip_file}"),
                )
                self.assertEqual(result.returncode, 0)
            finally:
                stop_receiver(receiver)

            with open(clip_file, "rb") as f:
                self.assertEqual(f.read(), b"e2e clipboard check")
        finally:
            if os.path.exists(clip_file):
                os.unlink(clip_file)


# ------------------------------------------------------------------------------


def setUpModule():
    global TEST_PORT
    TEST_PORT = _pick_free_port()


if __name__ == "__main__":
    setUpModule()
    unittest.main()

# ------------------------------------------------------------------------------
