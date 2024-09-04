# purpose: plot the sub stability analysis
library(digest)
library(genomation)
library(dendextend)
library(doParallel)
library(foreach)
library(future)
cores <- max(detectCores() %/% 2 + 1, 1)
cl <- makePSOCKcluster(cores)
registerDoParallel(cl)
plan("multicore")

# obj.united <- readRDS("./obj.united.rds")
gene.obj %<-% readTranscriptFeatures("./data/refseq.hg38.bed")
cpg.obj %<-% readFeatureFlank("./data/cpgIsland.hg38.bed")
objs <- readRDS("./results/obj_CpG.rds")
megaObj <- data.frame()
for (i in seq_along(objs)) {
  obj <- objs[[i]]
  # obj$rand <- runif(nrow(obj))
  promoters <- getData(regionCounts(obj, gene.obj$promoters))
  introns <- getData(regionCounts(obj, gene.obj$introns))
  exons <- getData(regionCounts(obj, gene.obj$exons))
  tss <- getData(regionCounts(obj, gene.obj$TSSes))
  # cpg stuff
  feature <- getData(regionCounts(obj, cpg.obj$features))
  flank <- getData(regionCounts(obj, cpg.obj$flanks))
  obj <- getData(obj)

  # obj$hash <- apply(obj, 1, digest)
  rownames(obj) <- obj$hash
  obj$region <- "Intergenic"
  obj$feature <- "Other"

  if (nrow(tss) > 0) {
    tss$region <- "TSS"
    obj2 <- merge(x = obj, y = tss, by = c("chr", "start", "end", "strand", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$region.y))
    obj[idx, "region"] <- "TSS"
  }
  if (nrow(exons) > 0) {
    exons$region <- "Exon"
    obj2 <- merge(x = obj, y = exons, by = c("chr", "start", "end", "strand", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$region.y))
    obj[idx, "region"] <- "Exon"
  }
  if (nrow(introns) > 0) {
    introns$region <- "Intron"
    obj2 <- merge(x = obj, y = introns, by = c("chr", "start", "end", "strand", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$region.y))
    obj[idx, "region"] <- "Intron"
  }
  if (nrow(promoters) > 0) {
    promoters$region <- "Promoter"
    obj2 <- merge(x = obj, y = promoters, by = c("chr", "start", "end", "strand", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$region.y))
    obj[idx, "region"] <- "Promoter"
  }

  if (nrow(feature) > 0) {
    feature$feature <- "CpGi"
    obj2 <- merge(x = obj, y = feature, by = c("chr", "start", "end", "strand", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$feature.y))
    obj[idx, "feature"] <- "CpGi"
  }
  if (nrow(feature) > 0) {
    feature$feature <- "CpGi"
    obj2 <- merge(x = obj, y = feature, by = c("chr", "start", "end", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$feature.y))
    obj[idx, "feature"] <- "CpGi"
  }
  if (nrow(flank) > 0) {
    flank$feature <- "Shore"
    obj2 <- merge(x = obj, y = flank, by = c("chr", "start", "end", "coverage", "numCs", "numTs"), all = TRUE)
    idx <- which(!is.na(obj2$feature.y))
    obj[idx, "feature"] <- "Shore"
  }
  c <- obj[, "numCs"]
  t <- obj[, "numTs"]
  obj$methylation <- c / (c + t)
  obj$hash2 <- apply(obj[, c("chr", "start", "end", "strand")], 1, digest)
  obj <- obj[!duplicated(obj$hash2), ]
  megaObj[obj$hash2, "region"] <- obj$region
  megaObj[obj$hash2, "feature"] <- obj$feature
  megaObj[obj$hash2, "chr"] <- obj$chr
  megaObj[obj$hash2, "start"] <- obj$start
  megaObj[obj$hash2, "end"] <- obj$end
  megaObj[obj$hash2, "strand"] <- obj$strand
  megaObj[obj$hash2, as.character(i)] <- obj$methylation
}

# print(table(megaObj$region))
# print(table(megaObj$feature))
megaObj <- megaObj[!is.na(megaObj$region), ]
megaObj[which(is.na(megaObj), arr.ind = TRUE)] <- 0
saveRDS(megaObj, "methylation_all_samples.rds")
print("done")
# head(megaObj)
