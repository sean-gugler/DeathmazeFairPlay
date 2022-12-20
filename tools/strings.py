#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extract strings from game image
by Sean Gugler
"""

import sys
import argparse
import string
from itertools import groupby, islice

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="PRG file with game data")
    # p.add_argument('output', help="output, TEXT file ready for CA65 compiler")
    return p.parse_args(argv[1:])

def runs(it):
    p = None
    for i,v in enumerate(it):
        if p != v:
            yield i
            p = v

def char(b):
    return chr(b & 0x7F)

def printable(b):
    return char(b) in string.printable

# Note: string tables have 1-based indexing
def sections(it, is_start):
    def inc_if (elt, c=[0]):
        c[0] += bool(is_start(elt))
        return c[0]
    return groupby(it, inc_if)

def write(fname, seq):
    define = []
    declare = []
    reference = []

    ident_illegal = str.maketrans(
        r' :.,*!?"()\<>' + "'" ,
        r"______________" )

    i = 1
    define.append('\t.feature  string_escapes\n')
    for _,s in sections(seq, lambda c: c & 0x80):
        ba = bytearray(s)
        ba[0] &= 0x7F
        text = ba.decode('ascii').replace('"', '\\"')
        # hdr.append(f'; STRING ${i:02x} ({i})\n')
        if len(text) <= 40:
            # word = (text + ' EMPTY').split()[0]
            word = text.translate(ident_illegal)
            define.append(f'\tmsbstring "{text}"\n')
            declare.append(f'\tword_{word} = ${i:02x}\n')
            reference.append(f'{i:3} ${i:02x} {text}\n')
        else:
            j = text.find('Copyright')
            for k in range(j%40, len(text), 40):
                define.append(f'\t.byte "{text[k:k+40]}"\n')
        if not text.endswith('*'):
            i += 1

    with open(fname + '.def.i', 'wt') as out:
        out.write(''.join(define))
    with open(fname + '.decl.i', 'wt') as out:
        out.write(''.join(declare))
    with open(fname + '.txt', 'wt') as out:
        out.write(''.join(reference))

def main(argv):
    args = usage(argv)

    with open(args.input, 'rb') as f:
        src = f.read()

    P = map(printable, src)
    R = runs(P)
    pairs = zip(iter(R), R)
    for c,(i,j) in enumerate(pairs):
        if j-i > 100:
            write(f'{args.input}_strings_{c}', src[i:j])

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
