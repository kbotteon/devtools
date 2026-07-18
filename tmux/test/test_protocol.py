#!/usr/bin/env python3
"""
Protocol tests for tmux-forwarder and tmux-receiver
"""

import io
import os
import struct
import sys
import unittest
import zlib

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from protocol import DtTmfConfig

CONFIG = DtTmfConfig()

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------


def encode(data: bytes) -> bytes:
    """Mirror of tmux-forwarder send logic"""
    header = struct.pack(
        CONFIG.STRF, CONFIG.MAGIC, CONFIG.VERS, len(data), zlib.crc32(data) & 0xFFFFFFFF
    )
    return header + data


def decode(f) -> tuple:
    """Mirror of tmux-receiver frame validation"""
    raw = f.read(CONFIG.hsize)
    if len(raw) != CONFIG.hsize:
        return None, "incomplete header"

    magic, version, length, checksum = struct.unpack(CONFIG.STRF, raw)

    if magic != CONFIG.MAGIC:
        return None, "invalid magic"
    if version != CONFIG.VERS:
        return None, f"unsupported version {version}"
    if length > CONFIG.PMAX:
        return None, f"payload too large"

    data = f.read(length)
    if len(data) != length:
        return None, f"incomplete payload"
    if (zlib.crc32(data) & 0xFFFFFFFF) != checksum:
        return None, "checksum mismatch"

    return data, None


def frame(
    data=b"hello",
    *,
    magic=CONFIG.MAGIC,
    version=CONFIG.VERS,
    length=None,
    checksum=None,
):
    """Build a frame with optional field overrides for error injection"""
    if length is None:
        length = len(data)
    if checksum is None:
        checksum = zlib.crc32(data) & 0xFFFFFFFF
    return struct.pack(CONFIG.STRF, magic, version, length, checksum) + data


# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------


class TestRoundtrip(unittest.TestCase):

    def _decode(self, raw):
        return decode(io.BytesIO(raw))

    def test_valid_small(self):
        payload = b"hello world"
        data, err = self._decode(encode(payload))
        self.assertIsNone(err)
        self.assertEqual(data, payload)

    def test_valid_at_max_size(self):
        payload = b"x" * CONFIG.PMAX
        data, err = self._decode(encode(payload))
        self.assertIsNone(err)
        self.assertEqual(len(data), CONFIG.PMAX)

    def test_valid_single_byte(self):
        data, err = self._decode(encode(b"\x00"))
        self.assertIsNone(err)
        self.assertEqual(data, b"\x00")

    def test_valid_binary(self):
        payload = bytes(range(256)) * 4
        data, err = self._decode(encode(payload))
        self.assertIsNone(err)
        self.assertEqual(data, payload)


class TestHeaderValidation(unittest.TestCase):

    def _decode(self, raw):
        return decode(io.BytesIO(raw))

    def test_empty_input(self):
        _, err = self._decode(b"")
        self.assertEqual(err, "incomplete header")

    def test_truncated_header(self):
        _, err = self._decode(frame()[: CONFIG.hsize - 1])
        self.assertEqual(err, "incomplete header")

    def test_wrong_magic(self):
        _, err = self._decode(frame(magic=b"XXXX"))
        self.assertEqual(err, "invalid magic")

    def test_wrong_version(self):
        _, err = self._decode(frame(version=99))
        self.assertIn("unsupported version", err)

    def test_payload_one_over_max(self):
        _, err = self._decode(frame(length=CONFIG.PMAX + 1))
        self.assertIn("payload too large", err)

    def test_payload_far_over_max(self):
        _, err = self._decode(frame(length=0xFFFFFFFF))
        self.assertIn("payload too large", err)


class TestPayloadValidation(unittest.TestCase):

    def _decode(self, raw):
        return decode(io.BytesIO(raw))

    def test_checksum_mismatch(self):
        _, err = self._decode(frame(checksum=0xDEADBEEF))
        self.assertEqual(err, "checksum mismatch")

    def test_truncated_payload(self):
        raw = encode(b"hello world")
        _, err = self._decode(raw[:-3])
        self.assertIn("incomplete payload", err)

    def test_payload_length_lie(self):
        # Header claims more bytes than are present
        _, err = self._decode(frame(data=b"hi", length=100))
        self.assertIn("incomplete payload", err)

    def test_corrupt_payload(self):
        raw = bytearray(encode(b"hello world"))
        raw[-1] ^= 0xFF  # flip bits in last byte
        _, err = self._decode(bytes(raw))
        self.assertEqual(err, "checksum mismatch")


# ------------------------------------------------------------------------------

if __name__ == "__main__":
    unittest.main()

# ------------------------------------------------------------------------------
