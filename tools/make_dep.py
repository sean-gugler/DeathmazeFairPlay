#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate .d makefile dependency file from .s source
by Sean Gugler
"""

import sys
import argparse
from pathlib import Path
import re

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="input asm .s source file")
    p.add_argument('output', help="output dependency .d makefile")
    return p.parse_args(argv[1:])

include = re.compile(r'\t.include "(.*)"')

def includes(src):
    for line in src:
        if m := include.match(line):
            yield m.group(1)

def main(argv):
    args = usage(argv)

    srcPath = Path(args.input)
    obj     = Path(args.output).with_suffix('.o')

    with open(args.input, 'rt') as f:
        src = f.readlines()

    deps = (srcPath.with_name(file) for file in includes(src))
    deps = ' '.join(map(str, deps))

    with open(args.output, 'wt') as out:
        print(f'{obj}: {deps}', file=out)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
