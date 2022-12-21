#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Extract strings from game image
by Sean Gugler
"""

import sys
import argparse
import string
from pathlib import Path
from itertools import groupby, islice

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="PRG file with game data")
    p.add_argument('output', help="output file for project-ready string list")
    p.add_argument('extras', help="extras output folder for numbered reference files")
    return p.parse_args(argv[1:])

def runs(it):
    p = None
    for i,v in enumerate(it):
        if p != v:
            yield i
            p = v

def text_blocks(it, min_length):
    R = runs(it)
    pairs = zip(iter(R), R)
    return ((i,j) for i,j in pairs if j-i >= min_length)

def char(b):
    return chr(b & 0x7F)

def printable(b):
    return char(b) in string.printable

# Note: string tables have 1-based indexing
def sections(it, is_start):
    def inc_if (elt, c=[0]):
        c[0] += bool(is_start(elt))
        return c[0]
    return (g for _,g in groupby(it, inc_if))

"""
    ident_illegal = str.maketrans(
        r' :.,*!?"()\<>' + "'" ,
        r"______________" )

    define.append('\t.feature  string_escapes\n')
    word = text.translate(ident_illegal)
    declare.append(f'\tword_{word} = ${i:02x}\n')
"""

def hibit_split(seq):
    for s in sections(seq, lambda c: c & 0x80):
        ba = bytearray(s)
        ba[0] &= 0x7F
        yield ba.decode('ascii')

def synonyms(seq):
    # In the game's vocabulary table, any word
    # ending in * indicates the next word is a synonym.
    # Both use the same number for internal game logic.
    syn = ''
    for text in seq:
        if text.endswith('*'):
            syn += text[:-1] + ' '
        else:
            yield syn + text
            syn = ''

def write_section(out, label, seq, folder):
    out.write(f'[{label}]\n')
    path = Path(folder) / f'string_nums_{label.lower()}.txt'
    with path.open('wt') as ref:
        for n,text in enumerate(seq, 1):
            out.write(f'{text}\n')
            ref.write(f'{n:3} ${n:02x} {text}\n')
    out.write('\n')

def write_quoted(out, label, text, stride):
    out.write(f'[{label}]\n')
    for i in range(0, len(text), stride):
        line = text[i:i+stride]
        out.write(f'"{line}"\n')
    out.write('\n')

def find_intro(text):
    # There's usually some compiler-junk surrounding
    # the text of interest. We trim it by knowing:
    #  - there are exactly 23 lines of 40-column text we want
    #  - line 21 begins with the unique string "Copyright"
    #  - the last line is 2 bytes short
    ROWLEN = 40
    END = ROWLEN * 23

    i = text.find(b'Copyright') - ROWLEN * 21
    j = i + END - 2
    trim = text[i:j].decode('ascii')

    return ROWLEN, trim

def main(argv):
    args = usage(argv)

    with open(args.input, 'rb') as f:
        src = f.read()

    P = map(printable, src)
    T = text_blocks(P, 100)
    S = (src[i:j] for i,j in T)

    with open(args.output, 'wt') as f:
        # First chunk of text is a concatenation of the verb list and the noun list.
        # Verbs are not capitalized and nouns are, so that's how we know where to divide the list.
        def upper_cased(text):
            return text[0].isupper()

        W = hibit_split(next(S))
        # G = groupby(W, upper_cased)
        # Convert generators to lists
        # Verbs, Nouns = [[w for w in g] for _,g in G]
        
        # write_section(f, 'Verbs', Verbs[1])
        # write_section(f, 'Nouns', Nouns[1])
        # number_vocab(vn)


        L = ('Verbs','Nouns')
        G = groupby(W, upper_cased)
        for label, (_,g) in zip(L, G):
            write_section(f, label, synonyms(g), args.extras)

        # Verbs, Nouns = groupby(W, upper_cased)
        # write_section(f, 'Verbs', Verbs[1])
        # write_section(f, 'Nouns', Nouns[1])

        write_section(f, 'Messages', hibit_split(next(S)), args.extras)

        n, text = find_intro(next(S))
        write_quoted(f, 'Intro', text, n)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
