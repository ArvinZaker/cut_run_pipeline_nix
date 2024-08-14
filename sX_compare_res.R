# purpose: temporary script to check what method is most useful
dir <- "./peak_lvl"
library(readxl)
types <- list.files(dir, )
meta <- data.frame(type = NA, peakCaller = NA, name = NA, peaks = NA)
for (type in types) {
  peakCallers <- list.files(sprintf("%s/%s", dir, type))
  for (peakCaller in peakCallers) {
    fs <- list.files(sprintf("%s/%s/%s", dir, type, peakCaller), pattern = "\\.bed$")
    fs <- grep("peak", fs, value = TRUE)
    names <- sapply(strsplit(fs, "\\."), function(x) {
      return(x[1])
    })
    for (i in seq_along(names)) {
      df <- data.table::fread(sprintf("%s/%s/%s/%s", dir, type, peakCaller, fs[i]))
      # https://en.wikipedia.org/wiki/BED_(file_format)
      colnames(df) <- c("chr", "start", "end", "name", "score", "strand")
      t <- data.frame(type = type, peakCaller = peakCaller, name = names[i], peaks = nrow(df))
      meta <- rbind(t, meta)
    }
  }
}
