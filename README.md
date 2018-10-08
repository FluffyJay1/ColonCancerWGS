# Gene2Cosmic.R

## Gene2Cosmic(genefilepath, cosmicfilepath, outputfilename, minqual = 10, sheets = 3)

### Description: 
Creates files called (outputfilename)\_(i).xlsx at the working directory, i = the sheet in the original excel file.
These files contain the significant genes (QUAL > minqual) with the COSMIC match (T/F) column appended.
A match is defined as the starting position of the mutations being the same.
If there is any match, another file called (outputfilename)\_(i)\_COSMIC.xlsx will be created, containing only the COSMIC matches.

### Parameters
**genefilepath**: the filepath of the .xlsx gene file of mutations (e.g. "EGFR analysis.xlsx")

**cosmicfilepath**: the filepath of the COSMIC file, csv format (e.g. "colorectal.csv")

**outputfilename**: the name of the output file excluding extensions

**minqual**: mininum quality for a gene to be significant, default is 10

**sheets**: number of sheets in the excel file to analyze, default is 3

### Example usage:
`source("Gene2Cosmic.R")`
`Gene2Cosmic('D:\\Michael Yang\\Documents\\Bio project\\EGFR analysis.xlsx', 'D:\\Michael Yang\\Documents\\Bio project\\colorectal.csv', "egfr")`

# VCF2Cosmic.R
## VCF2Cosmic(vcffilepath, cosmicfilepath, outputfilename, minqual = 10)

### Description: 
Creates a file called (outputfilename).xlsx at the working directory.
This file contains the significant genes (QUAL > minqual) with the COSMIC match (T/F) column appended.
A match is defined as the starting position of the mutations being the same.
If there is any match, another file called (outputfilename)\_COSMIC.xlsx will be created, containing only the COSMIC matches.

### Parameters
**vcffilepath**: the filepath of the .vcf file of mutations

**cosmicfilepath**: the filepath of the COSMIC file, csv format

**outputfilename**: the name of the output file excluding extensions

**minqual**: minimum quality for a gene to be significant, default is 10

### Example usage:
`source("VCF2Cosmic.R")`
`VCF2Cosmic("D:\\Michael Yang\\Documents\\Bio project\\thing\\02.vcf", 'D:\\Michael Yang\\Documents\\Bio project\\colorectal.csv', "vcf")`
