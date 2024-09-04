# purpose: plot the sub stability analysis
library(ggplot2)
library(ggpubr)
library(ggsci)
library(dendextend)
library(tidyverse)
library(viridis)
library(ComplexHeatmap)
library(digest)
gap <- 1
#
mat <- readRDS("./postRes/annotated_peaks_mat.rds")
mat$feature.name <- gsub("\\.[0-9]$", "", mat$feature.name)
start <- mat$start
mat[, c("start", "start2", "end", "end2", "max_signal_region", "prom", "exon", "intron", "dist.to.feature")] <- NULL
mat$max_signal <- NULL

mat <- as.data.frame(pivot_wider(mat, names_from = "sample", values_from = "total_signal"))
cols <- seq(ncol(mat) - 3, ncol(mat))
v <- apply(mat[, cols], 1, function(x) {
  return(sum(is.na(x)))
})
rowMeta <- mat[, -cols]
mat <- mat[, cols]
mat[which(is.na(mat), arr.ind = TRUE)] <- 0

# row info
rowMeta$feature.strand <- as.factor(as.character(rowMeta$feature.strand))
rowMeta$chr <- as.factor(rowMeta$chr)
strandLbl <- levels(rowMeta$feature.strand)
strandCol <- setNames(c("#52F522", "#8B0000"), strandLbl)
chrLvl <- levels(rowMeta$chr)
chrCol <- setNames(readLines("./databases/chromosome.txt")[seq_along(levels(rowMeta$chr))], levels(rowMeta$chr))

##
##
mat <- mat[order(start), ]
rowMeta <- rowMeta[order(start), ]
# col info
##
##
colMeta <- data.frame(
  histone = as.factor(c("H2AZ", "H2AZ", "H3", "H3")),
  location = as.factor(c("Cell plasma", "Nucleous", "Cell plasma", "Nucleous"))
)

histoneLbl <- levels(colMeta$histone)
histoneCol <- setNames(pal_npg()(length(unique(colMeta$histone))), histoneLbl)
locationLbl <- levels(colMeta$location)
locationCol <- setNames(pal_simpsons()(length(unique(colMeta$location))), locationLbl)


col_ha <- HeatmapAnnotation(
  "Histone" = colMeta$histone,
  "Localization" = colMeta$location,
  col = list(
    "Histone" = histoneCol,
    "Localization" = locationCol
  ),
  gap = unit(gap / 4, "mm"),
  show_annotation_name = TRUE
)


row_ha <- rowAnnotation(
  "Chromosome" = rowMeta$chr,
  "Strand" = rowMeta$feature.strand,
  col = list(
    "Chromosome" = chrCol,
    "Strand" = strandCol
  ),
  gap = unit(gap / 4, "mm"),
  show_annotation_name = TRUE
)

ht_opt$ROW_ANNO_PADDING <- unit(gap, "mm")

png("./heat_total.png", width = 7, height = 15, unit = "in", res = 500)
draw(
  Heatmap(log10(data.matrix(mat) + 1),
    show_heatmap_legend = TRUE,
    row_split = as.vector(rowMeta$chr),
    cluster_rows = FALSE,
    # row_order = names(cl), # order rownames
    row_gap = unit(gap, "mm"), # add gaps between clsuters
    left_annotation = row_ha, # add annotations
    top_annotation = col_ha,
    row_title = NULL, # remove cluster annotations
    # row names formatting
    show_row_names = FALSE,
    row_names_gp = gpar(fontsize = 1),
    # column formatting
    cluster_columns = FALSE,
    column_names_side = "bottom",
    column_names_gp = gpar(fontsize = 15),
    column_names_max_height = unit(60, "cm"),
    show_column_names = TRUE,
    # column title
    # , column_title = "Number of subsets",
    column_title_side = "bottom",
    column_title_gp = gpar(fontsize = 15),
    # colors
    na_col = "grey50",
    col = ggsci::pal_gsea("default")(12),
    heatmap_legend_param = list(
      title = "Total\nsignal",
      at = seq(0, 10, 2),
      labels = c(1, expression(10^2), expression(10^4), expression(10^6), expression(10^8), expression(10^10))
    )
  ),
  background = "transparent"
)
dev.off()
