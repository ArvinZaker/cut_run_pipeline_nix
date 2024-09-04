library(ggplot2)
library(ggpubr)
library(ggsci)
library(hrbrthemes)
library(doParallel)
library(foreach)
library(future)

plan("multicore")
cores <- mat(detectCores() %/% 2 + 1, 1)
cl <- makePSOCKcluster(cores)
registerDoParallel(cl)


head(objs)
head(objs)
objs <- readRDS("./postRes/annotated_peaks.rds")
table(rowSums(objs[[1]][, c("exons", "introns", "promoters", "TSSes")]))

themePlot <- function(p) {
  # p <- p + theme_cleveland()
  p <- p + theme_pubclean()
  ## p <- p + theme_linedraw()
  p <- p + theme(
    legend.position = "top",
    legend.direction = "horizontal",
    panel.spacing = unit(.5, "lines"),
    # :plot.background = element_blank(),
    # panel.background = element_blank(),
    # panel.border = element_rect(color = "black"),
    axis.ticks.x = element_blank(),
    axis.title.x = element_text(size = 12, hjust = 0.5),
    axis.title.y = element_text(size = 12, hjust = 0.5),
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")
  )
  return(p)
}
signalDf <- data.frame()
for (i in seq_along(objs)) {
  obj <- objs[[i]]
  sample <- obj$sample[1]
  signalDf <- rbind(obj[, c("total_signal", "max_signal", "max_signal_region", "sample")], signalDf)
}

signalHist1 <- ggplot(data = signalDf, aes(
  x = log10(max_signal),
  group = sample,
  # fill = Sample
)) +
  geom_density(adjust = 1, color = "black") +
  ggtitle("% Maximum signal distribution") +
  xlab(expression("log"[10] * "Maximum signal")) +
  ylab("Frequency") +
  scale_fill_npg() +
  scale_y_continuous(expand = c(0, 0)) + # , labels = scales::percent
  scale_x_continuous(expand = c(0, 0), trans = scales::log10_trans()) +
  facet_wrap(~sample, ncol = 2, nrow = 2)

signalHist2 <- ggplot(data = signalDf, aes(
  x = log10(total_signal),
  group = sample,
  # fill = Sample
)) +
  geom_density(adjust = 1, color = "black") +
  ggtitle("% Total signal distribution") +
  xlab(expression("log"[10] * "Total signal")) +
  ylab("Frequency") +
  scale_fill_npg() +
  scale_y_continuous(expand = c(0, 0)) + # , labels = scales::percent
  scale_x_continuous(expand = c(0, 0), limits = c(5.5, 9), trans = scales::log10_trans()) +
  facet_wrap(~sample, ncol = 2, nrow = 2)

signalHist1 <- themePlot(signalHist1)
signalHist2 <- themePlot(signalHist2)

# bar plot of regions
# x <- tidyr::pivot_longer(annotDf, cols = c("promoter", "exon", "intron", "intergenic"), names_to = "region")
# regionBar <- ggplot(x, aes(x = reorder(region, -value), y = value, fill = region, color = region)) +
#   geom_bar(position = "dodge", stat = "identity") +
#   ggtitle("Annotation coverage") +
#   xlab("Samples") +
#   ylab("Frequency (%)") +
#   scale_y_continuous(expand = c(0, 0), limits = c(0, 105)) +
#   scale_x_discrete(expand = c(0, 0)) +
#   geom_text(aes(label = paste0(value, "%"), y = value + 2), hjust = .5, color = "black", size = 4) +
#   scale_fill_nejm() +
#   scale_color_nejm() +
#   facet_wrap(~Sample, ncol = 3, nrow = 3)
# regionBar <- themePlot(regionBar)

pdf("./hist.pdf", height = 8, width = 8)
plot(signalHist1)
plot(signalHist2)
dev.off()
# pdf("./s1_bar.pdf", width = 9, height = 15)
# plot(regionBar)
# plot(cpgBar)
# dev.off()


# Used to get the data
# getMethod("getMethylationStats", "methylRawDB")
# showMethods(getMethylationStats)
# getMethod("getCoverageStats", "methylRawDB")

# genomation::plotTargetAnnotation

## showMethods("plotTargetAnnotation")
# showMethods(genomation::plotTargetAnnotation)
## getMethod(genomation::plotTargetAnnotation, "AnnotationByFeature")
# ?genomation::plotTargetAnnotation

# showMethods(getCorrelation)
# getMethod(methylKit::getCorrelation, "methylBase")
# methylKit:::.plotCorrelation
