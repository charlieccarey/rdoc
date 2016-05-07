#!/usr/bin/env Rscript
# report_dd_confusion_matrix.R
#
# Generates confusion matrix and plots from custom tables
# extracted from running DeepDive.
#
# TODO: Remove hardcoding of variable names used to determine
# class membership.
#
# Usage:
# 
#   RScript ../../../scripts/report_dd_confusion_matrix.R cc_all_predictions.tsv test aud
#
# Output:
#
#   test_all_known_aud.pdf
#   test_all_known_aud_confmatr.tsv
#   test_all_known_aud_stats.tsv
#   test_test_only_aud.pdf
#   test_test_only_aud_confmatr.tsv
#   test_test_only_aud_stats.tsv
#   test_train_only_aud.pdf
#   test_train_only_aud_confmatr.tsv
#   test_train_only_aud_stats.tsv
#
# ---------------------------------------------------------------!
title_size = 0.6

plot_expect_vs_known_t_f <- function(df, x, y, color, title) {
  require(ggplot2)  
  p <- ggplot(df, aes_string(x=x, y=y, color=color)) +
    geom_point(shape=1) + 
    labs(title=paste0('Expect values by article class\n', title),
         x='articles', 
         y='deepdive prediction') +
    theme(plot.title=element_text(size=rel(title_size)),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title=element_text(size=rel(1))) +
    scale_color_discrete(name="Known Class",
                         breaks=c("t", "f"),
                         labels=c("POSITIVE", "NEGATIVE"))
  #p
}

plot_unknowns <- function(df, x, y, color, title) {
  require(ggplot2)  
  p <- ggplot(df, aes_string(x=x, y=y)) +
    geom_point(shape=1, color=color) + 
    labs(title=paste0('Expect values by article class\n',title),
         x='articles', 
         y='deepdive prediction') +
    theme(plot.title=element_text(size=rel(title_size)),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title=element_text(size=rel(1)))
  plot_title = paste0(title, '.pdf')
  pdf(plot_title, height=4, width=4)
  print(p)
  dev.off()
  #p
}

get_confusion_matrix <- function(df) {
  # Can check result categories based solely on table...
  #    PPV = TP / (TP + FP)
  #    Sensitivity = TP / (TP + FN)
  #    Specificity = TN / (TN + FP)
  require('caret')
  df$pred_class <- ifelse(df$expect >= 0.5, 'Positive', 'Negative')
  df$known_class <- as.factor(ifelse(df$raw_has_terms == 't', 'Positive', 'Negative'))
  print(levels(df$known_class))
  # will possibly have many cases where we have no negatives
  # want to make sure we don't break confusionMatrix
  if(!'Negative' %in% levels(df$known_class)){
    df$known_class <- factor(df$known_class, levels = c('Negative', 'levels(df$known_class)'))
    #df$known_class <- factor(df$known_class, levels = c('Negative', 'Positive'))
  }
  cm = confusionMatrix(df$pred_class, df$known_class, positive='Positive')
  accuracy = cm$overall[c('Accuracy', 'AccuracyLower', 'AccuracyUpper')]
  cm_tab = cm$table
  other_stats = cm$byClass
  stats = c(accuracy, other_stats)
  return(list(table=cm_tab, stats=stats))
}


get_and_write_table_plot <- function(df, title_stem){
  df <- df[!duplicated(df$sentence_id),] # ex. 1000 disease + 146 auditory
  df$index <- row.names(df)
  if (!all(is.na(df$raw_has_terms))) { # skip confusion matrix if plotting only unknowns
    df_conf <- get_confusion_matrix(df)
    write.table(df_conf$stats, paste0(title_stem, '_stats.tsv'), sep='\t', col.names=FALSE)
    write.table(df_conf$table, paste0(title_stem, '_confmatr.tsv'), sep='\t')
  }
  plot_title = paste0(title_stem, '.pdf')
  p <- plot_expect_vs_known_t_f(df, 'index', 'expect', 'raw_has_terms', title_stem)
  pdf(plot_title, height=5, width=5)
  print(p)
  dev.off()
  #p
}


# ex. SQL table resulting from a query of deepdive
# cc_all_predictions.tsv
args = commandArgs(trailingOnly=TRUE)
ifile = args[1]
ofile_stem = args[2]
title = args[3]

# print(paste('Reading :', ifile))

#ifile = 'cc_all_predictions.tsv'
t = read.table(ifile, sep = '\t', col.names=c('test_has_term', 'raw_has_terms', 'sentence_id', 'expect'), na.strings=c('\\N'))

# Reporting predictions from all labeled classes

all_known <- unique(t[!is.na(t$raw_has_terms), !(names(t) %in% c('test_has_term'))])
get_and_write_table_plot(all_known, paste0(ofile_stem, '_all_known_', title))

# Reporting predictions on only the test or 'holdout' classes

test <- unique(t[!is.na(t$test_has_term) & !is.na(t$raw_has_terms),])
get_and_write_table_plot(test, paste0(ofile_stem, '_test_only_', title))

# Reporting predictions on only the training classes

test_ids <- test$sentence_id
train <- unique(t[is.na(t$test_has_term) & !is.na(t$raw_has_terms) & !t$sentence_id %in% test_ids,])
get_and_write_table_plot(train, paste0(ofile_stem, '_train_only_', title))

# Reporting predictions on only the uknown.
# (Only the plot as confusion matrix is irrelevant)

known_ids <- all_known$sentence_id
u <- unique(t[is.na(t$raw_has_terms) & !t$sentence_id %in% known_ids,])
u$index <- row.names(u)
nrow(u)
plot_unknowns(u[!duplicated(u$sentence_id),], 'index', 'expect', 'blue', paste0(ofile_stem, '_unknowns_only_', title))
