# purpose: plot the sub stability analysis
library(ggplot2)
library(ggpubr)
library(ggsci)
library(dendextend)
library(tidyverse)
library(viridis)
library(ComplexHeatmap)
library(digest)
library(doParallel)
library(foreach)
library(future)
gap <- 1
cores <- detectCores() %/% 2 + 1
registerDoParallel()
plan("multicore")
options(future.globals.maxSize = 891289600000)

# db <- readRDS("./postRes/rawPeakLvl.rds")
# mat %<-% matrix(as.numeric(unlist(db[, -c(1:4)])), nrow = nrow(db))



db <- data.table::fread("./postRes/rawPeakLvl.csv")
colnames(db)[1:4] <- c("sample", "chr", "start", "end")
db <- db[order(db$chr), ]
db <- db[order(db$start), ]
db <- db[order(db$end), ]
rowMeta <- db[, 1:4]
table(rowMeta$sample)
mat <- db[, -c(1:4)]

mat1 <- mat[rowMeta$sample == "IGGC1", ]
mat2 <- mat[rowMeta$sample == "IGGC2", ]
mat3 <- mat[rowMeta$sample == "H2AZ1", ]
mat4 <- mat[rowMeta$sample == "H2AZ2", ]

# row info
rowMeta <- rowMeta[rowMeta$sample == "IGGC1", ]
rowMeta$chr <- as.factor(rowMeta$chr)
chrLvl <- levels(rowMeta$chr)
chrCol <- setNames(readLines("./databases/chromosome.txt")[seq_along(levels(rowMeta$chr))], levels(rowMeta$chr))

row_ha <- rowAnnotation(
  "Chromosome" = rowMeta$chr,
  col = list(
    "Chromosome" = chrCol
  ),
  gap = unit(gap / 4, "mm"),
  show_annotation_name = TRUE
)

ht_opt$ROW_ANNO_PADDING <- unit(gap, "mm")

ht1 %<-% Heatmap(log10(data.matrix(mat1) + 1),
  show_heatmap_legend = TRUE,
  row_split = as.vector(rowMeta$chr),
  cluster_rows = FALSE,
  row_gap = unit(gap, "mm"), # add gaps between clsuters
  left_annotation = row_ha, # add annotations
  row_title = NULL, # remove cluster annotations
  show_row_names = FALSE,
  row_names_gp = gpar(fontsize = 1),
  # column formatting
  cluster_columns = FALSE,
  column_names_side = "bottom",
  column_names_gp = gpar(fontsize = 15),
  column_names_max_height = unit(60, "cm"),
  show_column_names = FALSE,
  # column title
  column_title_side = "bottom",
  column_title_gp = gpar(fontsize = 15),
  # colors
  use_raster = TRUE,
  na_col = "grey50",
  col = ggsci::pal_gsea("default")(12),
)
ht2 %<-% Heatmap(log10(data.matrix(mat2) + 1),
  show_heatmap_legend = TRUE,
  row_split = as.vector(rowMeta$chr),
  cluster_rows = FALSE,
  row_gap = unit(gap, "mm"), # add gaps between clsuters
  left_annotation = row_ha, # add annotations
  row_title = NULL, # remove cluster annotations
  show_row_names = FALSE,
  row_names_gp = gpar(fontsize = 1),
  # column formatting
  cluster_columns = FALSE,
  column_names_side = "bottom",
  column_names_gp = gpar(fontsize = 15),
  column_names_max_height = unit(60, "cm"),
  show_column_names = FALSE,
  # column title
  column_title_side = "bottom",
  column_title_gp = gpar(fontsize = 15),
  # colors
  use_raster = TRUE,
  na_col = "grey50",
  col = ggsci::pal_gsea("default")(12),
)

ht3 %<-% Heatmap(log10(data.matrix(mat3) + 1),
  show_heatmap_legend = TRUE,
  row_split = as.vector(rowMeta$chr),
  cluster_rows = FALSE,
  row_gap = unit(gap, "mm"), # add gaps between clsuters
  left_annotation = row_ha, # add annotations
  row_title = NULL, # remove cluster annotations
  show_row_names = FALSE,
  row_names_gp = gpar(fontsize = 1),
  # column formatting
  cluster_columns = FALSE,
  column_names_side = "bottom",
  column_names_gp = gpar(fontsize = 15),
  column_names_max_height = unit(60, "cm"),
  show_column_names = FALSE,
  # column title
  column_title_side = "bottom",
  column_title_gp = gpar(fontsize = 15),
  # colors
  use_raster = TRUE,
  na_col = "grey50",
  col = ggsci::pal_gsea("default")(12),
)
ht4 %<-% Heatmap(log10(data.matrix(mat4) + 1),
  show_heatmap_legend = TRUE,
  row_split = as.vector(rowMeta$chr),
  cluster_rows = FALSE,
  row_gap = unit(gap, "mm"), # add gaps between clsuters
  left_annotation = row_ha, # add annotations
  row_title = NULL, # remove cluster annotations
  show_row_names = FALSE,
  row_names_gp = gpar(fontsize = 1),
  # column formatting
  cluster_columns = FALSE,
  column_names_side = "bottom",
  column_names_gp = gpar(fontsize = 15),
  column_names_max_height = unit(60, "cm"),
  show_column_names = FALSE,
  # column title
  column_title_side = "bottom",
  column_title_gp = gpar(fontsize = 15),
  # colors
  use_raster = TRUE,
  na_col = "grey50",
  col = ggsci::pal_gsea("default")(12),
)

png("./heat_raw.png", width = 7 * 4 * 4, height = 15, unit = "in", res = 500)
draw(ht1 + ht2 + ht3 + ht4, background = "transparent")
dev.off()

# table(apply(mat1, 2, class))
# v1 %<-% (apply(mat1, 2, function(x) mean(as.numeric(x))))
# v2 %<-% (apply(mat2, 2, function(x) mean(as.numeric(x))))
# v3 %<-% (apply(mat3, 2, function(x) mean(as.numeric(x))))
# v4 %<-% (apply(mat4, 2, function(x) mean(as.numeric(x))))
#
# med <- median(c(v1, v2, v3, v4), na.rm = TRUE)
# hist(idx)
# idx <- which(v1 + v2 + v3 + v4 < 4 * med)
# length(idx)
