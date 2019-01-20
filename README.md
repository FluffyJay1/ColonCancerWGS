# Gene2Cosmic.R

## Gene2Cosmic(genefilepath, cosmicfilepath, outputfilename, minqual = 10, sheets = 3)

### Description: 

Creates files called (outputfilename)\_(i).xlsx at the working directory, i = the sheet in the original excel file.
These files contain the significant mutations (QUAL > minqual) with the COSMIC match (T/F) column appended.
A match is defined as the starting position of the mutations being the same.
If there is any match, another file called (outputfilename)\_(i)\_COSMIC.xlsx will be created, containing only the COSMIC matches.

### Parameters:

**genefilepath**: the filepath of the .xlsx gene file of mutations (e.g. "EGFR analysis.xlsx")

**cosmicfilepath**: the filepath of the COSMIC file, csv format (e.g. "colorectal.csv")

**outputfilename**: the name of the output file excluding extensions

**minqual**: mininum quality for a mutation to be significant, default is 10

**sheets**: number of sheets in the excel file to analyze, default is 3

### Example usage:

`source("Gene2Cosmic.R")`

`Gene2Cosmic('D:\\Michael Yang\\Documents\\Bio project\\EGFR analysis.xlsx', 'D:\\Michael Yang\\Documents\\Bio project\\colorectal.csv', "egfr")`

# VCF2Cosmic.R

## VCF2Cosmic(vcffilepath, cosmicfilepath, outputfilename, minqual = 10)

### Description: 

Creates a file called (outputfilename).xlsx at the working directory.
This file contains the significant mutations (QUAL > minqual) with the COSMIC match (T/F) column appended.
A match is defined as the starting position of the mutations being the same.
If there is any match, another file called (outputfilename)\_COSMIC.xlsx will be created, containing only the COSMIC matches.

### Parameters:

**vcffilepath**: the filepath of the .vcf file of mutations

**cosmicfilepath**: the filepath of the COSMIC file, csv format

**outputfilename**: the name of the output file excluding extensions

**minqual**: minimum quality for a mutation to be significant, default is 10

### Example usage:

`source("VCF2Cosmic.R")`

`VCF2Cosmic("D:\\Michael Yang\\Documents\\Bio project\\thing\\02.vcf", 'D:\\Michael Yang\\Documents\\Bio project\\colorectal.csv', "vcf")`

# PeakDistribution.R

## GeneratePeakData(bp, molarity)

### Description:

Returns a data frame representing the peak data from a vector of bps and a vector of molarities of the same length.

### Parameters:

**bp**: a numeric vector containing the bp information

**molarity**: a numeric vector containing the molarity information

### Example Usage:

`source("PlotDistribution.R")`

`GeneratePeakData(c(35,61,127,10380), c(5411.2,380.6,8254.9,10.9))`

## WritePeakData(peakData, filepath)

### Description:

Simply writes a peakData dataframe to the specified filepath.

### Parameters:

**peakData**: the data to write

**filepath**: the path and name to write to

### Example Usage:

`source("PlotDistribution.R")`

`pd = GeneratePeakData(c(35,61,127,10380), c(5411.2,380.6,8254.9,10.9))`

`WritePeakData(pd, "peakdata/S1.csv")`

## ReadPeakData(peakData, filepath)

### Description:

Simply reads a peakData dataframe from the specified file.

### Parameters:

**filepath**: the file to read from

### Example Usage:

`source("PlotDistribution.R")`

`ReadPeakData("peakdata/S1.csv")`

## NormalizePeakData(peakData)

### Description:

Returns a peakData dataframe or a list of peakData dataframes with their molarities normalized as a % of total between 0 and 1

### Parameters:

**peakData**: a single or a list of peakData to normalize

### Example Usage:

`source("PlotDistribution.R")`

`pd1 = ReadPeakData("peakdata/S1.csv")`

`pd1norm = NormalizePeakData(pd1)`

## PlotPeakDistribution(peakDataList, names = 1:length(peakDataList), minbp = 1, maxbp = 11000)

### Description:

Returns/plots a graph of the distributions of a or a list of peakData dataframes, both axes log-transformed

### Parameters:

**peakDataList**: a single or a list of peakData to graph

**names**: a vector of strings as the names of the lines on the legend

**minbp**: the left bound of the graph, default is 1

**maxbp** the right bound of the graph, default is 11000

### Example Usage:

`source("PlotDistribution.R")`

`pd1 = ReadPeakData("peakdata/S1.csv")`

`pd2 = ReadPeakData("peakdata/S2.csv")`

`PlotPeakDistribution(NormalizePeakData(list(pd1, pd2)), c("sample1","sample2"))`

# PlotCircos.R

## CircosVCFR(vcffilepath, bandwidthmult = 1, bandcolorexp = 2, minqual = 10, topcount = NA)

### Description:

Plots a circos plot from a VCF file.

### Parameters:

**vcffilepath**: the filepath of the .vcf file.

**bandwidthmult**: scale of the width of the bands on the graph, default is 1

**bandcolorexp**: exponent factor of the color of band (higher increases contrast between high and low qual), default is 2

**minqual**: the minimum qual for a mutation to be graphed, default is 10

**topcount**: if not NA, specifies how many mutations to graph, < 1 represents what fraction of total mutations to graph, >=1 represents how many mutations to graph, default is NA

### Example Usage:

`source("PlotCircos.R")`

`CircosVCFR("D:\\Michael Yang\\Documents\\Bio project\\thing\\02.vcf", topcount = 0.1)`

# VCF2GenePanel.R

## VCF2GenePanel(vcffilepath, genepanelfilepath, outputfilename, minqual = 10)

### Description:

For each entry in a gene annotation panel, mutations in the VCF file that fall within the listed exons will have their positions appended to a copy of the gene annotation panel.
Only mutations with QUAL > minqual will be considered.
Files will be created in the working directory.
If there are any matches between mutations and exons, a new file called (outputfilename)_matched.xlsx will be created, containing only gene entries that matched with at least one mutation.

### Parameters:

**vcffilepath**: the filepath of the .vcf file.

**genepanelfilepath**: the filepath of the gene annotation panel.

**outputfilename**: the name of the output file excluding extensions

**minqual**: mininum quality for a mutation to be significant, default is 10

## Example Usage:

`source("VCF2GenePanel.R")`

`VCF2GenePanel("D:\\Michael Yang\\Documents\\Bio project\\thing\\02.vcf", "D:\\Michael Yang\\Documents\\Bio project\\gene annotation_panel.xlsx", "genepanelmutations")`

## TumorMutationBurden(vcffilepath, genepanelfilepath, minqual = 10)

### Description:

For an entire gene annotation panel, the coding regions are noted, then all the mutations from the VCF that fall within the coding regions are tallied. 
The value returned from this function is the tumor mutation burden (TMB), which is the ratio of mutations per coding bp.

### Parameters:

**vcffilepath**: the filepath of the .vcf file.

**genepanelfilepath**: the filepath of the gene annotation panel.

**minqual**: mininum quality for a mutation to be significant, default is 10

## Example Usage:

`source("VCF2GenePanel.R")`

`TumorMutationBurden("D:\\Michael Yang\\Documents\\Bio project\\thing\\02.vcf", "D:\\Michael Yang\\Documents\\Bio project\\gene annotation_panel.xlsx")`
