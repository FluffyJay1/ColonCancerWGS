require(vcfR)
require(circlize)
require(ComplexHeatmap)

CircosVCFR = function(vcffilepath, bandwidthmult = 1, bandcolorexp = 2, minqual = 10, topcount = NA) {
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  vcfqual = as.numeric(as.character(vcffile$QUAL))
  sigGenes = logical()
  if(is.na(topcount)) {
    sigGenes = vcfqual > minqual
  } else {
    count = topcount
    if(topcount < 1) {
      count = ceiling(nrow(vcffile) * topcount)
    }
    sigGenes = order(-vcfqual) <= count
  }
  
  if(!any(sigGenes)) {
    warning(paste("No mutations with qual >", minqual))
    return()
  }
  
  sigvcf = vcffile[sigGenes,]
  
  data = data.frame(as.character(sigvcf$CHROM), as.numeric(as.character(sigvcf$POS)), as.numeric(as.character(sigvcf$POS)), as.numeric(as.character(sigvcf$QUAL)))
  colnames(data) = c("chr", "start", "end", "qual")
  circos.par("start.degree" = 0, "gap.degree" = c(rep(3,8), 9, rep(3,14), 5),
             "track.height" = 0.15)
  circos.initializeWithIdeogram(plotType = c("ideogram", "axis", "labels"))
  #a difference of 1000000 is barely enough to show up on screen
  minwidth = 1000000 * bandwidthmult
  minlinkwidth = 1000000 * bandwidthmult
  qualcoefficient = 1 / max(data$qual) #for calculating transparency
  qualalphafun = function(val = 0) {
    1 - 1 / (1 + (val * qualcoefficient) ^ bandcolorexp)
  }
  qualcolorfun = function(x = NULL, return_rgb = FALSE, max_value = 1) {
    res_col = rgb(0, 0.5, 0, alpha = qualalphafun(x))
    if(return_rgb) {
      res_col = t(col2rgb(as.vector(res_col), alpha = TRUE)/255)
    }
    return(res_col)
  }
  
  quallegend = Legend(at = c(signif(min(data[,"qual"]), 4), signif(mean(data[,"qual"]), 4), signif(max(data[,"qual"]), 4)),
                            grid_height = unit(15, "mm"), grid_width = unit(10, "mm"), col_fun = qualcolorfun, title_position = "topleft", title = "Qual")
  
  circos.genomicTrackPlotRegion(data, ylim = c(0, 1), bg.border = NA, track.height = 0.15, panel.fun = function(region, value, ...) {
    tempregion = cbind(region$start - minwidth, region$end + minwidth)
    ytop = rep(0.9, nrow(region))
    #ytop[value$sig] = 1.1
    ybottom = rep(0.1, nrow(region))
    #ybottom[value$sig] = -0.1
    circos.genomicRect(tempregion, ytop = ytop, ybottom = ybottom, col = qualcolorfun(value$qual), border = NA)
  })
  circos.text(CELL_META$xlim[1] - ux(3, "mm"), CELL_META$ycenter, labels = "QUAL", facing = "downward", sector.index = "chr1")
  circos.clear()
  
  pushViewport(viewport(x = 1.4, y = 0.2, width = 1, 
                        height = unit(4, "mm"), just = c("right", "center")))
  grid.draw(quallegend)
  upViewport()
}