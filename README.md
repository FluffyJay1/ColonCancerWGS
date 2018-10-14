# Gene2Cosmic.R

## Gene2Cosmic(genefilepath, cosmicfilepath, outputfilename, minqual = 10, sheets = 3)

### Description: 
Creates files called (outputfilename)\_(i).xlsx at the working directory, i = the sheet in the original excel file.
These files contain the significant genes (QUAL > minqual) with the COSMIC match (T/F) column appended.
A match is defined as the starting position of the mutations being the same.
If there is any match, another file called (outputfilename)\_(i)\_COSMIC.xlsx will be created, containing only the COSMIC matches.

### Parameters:
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

### Parameters:
**vcffilepath**: the filepath of the .vcf file of mutations

**cosmicfilepath**: the filepath of the COSMIC file, csv format

**outputfilename**: the name of the output file excluding extensions

**minqual**: minimum quality for a gene to be significant, default is 10

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