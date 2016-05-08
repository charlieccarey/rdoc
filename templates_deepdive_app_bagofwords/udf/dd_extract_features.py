#!/usr/bin/env python
from __future__ import print_function

'''
1\taaaa~^~bbbb~^~cccc
2\tdddd~^~EEEE~^~ffff
'''

import sys

ARR_DELIM = '~^~'

for row in sys.stdin:
    row = row.strip()
    sent_id, lemmas = row.split('\t')
    lemmas = lemmas.split(ARR_DELIM)
    for lemma in lemmas:
        print('{}\t{}'.format(sent_id, lemma))
