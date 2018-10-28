require(vcfR)
require(xlsx)
VCF2Cosmic = function (vcffilepath, cosmicfilepath, outputfilename, minqual = 10) {
  cosmicfile = read.csv(cosmicfilepath, stringsAsFactors = FALSE)
  cosmicChr = cosmicfile$MUTATION_GENOME_POSITION
  cosmicChr = substr(cosmicChr, 0, regexpr(":", cosmicChr) - 1)
  cosmicPos = cosmicfile$MUTATION_GENOME_POSITION
  cosmicPos = substr(cosmicPos, regexpr(":", cosmicPos) + 1, regexpr("-", cosmicPos) - 1)
  
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  sigGenes = as.numeric(as.character(vcffile$QUAL)) > minqual
  if(!any(sigGenes)) {
    warning(paste("No mutations with qual >", minqual))
    return()
  }
  sigGenesChr = substr(vcffile[sigGenes, "CHROM"], 4, 10)
  sigGenesPos = vcffile[sigGenes, "POS"]
  COSMIC = match(paste(sigGenesChr, sigGenesPos), paste(cosmicChr, cosmicPos), nomatch = 0)
  COSMICGenes = character(length(which(sigGenes)))
  COSMICMutations = data.frame(MUTATION_CDS = character(length(which(sigGenes))), MUTATION_AA = character(length(which(sigGenes))), MUTATION_DESCRIPTION = character(length(which(sigGenes))), MUTATION_ZYGOSITY = character(length(which(sigGenes))), stringsAsFactors = F)
  for(j in which(COSMIC > 0)) {
    COSMICGenes[j] = as.character(cosmicfile[COSMIC[j], "GENE_NAME"])
    COSMICMutations[j,] = cosmicfile[COSMIC[j], c("MUTATION_CDS", "MUTATION_AA", "MUTATION_DESCRIPTION", "MUTATION_ZYGOSITY")]
  }
  output = cbind(COSMICGenes, vcffile[sigGenes,], COSMIC > 0, COSMICMutations)
  write.xlsx(output, paste0(outputfilename,".xlsx"))
  if(any(COSMIC > 0)) {
    write.xlsx(output[COSMIC > 0,], paste0(outputfilename,"_COSMIC.xlsx"))
  }
}
