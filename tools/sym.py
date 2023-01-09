#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate an AppleWin SYM file from linker .lab file
by Sean Gugler
"""

import sys
import argparse
import re

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help=".lab file produced by linker")
    p.add_argument('output', help=".sym file in format usable by AppleWin")
    return p.parse_args(argv[1:])

pat = re.compile(r'al 00(....) .(.*)\n')

def parse(line):
    k,v = pat.match(line).groups()
    return k,v

def main(argv):
    args = usage(argv)

    with open(args.input, 'rt') as f:
        src = f.readlines()

    sym = {k:v for k,v in map(parse, src)}

    with open(args.output, 'wt') as out:
        out.write('; AppleWin Source Symbol Table\n')
        out.write(f'; {args.input}\n')
        for k,v in sym.items():
            out.write(f'{k} {v}\n')

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
