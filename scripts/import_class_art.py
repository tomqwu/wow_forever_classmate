#!/usr/bin/env python3
"""Import the class crests and icon frame from the ForeverHUD project.

The art is the author's original AI-painted work from
github.com/tomqwu/wow_forever_weakaura (assets/ai, exported by its
scripts/media.py). This only box-filters the exported 32-bit TGAs down to
64 x 64 so the 32 x 32 compact cells stay sharp without shipping 256 KB files.
It does not redraw the art. The frame and divider are also converted to
greyscale so the addon can tint them per class at runtime; the glow is a plain
generated radial falloff.

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


def downsample(width, height, pixels, size, out_height=None):
    """Premultiplied box filter, so transparent edges do not darken."""
    out_height = out_height or size
    step = width // size
    if width % size or height % out_height or height // out_height != step:
        raise SystemExit('expected an evenly divisible power-of-two source')
    out = bytearray()
    area = step * step
    for oy in range(out_height):
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


def write_tga(path, size, descriptor, pixels, height=None):
    header = struct.pack('<BBBHHBHHHHBB', 0, 0, 2, 0, 0, 0, 0, 0, size, height or size, 32, descriptor)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(header + pixels)


def greyscale(pixels):
    """Luminance-preserving greyscale, lifted slightly so tints stay bright."""
    out = bytearray(pixels)
    for i in range(0, len(out), 4):
        b, g, r = out[i:i + 3]
        y = min(255, round((0.299 * r + 0.587 * g + 0.114 * b) * 1.15))
        out[i:i + 3] = bytes((y, y, y))
    return bytes(out)


def convert(source, destination, size=TARGET, height=None, grey=False):
    width, src_height, descriptor, pixels = read_tga(source)
    out = downsample(width, src_height, pixels, size, height)
    write_tga(destination, size, descriptor, greyscale(out) if grey else out, height)


def write_glow(destination, size=64):
    """White radial falloff; tinted and additively blended in game."""
    out = bytearray()
    for y in range(size):
        for x in range(size):
            d = ((x + 0.5 - size / 2) ** 2 + (y + 0.5 - size / 2) ** 2) ** 0.5 / (size / 2)
            a = max(0.0, 1 - d) ** 2
            out += bytes((255, 255, 255, round(a * 255)))
    write_tga(destination, size, 0x28, bytes(out))


def main(argv):
    source = Path(argv[0]) if argv else DEFAULT_SOURCE
    for token in TOKENS:
        convert(source / f'crest-{token.lower()}.tga', TEXTURES / 'Classes' / f'{token}.tga')
    convert(source / 'icon-frame.tga', TEXTURES / 'IconFrame.tga', grey=True)
    convert(source / 'divider.tga', TEXTURES / 'Divider.tga', 256, 16, grey=True)
    write_glow(TEXTURES / 'Glow.tga')
    print(f'imported {len(TOKENS)} crests, the frame and divider from {source}')


if __name__ == '__main__':
    main(sys.argv[1:])
