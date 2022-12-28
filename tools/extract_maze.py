#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate a textual representation from binary maze data
by Sean Gugler
"""

import sys
import argparse
from itertools import islice,chain

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="PRG file for maze data")
    p.add_argument('output', help="output text file")
    p.add_argument('offset', help="offset (hex) where maze data is found in input")
    return p.parse_args(argv[1:])

def main(argv):
    args = usage(argv)

    with open(args.input, 'rb') as f:
        src = f.read()
    i = int(args.offset, 16)
    maze = iter(src[i:])

    M = []
    for level in range(5):
        M.append(f'# Level {level+1}')
        W = [''] * 12
        S = [''] * 12
        for col in range(11):
            for row in range(12):
                if row % 4 == 0:
                    b = next(maze)
                else:
                    b <<= 2

                S[row] += '+'
                S[row] += '---' if b & 0x80 else '   '
                W[row] += '|' if b & 0x40 else ' '
                W[row] += '   '
        for w,s in reversed(list(zip(W,S))):
            M.append(w)
            M.append(s)
        M.append('')

    with open(args.output, 'wt') as out:
        out.write('\n'.join(M) + '\n')

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
