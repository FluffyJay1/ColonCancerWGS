require(xlsx)
Gene2Cosmic = function (genefilepath, cosmicfilepath, outputfilename, minqual = 10, sheets = 3) {
  cosmicfile = read.csv(cosmicfilepath)
  cosmicChr = cosmicfile$MUTATION_GENOME_POSITION
  cosmicChr = substr(cosmicChr, 0, regexpr(":", cosmicChr) - 1)
  cosmicPos = cosmicfile$MUTATION_GENOME_POSITION
  cosmicPos = substr(cosmicPos, regexpr(":", cosmicPos) + 1, regexpr("-", cosmicPos) - 1)
  for(i in 1:sheets) {
    genefile = read.xlsx(genefilepath, sheetIndex = i, startRow = 2)
    sigGenes = as.numeric(genefile$QUAL) > minqual
    if(any(sigGenes)) {
      sigGenesChr = substr(genefile[sigGenes, "X.CHROM"], 4, 10)
      sigGenesPos = genefile[sigGenes, "POS"]
      COSMIC = paste(sigGenesChr, sigGenesPos) %in% paste(cosmicChr, cosmicPos)
      output = cbind(genefile[sigGenes,], COSMIC)
      write.xlsx(output, paste0(outputfilename, "_", i,".xlsx"))
      if(any(COSMIC)) {
        write.xlsx(output[COSMIC,], paste0(outputfilename, "_", i,"_COSMIC.xlsx"))
      }
    }
  }
}
