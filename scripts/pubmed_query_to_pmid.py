from __future__ import print_function
from Bio import Entrez
import time

Entrez.email = "charlieccarey@gmail.com"

def pubmed_query_to_pubmed_ids(search_string, retmax=20):
    # verify how many records match
    handle = Entrez.egquery(term=search_string)
    record = Entrez.read(handle)
    for row in record["eGQueryResult"]:
        if row["DbName"] == "pubmed":
            print(row["Count"])
    # fetch the ids for those records
    handle = Entrez.esearch(db="pubmed", retmax=retmax, term=search_string)
    record = Entrez.read(handle)
    pubmed_ids = record["IdList"]
    return(pubmed_ids)


query = '("humans"[MeSH Terms] OR "humans"[All Fields] OR "human"[All Fields]) AND "loattrfree full text"[sb]'

ids = pubmed_query_to_pubmed_ids(query, retmax=1000)

for my_id in ids:
    print(my_id)
