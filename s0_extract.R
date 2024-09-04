# TODO: to compare igg and H2AZ with bedgraph files
library(methylKit)
library(genomation)
library(doParallel)
library(foreach)
library(future)
cores <- max(detectCores() %/% 4 + 1, 1)
cl <- makePSOCKcluster(cores)
registerDoParallel(cl)
plan("multicore")
#
# dir <- "./results/03_peak_calling/04_called_peaks/seacr"
# fs <- list.files(dir)
dir <- "./results/03_peak_calling/05_consensus_peaks"
fs <- list.files(dir)
fs <- grep("counts", fs, value = TRUE)



gene.obj %<-% readTranscriptFeatures("./databases/mm10.bed.txt")

objs <- mclapply(sprintf("%s/%s", dir, fs), data.table::fread, mc.cores = cores)

i <- 1
for (i in seq_along(objs)) {
  obj <- objs[[i]]
  # # colnames(obj) <- c("chr", "start", "end", "total_signal", "max_signal", "max_signal_region")
  colnames(obj) <- c("chr", "start", "end", "start2", "end2", "total_signal", "max_signal", "max_signal_region", "sample", "replicate")
  obj$chr <- paste0("chr", obj$chr)
  # note: found a super efficient way to get annotation to specific features
  # without granges or methylkit
  obj2 <- makeGRangesFromDataFrame(obj, ignore.strand = TRUE)
  regionInfo <- annotateWithGeneParts(obj2, gene.obj)
  geneInfo <- (getAssociationWithTSS(regionInfo))
  regionInfo <- regionInfo@members
  # getAssociationWithTSS(l)
  # this gives the gene info

  # df <- cbind.data.frame(lapply(l, getMembers))
  # ?genomation::getMembers
  obj <- cbind(obj, regionInfo)
  obj <- cbind(obj, geneInfo)
  obj$sample <- strsplit(fs[i], "\\.")[[1]][1]
  obj$peakCaller <- strsplit(fs[i], "\\.")[[1]][2]
  objs[[i]] <- obj
}
objs <- lapply(objs, as.data.frame)
mat <- do.call("rbind.data.frame", objs)

saveRDS(objs, "./postRes/annotated_peaks_obj.rds")
saveRDS(mat, "./postRes/annotated_peaks_mat.rds")
print("done")
