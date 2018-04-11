# Machine Learning for Research Domain Criteria Classification

Categorizing Pubmed Articles using Research Domain Criteria.

The NIMH created the Research Domain Criteria research framework to
facilitate and integrate approaches to research on mental health.

NIMH Research Domain Criteria

We began herein to demonstrate and use machine learning tools to apply
RDoC ideas or terms to categorize psychological literature in an RDoC
aware manner.

The project's genesis was at Montana State University with support
from the Center for Mental Health Research and Recovery and essential
guidance and contributions from NAMI Montana.

## Research Domain Criteria (RDoC).

    RDoC is a research framework for studying mental illnesses.
    - NIMH Resarch Priorities (link) (4-10-2018)

More generally, a benefit of RDoC is to break down the traditional
silos of mental health classification and research. For instance,
schizophrenia might be usefully studied in its own right. Rather than
specifically as a subtopic and separately according to DSM V
classification of mental disorders.

## Project status:

(I wrapped up my involvement in the project. Several months later it was
resumed using different tools by someone else.)

The purpose of classification was to assist researchers in identifying
literature of particular interest to them. A natural extension of the
project can be viewed as serving as a foundation for a more ambitious
analysis and entity extraction from the psychological
literature. Ultimately we wanted to facilitate all the goals of NIMH
RDoC. Mapping literature to concepts. Linking RDoC concepts to neural
models. Extracting genes and protein networks and so on. All in the
context of making this maximally useful to psychologists and
psychiatrists, both in the research and the professional domains.

While RDoC and text classification both continue to be in vogue and
critical research topics, one of the principal tools I used for this
research is in maintenance only status. It has been superseded by many
other tools and the field of natural language processing and text
classification have made tremendous strides.

For those reasons, this repository is in part a look into the past.

That said, several of the tools and the general approach continue to
be useful. It is likely I will revisit them. If you find anything
useful in here, if you are interested in participating in resurrecting
this project with a more up to date approach, or if you simply
have a few questions, I'd be happy to discuss these further.

## Navigating this project

See documentaton_of_key_files.pdf in the pdfs folder for this repository. It might not correspond perfectly to what is here at github, but it should help.

## Shortcuts to prettier views of jupyter notebooks.

TODO: finish this list.

[10_1_design_deepdive_sql_reports_for_confusion_matrix](http://nbviewer.jupyter.org/github/charlieccarey/rdoc/blob/master/jupyter_notebooks/10_1_design_deepdive_sql_reports_for_confusion_matrix.ipynb)

## Project Outline

Apply the following to a few selected RDoC terms of varying precision
or ambiguity to demonstrate our ability to model these topics in the
literature.

Variation 1: Manual annotation and analysis:

1. Use paid annotators of various expertise to markup PDFs of
   abstracts or articles in the primary psychology literature.
2. Extract the sentences marked as most akin to a targeted RDoC concept.
3. Perform natural language processing and machine learning for
   prediction at a sentence level against these manually annotated
   positive and negative training examples.
4. Apply models to predict and classify unlabeled (or holdout)
   portions of the data.
5. Document and visualize measures of success, including using some of
   the standard metrics used in Machine Learning.

Variation 2: Automated 'annotation' and analysis.

1. Use MeSH (Medical Subject Headings) terms that we determined are
   aligned to varying degrees with RDoC definitions.
2. Fetch text versions of these abstracts from Pubmed (NIH, NLM).
3. Use mixtures of in and outgroup's as 'true' and 'false' for
   specific RDoC concepts. Use the entire abstract (rather than
   individual sentences).
4-6. (As in 3-5 in Variation 1).

The advantage of:

- Variation 1: Human's superior annotation ability to deal with ambiguous concepts.
- Variation 2: A much larger training set.

The limitation of:

- Variation 1: The expense in time and/or money for manual annotation.
- Variation 2: Restriction to concepts that are at least partly
  aligned to MeSH terms and thereby accessible by automatic
  selection.

A generalized view of our approach is depicted below.

## Tools used.

![Tools](https://raw.githubusercontent.com/charlieccarey/rdoc/master/images/tools.png)

| Tool       | Purpose                                                                                                          |
|------------|------------------------------------------------------------------------------------------------------------------|
| Biopython  | Automatically fetch Pubmed IDs using Entrez and according to RDoC concepts.                                      |
| Python     | Fetch PDFs from Pubmed Central. Run spaCy. Extract annotations from PDFs.                                        |
| Medic      | A python based tool to manage pubmed ids, abstracts and affiliated data.                                         |
| Humans     | Manual annotation of PDFs. (Highlight positive and negative sentences in different colors.) Tag entire articles. |
| pdfminer   | A python based tool to extract PDF tax by exact location of objects.                                             |
| Spacy      | NLP tasks, such as generating bags of lemmatized words from training data.                                       |
| DeepDive   | Databasing training and 'naive' data, predictive modeling on top of PostgreSQL.                                  |
| PostgreSQL | Database on which DeepDive is built, and which we manipulate to makeup for DeepDive's shortcomings.              |
| R          | Visualize results (ggplot2). Generate confusion matrices.                                                        |
| Jupyter    | Documentation of analysis pipeline, demos, and results.                                                          |
| NIMH       | Source of RDoC concepts.                                                                                         |
| PMC        | Source of most of the PDFs.                                                                                      |

For specific tool versions, see Documentation_of_key_files.pdf section 7.

## Post hoc analysis of the successes and failures of this project.

### Successes.

We had pretty good success on our larger training sets from automated
discovery using MeSH terms to query pubmed. (80-90% correct
predictions to positive and negative categories. See figure.)

![Summary](https://raw.githubusercontent.com/charlieccarey/rdoc/master/images/img.png)

We binned the results to true / false postive and true / false
negative categories in our confusion matrices. However, the primary
scoring on the articles was a percent similarity score. Occasionally
articles were very close to 50% representative of one topic over
another. Inspection of those articles revealed that they
shared characteristics of both the 'in group' and the 'out group'
training sets.

I learned a lot about NLP tasks, Pubmed, and (regrettably) PDF extraction.

### Failures and / or pain points.

: Pain points by tool.

| Tool               | Reason                                                                                                                                   |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| DeepDive           | Kind of 'beta'. Lacked easy ways to generate many typical Machine Learning statistics (like predictive performance on the training set). |
| PDFs               | OMG, extracting PDFs is such a pain in the ...                                                                                           |
| PostgreSQL         | A bit of a hassle to configure with various permissions if you aren't doing this everyday.                                               |
| PMC                | Are we in danger of getting targeted as Aaron Swartz was?                                                                                |

DeepDive:

DeepDive was the most important bottleneck and severely limited what
we might have otherwise accomplished. While it was highly recommended
to us, it was in the early stages of development and undergoing
massive changes as I worked on this project. Too much time was spent
shoehorning it to fit my needs. For example, I had to create proxies
for some of the basic statistics (like ROC curves and training
bias). This sent me down the path of having to develop SQL and
R-Scripts to process multiple tables. Tables that I had to customize,
load and download from the PostgreSQL database.

PDFs:

On the topic of PDFs, OK, we didn't download all that many PDFs and we
stuck to those with less restrictive use. But we could have downloaded
them all (hahahaha!). For those who care, there are more legitimate
ways to download full text from Pubmed for research purposes.

Selecting PDFs for the annotators:

While it would be normal to think that human annotators were the most
'blocking' issue, due to the time of their manual labors, it turned
out that I was limiting the human annotators by failing to give them
as many articles as they could handle. That sounds odd. But the
project relied on my engineering the data analysis. And also on
identifying and delivering PDFs to the participants. The engineering
challenge was sometimes so high, particularly with respect to
extracting annotations from the PDFs, that I fell behind finding new
RDoC categories of PDFs for them.

## If I were to do it again.

Many of these suggestions will be familiar to folks already doing
NLP. I have a short enough memory that it is necessary for me to
record them here or I'll have to relearn it all again from scratch.

### scikit-learn, not DeepDive.

Much of what we succeeded doing would have been accomplished far
easier and faster using Python's scikit-learn machine learning
tools. We suspect our particular use of deepdive largely mimiced a
TFIDF based approach that would have been incredibly easy to implement
in scikit-learn. Part of the appeal of DeepDive was that we could use
it later for more complex entity extractions, but even so, I would
start with tools that are more transparent in how they achieved their
results.

### Annotate text, not PDFs.

PDFs make it easy for annotators to see the journal name. This might
introduce biases in their judgements. Also, PDFs are a pain to extract
annotation information from in a fully automated manner. The
formatting, text size, super and subscript locations etc. varies by
publisher making extracting according to location difficult. Further,
highlighting quality, width and location offsets vary by the
annotator's annotation tool. It all would have been easier if
annotators marked up plain text.

If one is stuck with PDFs, I'm sorry. I went through a lot of
applications, libraries and online services, both paid and free to try
to make this easy. While there were some nice online services, the
shortfall of many of these was the inability to easily extract
annotations in bulk. When they seemed to meet my criteria better, the
pricing was by number of PDFs and was a bit too high for the large
number of PDFs a project like this might eventually handle. Hopefully
that has changed for the better more recently.

### Decide the appropriate granularity of annotation early on.

Should one score or annotate words, phrases, sentences, abstracts?
Paragraphs or entire documents? We ambitiously started with phrases,
then sentences, then entire abstracts. It would have been best to
start at the abstract level for the gross level article categorization
we were trying to achieve. Mostly this is a matter of deriving a
larger and more robust training set from the annotators. And to make
the life of the developer easier.

For the analysis we performed, doing all tagging at an abstract level
would have been the best choice.

It would be an entirely appropriate thing to annotate individual
phrases and words if the primary goal was extraction of individual
entities or their relationships, like genes positively or negatively
involved in schizophrenia.

### Run some models including and excluding metadata.

Because researchers most frequently publish on topics of their own
expertise, and journals are specialized, it would be useful to explore
the use of author and journal names to determine their effect on RDoC
concept predictability.

Because research topics and definitions change over time, including
dates of publications is appropriate. I avoided this particular issue
by defining a narrow window of time for all selected publications.

### Explore topic models and how they overlap with RDoC concepts.

A critical question arises when we rely on possibly arbitrary
decisions by NIMH panelist's definition of RDoC concepts and our
desire to predictively obtain literature based on those concepts. Do
the RDoC categories conform to natural categories of literature?

Topic modeling would have been a great complement to the predictive
training approach we used. Unsupervised topic modeling may have
identified RDoC concepts that matched well with NIMH RDoC panelists,
as well as suggesting other topics that they should consider
integrating into RDoC definitions. It could have pointed us to the
cleanest concepts, and we could focus our most precious resource,
human annotators time, on helping to disambiguate the more difficult
concepts.

gensim would be my tool of choice.

## Data.

Note that I deem the amount of human tagged data as somewhat
insufficient in amount. Much of the automatically generated
training data can be derived following the Jupyter notebooks and
scripts included in this repo.

Data is available here. If you'd like a better description of the
files therein, contact me.

[data](http://rdoc.s3-us-west-2.amazonaws.com/index.html)

## An official project wrapup.

I prepared an official report for Montana State University as we
closed the project. The report is available in the projects pdfs folder.

## Open Source, Support and Attributions.

Montana State University generously supported me throughout this
project. They also generously released the project to the public
domain. See the license.

I thank Montana State University, NAMI Montana, and The Center for Mental
Health Research and Recovery (Montana State University). I also thank
the 3 contributors who spent precious hours annotating PDFs to
generate the training data on which this project depended.