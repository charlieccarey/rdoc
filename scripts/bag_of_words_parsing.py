#!/usr/env/bin python
# file cc_bag_of_words_parsing.py
import io
import codecs
from spacy.en import English
import argparse

nlp = English(parser=True, tagger=True) # so we can sentence parse

def spacy_lemma_gt_len(text, length=2):
    '''Create bag of unique lemmas, requiring lemma length > length
    
    Note: setting length to 1 may mess up our postgres arrays as we would
    get commas here, unless we were to quote everything.
    '''
    tokens = []
    #doc = nlp(text.decode('utf8')) #"This is a sentence. Here's another...".decode('utf8'))
    parsed_data = nlp(text) #"This is a sentence. Here's another...".decode('utf8'))
    for token in parsed_data:
        if len(token.lemma_) > length:
            tokens.append(token.lemma_.lower())
    return(list(set(tokens)))

# def remove_stop_words():
#     pass

def spacy_lemma_biwords_gt_len(text, length=3):
    '''Create bag of unique bi-lemmas, requiring lemma length > length
    
    We are crudely eliminating any bi-lemmas that have commas in them to save us in loading postgres arrays.
    '''
    biwords = []
    parsed_data = nlp(text)
    skip_chars = [',', '"', "'"]
    for i in range(1, len(parsed_data) - 1):
        skip = False
        biword = u'{} {}'.format(parsed_data[i].lemma_.lower(), parsed_data[i+1].lemma_.lower())
        if (parsed_data[i].lemma_ in skip_chars or parsed_data[i+1].lemma_ in skip_chars):
            skip = True
        if len(biword) > length and not skip:
            biwords.append(biword)
    return(list(set(biwords)))

def get_scored_abstract_bow(abstracts, score):
    '''Return annotated bag of words.
     my_id   sentences   [tf]    \N
     - score (postgres boolean) :  t f \N
     - column 3, true, false, null.
     - column 4 null id for deepdive use.
     - {{}} is to wrap list as postgres array.
    '''
    results = []
    for a in abstracts:
        # bow = spacy_lemma_gt_len(a[2].decode('utf8'), length=2)
        bow = spacy_lemma_gt_len(a[2].decode('utf-8'), length=2)
        # maybe remove stop words
        bow = u', '.join(bow)
        results.append(u'{}\t{{{}}}\t{}\t{}'.format(a[0], bow, score, '\N'))
    return(results)

def append_raw_sentences(fname, annotations, score=None):
    ''' annotations (list of lists) : [[id, title, abstract],...]
    score (postgres boolean) :  t f \N'''
    with codecs.open(fname, 'a', encoding = 'utf-8') as f:
        for a in annotations:
            f.write(u'{}\t{}\t{}\t{}\n'.format(a[0], a[2].decode('utf-8'), score, '\N'))
                    
def append_annotated_sentences(fname, annotations):
    ''' annotations (list of strings) : ["id\tbagofwords\tpostgres_boolean\t\N",...]'''
    with codecs.open(fname, 'a', encoding = 'utf-8') as f:
        for a in annotations:
            a = a.replace('"', '') # avoid postgres malformed array on unescaped quotes
            f.write(a + '\n')

def main(args):
    pass

if '__name__' == 'main':
     main(sys.argv[1:])
