#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Report the Row,Column position of a given memory address in Apple HGR space.
by Sean Gugler
"""

import sys
import argparse
from itertools import islice,chain

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('address', help="in hexadecimal")
    return p.parse_args(argv[1:])

def bitsplit(value, num):
    mask = (1 << num) - 1
    return (value >> num), (value & mask)

def main(argv):
    args = usage(argv)

    addr = int(args.address, 16)

    hi,lo = bitsplit(addr, 7)
    stride,col = divmod(lo, 40)

    hi,row = bitsplit(hi, 3)
    page,raster = bitsplit(hi, 3)

    # 0-based indexing for consistency with zp_row,zp_col convention
    print(f'Page {page} Row {row+stride*8} Col {col} Line {raster}')
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
