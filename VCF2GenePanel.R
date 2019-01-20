require(vcfR)
require(xlsx)
VCF2GenePanel = function(vcffilepath, genepanelfilepath, outputfilename, minqual = 10) {
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  sigGenes = as.numeric(as.character(vcffile$QUAL)) > minqual
  sigChrom = substr(as.character(vcffile[,"CHROM"]), 4, 100)
  vcfChromMap = list()
  for(x in c(as.character(1:22), "X", "Y")) {
    vcfChromMap[[x]] = vcffile[sigGenes & x == sigChrom,]
  }
  
  genepanel = read.xlsx(genepanelfilepath, sheetIndex = 1, stringsAsFactors = FALSE)
  geneChrom = substr(genepanel$chrom, 4, 100)
  geneExonStarts = strsplit(genepanel$exonStarts, ",")
  geneExonEnds = strsplit(genepanel$exonEnds, ",")
  
  output = data.frame(character(length(geneChrom)), stringsAsFactors = F)
  matched = rep(F, length(geneChrom))
  
  for(i in 1:length(geneChrom)) {
    chr = geneChrom[i]
    ex = regexpr("_", chr) #in case of weird stuff after number
    if(ex != -1) {
      chr = substr(chr, 1, ex - 1)
    }
    relevant = vcfChromMap[[chr]]
    for(exon in 1:length(geneExonStarts[[i]])) {
      matches = character()
      if(nrow(relevant) != 0) {
        withinBounds = as.numeric(as.character(relevant[, "POS"])) >= as.numeric(geneExonStarts[[i]][exon]) & as.numeric(as.character(relevant[, "POS"])) <= as.numeric(geneExonEnds[[i]][exon])
        for(k in 1:length(withinBounds)) {
          if(withinBounds[k]) {
            matches = c(matches, as.character(relevant[k, "POS"]))
            matched[i] = T
          }
        }
      }
      #append new col if necessary
      if(exon > ncol(output)) {
        output = cbind(output, rep("", nrow(output)), stringsAsFactors = F)
      }
      if(length(matches) > 0) {
        output[i, exon] = paste(matches, collapse = ", ")
      } else {
        output[i, exon] = "-"
      }
    }
  }
  colnames(output) = paste0("exon", 1:ncol(output))
  write.xlsx(cbind(genepanel, output), paste0(outputfilename,".xlsx"))
  if(any(matched)) {
    write.xlsx(cbind(genepanel, output)[matched,], paste0(outputfilename,"_matched.xlsx"))
  }
}


RegionsIntersect = function(start1, end1, start2, end2) {
  return(end1 > start2 && start1 < end2)
}

TumorMutationBurden = function(vcffilepath, genepanelfilepath, minqual = 10) {
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  sigGenes = as.numeric(as.character(vcffile$QUAL)) > minqual
  sigChrom = substr(as.character(vcffile[,"CHROM"]), 4, 100)
  vcfChromMap = list()
  regionStarts = list()
  regionEnds = list()
  for(x in c(as.character(1:22), "X", "Y")) {
    vcfChromMap[[x]] = vcffile[sigGenes & x == sigChrom,]
  }
  
  genepanel = read.xlsx(genepanelfilepath, sheetIndex = 1, stringsAsFactors = FALSE)
  geneChrom = substr(genepanel$chrom, 4, 100)
  geneExonStarts = strsplit(genepanel$exonStarts, ",")
  geneExonEnds = strsplit(genepanel$exonEnds, ",")
  
  output = data.frame(character(length(geneChrom)), stringsAsFactors = F)
  matched = rep(F, length(geneChrom))
  
  #process all regions into their respective chr
  for(i in 1:length(geneChrom)) {
    chr = geneChrom[i]
    ex = regexpr("_", chr) #in case of weird stuff after number
    if(ex != -1) {
      chr = substr(chr, 1, ex - 1)
    }
    if(is.null(regionStarts[[chr]])) {
      regionStarts[[chr]] = as.numeric(geneExonStarts[[i]])
      regionEnds[[chr]] = as.numeric(geneExonEnds[[i]])
    } else {
      regionStarts[[chr]] = c(regionStarts[[chr]], as.numeric(geneExonStarts[[i]]))
      regionEnds[[chr]] = c(regionEnds[[chr]], as.numeric(geneExonEnds[[i]]))
    }
  }
  matches = 0
  codingLength = 0
  for(x in c(as.character(1:22), "X", "Y")) {
    #sort the regions
    newOrder = order(-regionStarts[[x]])
    regionStarts[[x]] = regionStarts[[x]][newOrder]
    regionEnds[[x]] = regionEnds[[x]][newOrder]
    currRegion = 2
    while(currRegion <= length(regionStarts[[x]])) {
      if(RegionsIntersect(regionStarts[[x]][currRegion], regionEnds[[x]][currRegion], 
                          regionStarts[[x]][currRegion - 1], regionEnds[[x]][currRegion - 1])) {
        #merge regions
        regionStarts[[x]][currRegion - 1] = min(regionStarts[[x]][currRegion - 1], regionStarts[[x]][currRegion])
        regionStarts[[x]] = regionStarts[[x]][!(1:length(regionStarts[[x]]) %in% currRegion)]
        regionEnds[[x]][currRegion - 1] = max(regionEnds[[x]][currRegion - 1], regionEnds[[x]][currRegion])
        regionEnds[[x]] = regionEnds[[x]][!(1:length(regionEnds[[x]]) %in% currRegion)]
        
      } else {
        currRegion = currRegion + 1
      }
    }
    
    #regions have been merged, get region length
    
    codingLength = codingLength + sum(regionEnds[[x]] - regionStarts[[x]])
    #print(paste(x, sum(regionEnds[[x]] - regionStarts[[x]])))
    #print(length(regionStarts[[x]]))
    relevant = vcfChromMap[[x]]
    for(region in 1:length(regionStarts[[x]])) {
      if(nrow(relevant) != 0) {
        withinBounds = as.numeric(as.character(relevant[, "POS"])) >= as.numeric(regionStarts[[x]][region]) & as.numeric(as.character(relevant[, "POS"])) <= as.numeric(regionEnds[[x]][region])
        matches = matches + length(which(withinBounds))
      }
    }
  }
  print(paste(matches, "matches,", codingLength, "bp"))
  return(matches/codingLength)
}