#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Build assembly directives from a textual representation of the maze
by Sean Gugler
"""

import sys
import argparse
from itertools import chain

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="text file of maze data")
    p.add_argument('output', help="output assembly file")
    return p.parse_args(argv[1:])

def main(argv):
    args = usage(argv)

    with open(args.input, 'rt') as f:
        #remove \n
        src = (s[:-1] for s in f.readlines())

    S = group(bitpairs(src), 4)

    asm = [
        ';;; THIS FILE IS AUTO-GENERATED\n'
        f';;; BY  {sys.argv[0]}\n'
        f';;; FROM  {args.input}\n'
        '\n',
        '\t.export maze_walls\n',
        '\n',
        '\t.segment "MAZE"\n',
        '\n',
        'maze_walls:\n',
        '\t;Each 3-byte sequence is one column, south to north (max 12 cells).\n',
        '\t;Columns are sequenced west to east.\n',
        '\t;Each pair of bits is whether there is a wall to South and West of each cell.\n',
    ]
    for level in range(5):
        asm.append(f'\t; Level {level+1}\n')

        for row in range(11):
            B = [b for _,b in zip(range(3), S)]
            as_bin = ','.join('%'+b for b in B)
            as_hex = ','.join(f'${int(b,2):02x}' for b in B)
            asm.append(f'\t.byte {as_bin} ; {as_hex}\n')

    asm.append('\n.assert >* = >maze_walls, error, "Maze must fit in one page"\n')

    with open(args.output, 'wt') as out:
        out.write(''.join(asm))

    return 0

def group(S, n):
    while True:
        out = ''
        for i in range(n):
            a,b = next(S)
            out += a + b
        yield out

def to_bits(p, s, i):
    return ['1' if c==p else '0'  for c in s[i::4]]

def bitpairs(L):
    while True:
        next(L) #skip "Level" header

        W = []
        S = []
        for row in range(12):
            W.append(to_bits('|', next(L), 3))
            S.append(to_bits('-', next(L), 4))
        W = zip(*W)
        S = zip(*S)

        for w,s in zip(W,S):
            # print(s,w)
            yield from zip(reversed(s),reversed(w))

        next(L) #skip X-axis labels
        next(L) #skip blank line

if __name__ == '__main__':
    sys.exit(main(sys.argv))
