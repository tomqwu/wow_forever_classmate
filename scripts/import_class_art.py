#!/usr/bin/env python3
"""Import the class crests and icon frame from the ForeverHUD project.

The art is the author's original AI-painted work from
github.com/tomqwu/wow_forever_weakaura (assets/ai, exported by its
scripts/media.py). This only box-filters the exported 32-bit TGAs down to
64 x 64 so the 32 x 32 compact cells stay sharp without shipping 256 KB files.
It does not recolor or redraw the art.

    python3 scripts/import_class_art.py [path/to/ForeverHUD/Media]
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = ROOT.parent / 'forever-gui-aura/src/ForeverHUD/Media'
TEXTURES = ROOT / 'addons/ForeverUtilities/Textures'
TOKENS = ('WARRIOR', 'PALADIN', 'HUNTER', 'ROGUE', 'PRIEST', 'SHAMAN', 'MAGE', 'WARLOCK', 'DRUID')
TARGET = 64


def read_tga(path):
    data = path.read_bytes()
    id_length, cmap_type, image_type = data[0], data[1], data[2]
    width, height, depth, descriptor = struct.unpack('<HHBB', data[12:18])
    if cmap_type or image_type != 2 or depth != 32:
        raise SystemExit(f'{path}: expected uncompressed 32-bit TGA')
    pixels = data[18 + id_length:18 + id_length + width * height * 4]
    return width, height, descriptor, pixels


def downsample(width, height, pixels, size):
    """Premultiplied box filter, so transparent edges do not darken."""
    step = width // size
    if width != height or width % size:
        raise SystemExit('expected a square power-of-two source')
    out = bytearray()
    area = step * step
    for oy in range(size):
        for ox in range(size):
            b = g = r = a = 0
            for y in range(oy * step, oy * step + step):
                base = (y * width + ox * step) * 4
                for x in range(step):
                    pb, pg, pr, pa = pixels[base + x * 4:base + x * 4 + 4]
                    b += pb * pa; g += pg * pa; r += pr * pa; a += pa
            if a:
                out += bytes((round(b / a), round(g / a), round(r / a), round(a / area)))
            else:
                out += b'\0\0\0\0'
    return bytes(out)


def write_tga(path, size, descriptor, pixels):
    header = struct.pack('<BBBHHBHHHHBB', 0, 0, 2, 0, 0, 0, 0, 0, size, size, 32, descriptor)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(header + pixels)


def convert(source, destination):
    width, height, descriptor, pixels = read_tga(source)
    write_tga(destination, TARGET, descriptor, downsample(width, height, pixels, TARGET))


def main(argv):
    source = Path(argv[0]) if argv else DEFAULT_SOURCE
    for token in TOKENS:
        convert(source / f'crest-{token.lower()}.tga', TEXTURES / 'Classes' / f'{token}.tga')
    convert(source / 'icon-frame.tga', TEXTURES / 'IconFrame.tga')
    print(f'imported {len(TOKENS)} crests and the icon frame from {source}')


if __name__ == '__main__':
    main(sys.argv[1:])
