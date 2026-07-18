"""
Shared protocol definitions for tmux clipboard forwarding.

Wire format: [4U8:TMXC][1U8:Version][U32:Length][U32:CRC32][xU8:Payload]
Response:    [1U8:Status]
"""

import os
import struct
from dataclasses import dataclass
from enum import IntEnum


class DtTmfResponse(IntEnum):
    """Single-byte ACK/NAK sent by the receiver after processing"""

    ACCEPTED = 0x00 # Accepted and remote clipboard tool succeeded
    REJECTED = 0x01 # tmux-receiver rejected the message
    CLIPERR = 0x02  # Clipboard tool on remote host errored


@dataclass(frozen=True)
class DtTmfConfig:
    """Protocol constants and tuning"""

    PORT: int = int(os.environ.get("DEVTOOLS_TMUX_PORT", "50024"))
    MAGIC: bytes = b"TMXC"
    VERS: int = 1
    STRF: str = "!4sBII"
    PMAX: int = 512 * 1024

    @property
    def hsize(self) -> int:
        return struct.calcsize(self.STRF)
