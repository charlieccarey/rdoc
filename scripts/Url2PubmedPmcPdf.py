from Bio import Entrez
Entrez.email = "charlieccarey@gmail.com"

class Url2PubmedPmcPdf:
    """Tries to construct a url to a pdf in pubmed central starting from a pubmed id

    Args:
        pubmed_id (string): pubmed id. Uniquely identifies a publication in NIH pubmed.

    Attributes:
        pubmed_ids (list of strings): pubmed_id from ncbi.
        xmls (list of dicts with lists...) : entrez xml records in biopython parsed format.
        list_of_ids_dict (list of dicts) : contains ids, and (if set) the url to the pdf.

    See: http://www.ncbi.nlm.nih.gov/books/NBK25499/table/chapter4.T._valid_values_of__retmode_and/?report=objectonly

    Requires: from Bio import Entrez

    Generally the following should retrieve a pdf after obtaining the
    url to the pdf here:
    
        curl -L http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3306301/pdf -o mytemp.pdf
    """
    def __init__(self, pubmed_ids):
        self.pubmed_ids = [str(p) for p in pubmed_ids] # instead of asserting...
        self.xmls = []
        self.list_of_ids_dict = []
        self.set_urls()

    # def get_ids(self):
    #     """Gets the pubmed, pmc and mids.

    #     Note, useful if we need to troubleshoot pubmed ids that don't map into pmc
    #     """
    #     return self.list_of_ids_dict

    def set_urls(self):
        '''Set urls based on pubmed ids and the related pubmed article info thay pulled out.

        If not in pubmed central, skip'''
        self.get_xml_list()
        self.parse_xmls_article_ids()
        for d in self.list_of_ids_dict:
            # print(d)
            pubmed = d['pubmed']
            assert(pubmed in self.pubmed_ids)
            if 'pmc' in d.keys():
                d.update({'url': 'http://www.ncbi.nlm.nih.gov/pmc/articles/{}/pdf'.format(d['pmc'])})
            else:
                d.update({'url': None})

    def get_urls(self):
        return self.list_of_ids_dict

    def get_xml_list(self):
        handle = Entrez.efetch(db='pubmed', id=self.pubmed_ids, rettype='xml')
        self.xmls = Entrez.read(handle)

    def parse_xmls_article_ids(self):
        """Parses string elements for article ids into list of dicts
        having ids for pmc, mid and pubmed ids.
        """
        ids_list_d = []
        for x in self.xmls:
            ids_list_d.append(self.parse_one_xml_article_id(x))
        self.list_of_ids_dict = ids_list_d

    def parse_one_xml_article_id(self, xml):
        # Assume only one xml
        s_elems = xml['PubmedData']['ArticleIdList']
        s_ids = [(s.attributes['IdType'], s.title().upper()) for s in s_elems]
        return dict(s_ids)

    # Examples of article id dicts from Entrez XML parsing.

    ## NO MID variant, build off of doi... but these vary per journal type, so safer to just build off of pdf if possible
    # {u'doi': '10.5665/SLEEP.2894', u'pubmed': '23904684', u'pmc': 'PMC3700721'}
    ## Alternately (fuller version which is the redirect location we would end up with from ..../pdf/):
    #    http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3314699/pdf/pone.0034106.pdf
    #    http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3700721/pdf/aasm.36.8.1239.pdf

    ## MID variant
    # {u'pii': 'S0001-4575(12)00290-4', u'doi': '10.1016/J.AAP.2012.08.003', u'pubmed': '22959616', u'mid': 'NIHMS405356', u'pmc': 'PMC3513628'}
    # Aleternatively could use:
    #       'http://www.ncbi.nlm.nih.gov/pmc/articles/PMC{}/pdf/{}.pdf'.format(pmc, mid)
    #    http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3260461/pdf/nihms340667.pdf

    ## PMC missing, return 'no pubmed central'
    # {u'doi': '10.1111/J.1365-2869.2012.01008.X', u'pubmed': '22436093'}
    # {u'doi': '10.1111/J.1365-2869.2012.01062.X', u'pubmed': '23171222'}
