require(vcfR)
require(xlsx)
VCF2GenePanel = function(vcffilepath, genepanelfilepath, outputfilename, minqual = 10) {
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  sigGenes = as.numeric(as.character(vcffile$QUAL)) > minqual
  sigChrom = substr(as.character(vcffile[sigGenes,"CHROM"]), 4, 100)
  vcfChromMap = list()
  for(x in c(as.character(1:22), "X", "Y")) {
    vcfChromMap[[x]] = vcffile[sigGenes && x == sigChrom,]
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
        for(k in 1:length(relevant)) {
          if(as.numeric(as.character(relevant[k, "POS"])) >= as.numeric(geneExonStarts[[i]][exon]) && as.numeric(as.character(relevant[k, "POS"])) <= as.numeric(geneExonEnds[[i]][exon])) {
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