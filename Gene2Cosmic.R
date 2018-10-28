require(xlsx)
Gene2Cosmic = function (genefilepath, cosmicfilepath, outputfilename, minqual = 10, sheets = 3) {
  cosmicfile = read.csv(cosmicfilepath, stringsAsFactors = FALSE)
  cosmicChr = cosmicfile$MUTATION_GENOME_POSITION
  cosmicChr = substr(cosmicChr, 0, regexpr(":", cosmicChr) - 1)
  cosmicPos = cosmicfile$MUTATION_GENOME_POSITION
  cosmicPos = substr(cosmicPos, regexpr(":", cosmicPos) + 1, regexpr("-", cosmicPos) - 1)
  for(i in 1:sheets) {
    genefile = read.xlsx(genefilepath, sheetIndex = i, startRow = 2, stringsAsFactors = FALSE)
    genequals = genefile$QUAL
    if(!is.numeric(genequals)) {
      warning(paste("Warning in sheet", i, ", expected numbers in QUAL, output may be bugged"))
    }
    sigGenes = genequals > minqual
    if(any(sigGenes)) {
      sigGenesChr = substr(genefile[sigGenes, "X.CHROM"], 4, 10)
      sigGenesPos = genefile[sigGenes, "POS"]
      COSMIC = match(paste(sigGenesChr, sigGenesPos), paste(cosmicChr, cosmicPos), nomatch = 0)
      COSMICGenes = character(length(which(sigGenes)))
      COSMICMutations = data.frame(MUTATION_CDS = character(length(which(sigGenes))), MUTATION_AA = character(length(which(sigGenes))), MUTATION_DESCRIPTION = character(length(which(sigGenes))), MUTATION_ZYGOSITY = character(length(which(sigGenes))), stringsAsFactors = F)
      for(j in which(COSMIC > 0)) {
        COSMICGenes[j] = as.character(cosmicfile[COSMIC[j], "GENE_NAME"])
        COSMICMutations[j,] = cosmicfile[COSMIC[j], c("MUTATION_CDS", "MUTATION_AA", "MUTATION_DESCRIPTION", "MUTATION_ZYGOSITY")]
      }
      output = cbind(COSMICGenes, genefile[sigGenes,], COSMIC > 0, COSMICMutations)
      write.xlsx(output, paste0(outputfilename, "_", i,".xlsx"))
      if(any(COSMIC > 0)) {
        write.xlsx(output[COSMIC > 0,], paste0(outputfilename, "_", i,"_COSMIC.xlsx"))
      }
    }
  }
}
