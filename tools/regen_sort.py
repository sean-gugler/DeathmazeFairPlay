#!/usr/bin/env python3

"""
Sort sections within a Regenerator config script file.
by Sean Gugler
"""

import sys
import argparse
from itertools import groupby

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of """ header
    p.add_argument("-v", "--verbose", action="store_true",
                   help="Verbose output.")
    p.add_argument("filename", help="Regenerator config to adjust")
    return p.parse_args(argv[1:])

def main(argv):
    args = usage(argv)
    run(args.filename)
    return 0

def header(text):
    return text.startswith(':')

def sections(it, is_start):
    def inc_if (elt, c=[-1]):
        c[0] += bool(is_start(elt))
        return c[0]
    return [list(g) for _,g in groupby(it, inc_if)]

def run(fname):
    with open(fname, 'rt') as f:
        S = sections(f, header)

    with open(fname, 'wt') as f:
        for section in S:
            section.sort(key = lambda t: (not header(t), t))
            f.write(''.join(section))


if __name__ == '__main__':
    sys.exit(main(sys.argv))
