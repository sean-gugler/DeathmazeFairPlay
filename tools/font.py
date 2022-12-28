#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate an HGR page from font data
by Sean Gugler
"""

import sys
import argparse
from itertools import islice,chain

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="PRG file for font data")
    p.add_argument('output', help="output, PRG file in HGR format")
    p.add_argument('offset', help="offset (hex) where font data is found in input")
    return p.parse_args(argv[1:])

# Byte offsets to scan lines (bitmap rows) in Apple II HGR memory, in vertical order
screen = [i + j + k  for i in range(0, 0x80, 0x28) for j in range(0, 0x400, 0x80) for k in range(0, 0x2000, 0x400)]

def main(argv):
    args = usage(argv)

    with open(args.input, 'rb') as f:
        src = f.read()
    i = int(args.offset, 16)

    # Write data into an initially-empty screen, with proper HGR memory placement.
    frame = bytearray(0x2000 - 8)
    font = iter(src[i:])
    fname = args.output

    for row in range(8):
        for col in range(16):
            for line in range(8):
                b = next(font)
                i = screen[row * 8 + line] + col + 4
                frame[i] = b
                i += 17
                frame[i] = b
                i = screen[(row * 2 + 9) * 8 + line] + col * 2 + 5
                frame[i] = b

    with open(fname, 'wb') as out:
        load_addr = b'\x00\x40'  # lo+hi
        out.write(load_addr + frame)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
