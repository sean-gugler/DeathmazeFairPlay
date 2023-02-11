#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Build assembly-ready files from master string list
by Sean Gugler
"""

import sys
import argparse
import string
from pathlib import Path
from itertools import groupby, islice

def usage(argv):
    p = argparse.ArgumentParser(description = __doc__.split('\n')[1])  # extract first line of ''' header
    p.add_argument('input', help="project-ready string list")
    p.add_argument('verbs', help="file stem for verb strings")
    p.add_argument('nouns', help="file stem for noun strings")
    p.add_argument('messages', help="file stem for message strings")
    p.add_argument('intro', help="file stem for intro")
    p.add_argument('-f', '--full', action='store_true', help="Retain full words, do not truncate to 4 letters")
    return p.parse_args(argv[1:])

def sections(it):
    def delimiter(elt, k=[None]):
        if elt.startswith('['):
            k[0] = elt[1:-1]
        return k[0]

    def make_list(grouper):
        # Grouper requires 'for' iteration to function properly.
        # Coercing with 'list(group)' doesn't work.
        L = [v for v in grouper]

        # First line is section name, and last is always blank.
        # Remove them both.
        return L[1:-1]

    # Return dictionary keyed by group header
    return {k:make_list(g) for k,g in groupby(it, delimiter)}


def fit4(word):
    return (word + '   ')[:4]

def min4(word):
    return word + ' ' * max(0, 4 - len(word))

def define_vocab(fit, T):
    for text in T:
        # Synonyms get * appended
        W = [fit(w) + '*' for w in text.split()]

        # Remove * from last element, though
        last = W.pop()[:-1]
        W.append(last)

        for word in W:
            yield f'\tmsbstring "{word}"\n'

def define_vocab_full(T):
    for text in T:
        # Synonyms get * prepended
        W = ['*' + w for w in text.split()]

        # Remove * from first element, though
        W[0] = W[0][1:]

        for word in W:
            yield f'\tmsbstring "{word.title()}"\n'

def declare_vocab(prefix, T):
    for i,text in enumerate(T, 1):
        W = map(str.lower, text.split())
        for word in W:
            yield i, f'\t{prefix}_{word} = ${i:02x}\n'
    i += 1
    yield i, f'\n\t{prefix}s_end = ${i:02x}\n'

def define_message(T):
    yield '\t.feature  string_escapes\n'
    for text in T:
        escaped = text.replace('"', '\\"')
        yield f'\tmsbstring "{escaped}"\n'

def declare_message(prefix, T):
    for i,text in enumerate(T, 1):
        line = text.translate(ident_illegal)
        yield i, f'\t{prefix}_{line} = ${i:02x}\n'

ident_illegal = str.maketrans(
    r' :.,*!?"-()\<>' + "'" ,
    r"_______________" )


def main(argv):
    args = usage(argv)

    with open(args.input, 'rt') as f:
        src = (s[:-1] for s in f.readlines())
    S = sections(src)

    DECL = '_decl.i'
    DEF = '_defs.inc'

    VT = S['Verbs Transitive']
    VI = S['Verbs Intransitive']
    marker = {
        1 + len(VT): 'verb_intransitive',
    }
    with open(args.verbs + DECL, 'wt') as out:
        for i,line in declare_vocab('verb', VT + VI):
            if label := marker.get(i):
                out.write(f'\n\t{label} = ${i:02x}\n\n')
                del marker[i]
            out.write(line)
    with open(args.verbs + DEF, 'wt') as out:
        if args.full:
            lines = define_vocab_full(VT + VI)
        else:
            lines = define_vocab(fit4, VT + VI)
        for line in lines:
            out.write(line)

    NU = S['Nouns Unique']
    NM = S['Nouns Multiple']
    NN = S['Nouns Non-Item']
    marker = {
        1 + len(NU): 'nouns_unique_end',
        1 + len(NU) + len(NM): 'nouns_item_end',
    }
    with open(args.nouns + DECL, 'wt') as out:
        for i,line in declare_vocab('noun', NU + NM + NN):
            if label := marker.get(i):
                out.write(f'\n\t{label} = ${i:02x}\n\n')
                del marker[i]
            out.write(line)
    with open(args.nouns + DEF, 'wt') as out:
        if args.full:
            lines = define_vocab_full(NU + NM + NN)
        else:
            lines = define_vocab(min4, NU + NM + NN)
        for line in lines:
            out.write(line)

    M = S['Messages']
    with open(args.messages + DECL, 'wt') as out:
        for i,line in declare_message('text', M):
            out.write(line)
    with open(args.messages + DEF, 'wt') as out:
        for line in define_message(M):
            out.write(line)

    I = S['Intro']
    with open(args.intro + DECL, 'wt') as out:
        out.write('')
    with open(args.intro + DEF, 'wt') as out:
        for line in I:
            out.write(f'\t.byte {line}\n')

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
