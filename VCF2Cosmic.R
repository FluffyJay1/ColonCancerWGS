require(vcfR)
VCF2Cosmic = function (vcffilepath, cosmicfilepath, outputfilename, minqual = 10) {
  cosmicfile = read.csv(cosmicfilepath)
  cosmicChr = cosmicfile$MUTATION_GENOME_POSITION
  cosmicChr = substr(cosmicChr, 0, regexpr(":", cosmicChr) - 1)
  cosmicPos = cosmicfile$MUTATION_GENOME_POSITION
  cosmicPos = substr(cosmicPos, regexpr(":", cosmicPos) + 1, regexpr("-", cosmicPos) - 1)
  
  vcffile = as.data.frame(getFIX(read.vcfR(vcffilepath, verbose = F)))
  sigGenes = as.numeric(as.character(vcffile$QUAL)) > minqual
  if(any(sigGenes)) {
    sigGenesChr = substr(vcffile[sigGenes, "CHROM"], 4, 10)
    sigGenesPos = vcffile[sigGenes, "POS"]
    COSMIC = paste(sigGenesChr, sigGenesPos) %in% paste(cosmicChr, cosmicPos)
    output = cbind(vcffile[sigGenes,], COSMIC)
    write.xlsx(output, paste0(outputfilename,".xlsx"))
    if(any(COSMIC)) {
      write.xlsx(output[COSMIC,], paste0(outputfilename,"_COSMIC.xlsx"))
    }
  }
}
