require(ggplot2)
GeneratePeakData = function(bp, molarity) {
  df = data.frame(bp, molarity)
  colnames(df) = c("bp", "molarity")
  return(df)
}

WritePeakData = function(peakData, filepath) {
  write.csv(peakData, file = filepath, row.names = F)
}

ReadPeakData = function(filepath) {
  return(read.csv(filepath))
}

NormalizePeakData = function(peakData) {
  if(is.data.frame(peakData)) {
    peakData$molarity = peakData$molarity/sum(peakData$molarity)
    return(peakData)
  }
  return(lapply(peakData, function(x) {
    x$molarity = x$molarity/sum(x$molarity)
    return(x)
  }))
}

PlotPeakDistribution = function(peakDataList, names = 1:length(peakDataList), minbp = 1, maxbp = 11000) {
  if(is.data.frame(peakDataList)) {
    peakDataList = list(peakDataList)
  } else if(!is.data.frame(peakDataList[[1]])) {
    warning("peakDataList format is incorrect, should use list() instead of c()")
  }
  if(is.list(names)) {
    names = as.character(names)
  }
  df = NULL
  ys = numeric()
  for(i in seq(1, length(peakDataList))) {
    x = minbp:maxbp
    y = numeric(length(x))
    for(j in 1:length(peakDataList[[i]])) {
      y[peakDataList[[i]]$bp[j]] = peakDataList[[i]]$molarity[j]
    }
    col = rep(names[i], each = maxbp - minbp + 1)
    tempdf = data.frame(x, y, col)
    df = rbind(df, tempdf)
    ys = c(ys, y)
  }
  colnames(df) = c("x", "y", "col")
  g = ggplot(df, aes(x)) + scale_x_log10() + scale_y_log10(breaks = round((seq(0.001^0.1, max(df$y + 0.1)^0.1, length.out = 20)) ^ 10, digits = 4))
  g = g + geom_line(data = df, aes(x = x, y = y, group = col, colour=factor(col)))
  g = g + xlab("bp") + ylab("% total molarity") + labs(col = "Samples")
  g
}

