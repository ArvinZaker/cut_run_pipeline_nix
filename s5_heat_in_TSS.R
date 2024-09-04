library(doParallel)
library(foreach)
library(future)
cores <- detectCores() %/% 2 + 1
# cl <- makePSOCKcluster(cores)
registerDoParallel()
plan("multicore")
options(future.globals.maxSize = 891289600000)

df <- readRDS("./postRes/annotated_peaks_mat.rds")
df <- df[df$sample == "H2AZ", ]
df$mean <- (df$start + df$end) / 2
range <- 3000
df$from <- df$mean - range
df$to <- df$mean + range

db <- list(
  "H2AZ1" = data.table::fread("./results/03_peak_calling/01_bam_to_bedgraph/H2AZ_R1.sorted.bedGraph"),
  "H2AZ2" = data.table::fread("./results/03_peak_calling/01_bam_to_bedgraph/H2AZ_R2.sorted.bedGraph"),
  "IGGC1" = data.table::fread("./results/03_peak_calling/01_bam_to_bedgraph/igg_ctrl_R1.sorted.bedGraph"),
  "IGGC2" = data.table::fread("./results/03_peak_calling/01_bam_to_bedgraph/igg_ctrl_R2.sorted.bedGraph")
)

db <- lapply(db, function(x) {
  colnames(x) <- c("chr", "start", "end", "signal")
  return(x)
})
out <- data.frame()
# nrow(df)
out <- foreach(i = names(db), .combine = "rbind") %:% foreach(j = seq_len(nrow(df)), .combine = "rbind") %dopar% {
  mat <- db[[i]]
  # mat$chr <- paste0("chr", mat$chr)
  v <- df[j, ]
  idx <- unique(c(
    # forward strand
    which(paste0("chr", mat$chr) == v$chr & mat$start >= v$from & mat$end <= v$to),
    # reverse strand
    which(paste0("chr", mat$chr) == v$chr & mat$start <= v$from & mat$end >= v$to)
  ))
  sequence <- as.character(seq(v$start, v$end))
  t <- c()
  t <- rep(0, length(sequence))
  t <- setNames(t, sequence)
  for (k in idx) {
    x <- mat[k, ]
    rows <- as.character(seq(x$start, x$end))
    t[rows] <- t[rows] + x$signal
  }
  t <- na.omit(t)
  return(c(i, v$chr, v$start, v$end, unname(t)))
  # return(data.frame(coord = sequence, signal = t, chr = v$chr, start = v$start, end = v$end, sample = i))
}

saveRDS(out, "./postRes/rawPeakLvl.rds")
data.table::fwrite(out, "./postRes/rawPeakLvl.csv")

print("done")
