# maybe some of the code we were using to combine our input into raw_sentences?

# start populating deepdive tables

# raw sentences

deepdive sql "COPY _raw_sentences FROM STDIN" < ${APP_HOME}"/input/raw_sentences"

# bags of lemmas we processed by nlp within our jupyter notebook.

# should maybe pull this out to its own parser in future.
# but if we do, want to load nlp in spacy.)
# (i.e. examine how deepdive will work through chunks)

deepdive sql "COPY _annotated_sentences FROM STDIN" < ${APP_HOME}"/input/annotated_sentences"
