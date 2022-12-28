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
        src = f.readlines()
    L = iter(src)

    asm = []

    B = []
    b = ''
    for w,s in bitstream(L):
        b += s + w
        if len(b)==8:
            B.append(b)
            if len(B)==3:
                as_bin = ','.join('%'+b for b in B)
                as_hex = ','.join(f'${int(b,2):02x}' for b in B)
                asm.append(f'\t.byte {as_bin} ; {as_hex}\n')
                B = []
            b = ''

    with open(args.output, 'wt') as out:
        out.write(''.join(asm))

    return 0
        
def bit(a,b):
    return '1' if a==b else '0'

def bitstream(L):
    M = []
    for level in range(5):
        next(L) #skip "Level" header
        W = []
        S = []
        for row in range(12):
            line = next(L)[:-1] #remove \n
            w = [bit(c, '|') for c in line[0::4]]
            W.append(w)

            line = next(L)[:-1] #remove \n
            s = [bit(c, '-') for c in line[1::4]]
            S.append(s)

        W = zip(*W)
        S = zip(*S)
        for w,s in zip(W,S):
            yield from zip(reversed(w),reversed(s))

        next(L) #skip blank line

if __name__ == '__main__':
    sys.exit(main(sys.argv))
