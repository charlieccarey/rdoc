#!/usr/bin/env Rscript
#------------------------------------------------------------------
#
# Plot a calibration curve for deepdive.
#
# Usage:
#
#    Rscript --vanilla plot_deepdive_calibration.R my_dd_predictions.tsv ofile
#    Rscript --vanilla ../scripts/plot_deepdive_calibration.R deepdive_app/8_0_3_quick_auditory_perception/run/LATEST/calibration/_annotated_sentences.has_term.tsv temp.plot
#
#------------------------------------------------------------------
library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
ifile = args[1]
ofile_stem = args[2]

print(paste('Reading :', ifile))

t <- read.table(args[1])
t$V6 <- t$V3 - t$V4 - t$V5


pos_lab = 'Positive training'
neg_lab = 'Negative training'
neut_lab = 'Unknown' # includes pseudolabeled unkowns (i.e. were labeled positive / negative, but now unkown for prediction)

pos <- cbind.data.frame(class=pos_lab, bin=t$V1 + 0.1, count=t$V4)
neg <- cbind.data.frame(class=neg_lab, bin=t$V1 + 0.1, count=t$V5)
n <- cbind.data.frame(class=neut_lab, bin=t$V1 + 0.1, count=t$V6)
all <- rbind.data.frame(neg,n,pos)


print(paste0('Writing results to : ', ofile_stem, '_histogram.pdf'))

pdf(paste0(ofile_stem, '_histogram.pdf'))
ggplot(all, aes(x=as.character(bin), y=count, fill=class, xlab='probability bin')) +
  geom_bar(stat='identity', position='dodge') +
  ggtitle('histogram') +
  xlab('probability bin')
dev.off()

png(paste0(ofile_stem, '_histogram.png'))
ggplot(all, aes(x=as.character(bin), y=count, fill=class, xlab='probability bin')) +
  geom_bar(stat='identity', position='dodge') +
  ggtitle('histogram') +
  xlab('probability bin')
dev.off()

print(paste0('Writing results to : ', ofile_stem, '_stacked_histogram.pdf'))

pdf(paste0(ofile_stem, '_stacked_histogram.pdf'))
ggplot(all, aes(x=bin, y=count, fill = class)) + 
  geom_bar(stat = "identity") + 
  ggtitle('Stacked histogram') +
  xlab('input class')
dev.off()

png(paste0(ofile_stem, '_stacked_histogram.png'))
ggplot(all, aes(x=bin, y=count, fill = class)) + 
  geom_bar(stat = "identity") + 
  ggtitle('Stacked histogram') +
  xlab('input class')
dev.off()

#plot(x=t$V1+0.1, y=t$V3, xlim = c(0,1), ylim = c(0,max(t)), col = 'grey', main='calibration curve deepdive documentation')
# points(x=t$V1+0.1, y=t$V4, col = 'blue')
# points(x=t$V1+0.1, y=t$V5, col = 'red')

