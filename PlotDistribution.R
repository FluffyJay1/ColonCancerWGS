require(ggplot2)
require(reshape2)
GeneratePeakData = function(bp, molarity) {
  df = data.frame(bp, molarity)
  colnames(df) = c("bp", "molarity")
  return(df)
}

NormalizePeakData = function(peakData) {
  total = sum(peakData$molarity)
  peakData$molarity = peakData$molarity / total
  return(peakData)
}

PlotDistribution = function(peakData, minbp = 1, maxbp = 11000) {
  df = NULL
  ys = numeric()
  for(i in seq(1, length(peakData), by = 2)) {
    x = minbp:maxbp
    y = numeric(length(x))
    for(j in 1:length(peakData[[i]])) {
      y[peakData[[i]][j]] = peakData[[i + 1]][j]
    }
    col = rep((i + 1)/2, each = maxbp - minbp + 1)
    tempdf = data.frame(x, y, col)
    df = rbind(df, tempdf)
    ys = c(ys, y)
  }
  colnames(df) = c("x", "y", "col")
  g = ggplot(df, aes(x)) + scale_x_log10()
  g = g + geom_line(data = df, aes(x = x, y = y, group = col, colour=factor(col)))
  g
}

