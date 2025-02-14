#' ---
#' title: "ex2"
#' author: "Asier Ràfales Vila"
#' date: "29/5/2019"
#' output: html_document
#' ---
#' 
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
## ------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------
###FOLDER DESTINATION DEFINITIONS
#---------------------------------------------------------------------------------------------
workingDir <-getwd()
workingDir
dataDir <- file.path(workingDir, "GSE64896_RAW")
dataDir
resultsDir <- file.path(workingDir, "results")
resultsDir
setwd(resultsDir)

#' 
#' 
#' 
#' 
## ----eval=FALSE, include=FALSE-------------------------------------------
## # DO NOT RUN
## installifnot <- function (pkg){
##   if (!require(pkg, character.only=T)){
##     BiocManager::install(pkg)
## }else{
##   require(pkg, character.only=T)
##   }
## }
## 

#' 
#' 
#' #
#' ## INSTALLATION OF PACKAGES NEEDED
#' #
#' 
## ----eval=FALSE, include=FALSE-------------------------------------------
## source("http://bioconductor.org/biocLite.R")
## biocLite("GEOquery")

#' 
## ----eval=FALSE, include=FALSE-------------------------------------------
## installifnot("pd.mogene.1.0.st.v1")
## installifnot("mogene10sttranscriptcluster.db")
## installifnot("oligo")
## installifnot("limma")
## installifnot("Biobase")
## installifnot("arrayQualityMetrics")
## installifnot("genefilter")
## installifnot("multtest")
## installifnot("annotate")
## installifnot("xtable")
## installifnot("gplots")
## installifnot("scatterplot3d")

#' 
#' 
#' 
#' 
## ------------------------------------------------------------------------
targets <- read.delim("/home/dima/Desktop/asier/Rafales_Asier_OmicsTechniques/Exercise_2/targets.txt")
targets

#' 
#' 
## ------------------------------------------------------------------------
CELfiles <- list.celfiles(file.path(dataDir))
CELfiles

#' 
#' 
#' 
## ------------------------------------------------------------------------
rawData <- read.celfiles(file.path(dataDir,CELfiles))

#' 
#' 
## ------------------------------------------------------------------------
#DEFINE SOME VARIABLES FOR PLOTS
sampleNames <- as.character(targets$Sample_name)
sampleNames
sampleColor <- as.character(targets$colors)
sampleColor



#' 
#' #---------------------------------------------------------------------------------------------
#' ###QUALITY CONTROL OF ARRAYS: RAW DATA
#' #---------------------------------------------------------------------------------------------
#' 
## ------------------------------------------------------------------------

#BOXPLOT
boxplot(rawData, which="all",las=2, main="Intensity distribution of RAW data", 
        cex.axis=0.6, col=sampleColor, names=sampleNames)


#' 
#' 
## ------------------------------------------------------------------------
#HIERARQUICAL CLUSTERING
clust.euclid.average <- hclust(dist(t(exprs(rawData))),method="average")
plot(clust.euclid.average, labels=sampleNames, main="Hierarchical clustering of RawData", 
     cex=0.7,  hang=-1)

#' 
#' 
#' 
#' 
#' #PRINCIPAL COMPONENT ANALYSIS
## ------------------------------------------------------------------------
plotPCA <- function ( X, labels=NULL, colors=NULL, dataDesc="", scale=FALSE, formapunts=NULL, myCex=0.8,...)
{
  pcX<-prcomp(t(X), scale=scale) # o prcomp(t(X))
  loads<- round(pcX$sdev^2/sum(pcX$sdev^2)*100,1)
  xlab<-c(paste("PC1",loads[1],"%"))
  ylab<-c(paste("PC2",loads[2],"%"))
  if (is.null(colors)) colors=1
  plot(pcX$x[,1:2],xlab=xlab,ylab=ylab, col=colors, pch=formapunts, 
       xlim=c(min(pcX$x[,1])-100000, max(pcX$x[,1])+100000),ylim=c(min(pcX$x[,2])-100000, max(pcX$x[,2])+100000))
  text(pcX$x[,1],pcX$x[,2], labels, pos=3, cex=myCex)
  title(paste("Plot of first 2 PCs for expressions in", dataDesc, sep=" "), cex=0.8)
}

plotPCA(exprs(rawData), labels=sampleNames, dataDesc="raw data", colors=sampleColor,
        formapunts=c(rep(16,4),rep(17,4)), myCex=0.6)

#' 
#' 
#' 
#' #SAVE TO A FILE
## ------------------------------------------------------------------------


pdf(file.path(resultsDir, "QCPlots_Raw.pdf"))
boxplot(rawData, which="all",las=2, main="Intensity distribution of RAW data", 
        cex.axis=0.6, col=sampleColor, names=sampleNames)
plot(clust.euclid.average, labels=sampleNames, main="Hierarchical clustering of samples of RawData", 
     cex=0.7,  hang=-1)
plotPCA(exprs(rawData), labels=sampleNames, dataDesc="raw data", colors=sampleColor,
        formapunts=c(rep(16,4),rep(17,4)), myCex=0.6)
dev.off()

#' 
#' 
#' 
#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###DATA NORMALIZATION
#' #---------------------------------------------------------------------------------------------
#' 
#' 
## ------------------------------------------------------------------------
eset<-rma(rawData)

write.exprs(eset, file.path(resultsDir, "NormData.txt"))

#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###QUALITY CONTROL OF ARRAYS: NORMALIZED DATA
#' #---------------------------------------------------------------------------------------------
#' 
#' 
#' #BOXPLOT
## ------------------------------------------------------------------------

boxplot(eset, las=2, main="Intensity distribution of Normalized data", cex.axis=0.6, 
        col=sampleColor, names=sampleNames)


#' 
## ------------------------------------------------------------------------
#HIERARQUICAL CLUSTERING
clust.euclid.average <- hclust(dist(t(exprs(eset))),method="average")
plot(clust.euclid.average, labels=sampleNames, main="Hierarchical clustering of NormData", 
     cex=0.7,  hang=-1)


#' 
#' 
#' #PRINCIPAL COMPONENT ANALYSIS
## ------------------------------------------------------------------------
plotPCA <- function ( X, labels=NULL, colors=NULL, dataDesc="", scale=FALSE, formapunts=NULL, myCex=0.8,...)
{
  pcX<-prcomp(t(X), scale=scale) # o prcomp(t(X))
  loads<- round(pcX$sdev^2/sum(pcX$sdev^2)*100,1)
  xlab<-c(paste("PC1",loads[1],"%"))
  ylab<-c(paste("PC2",loads[2],"%"))
  if (is.null(colors)) colors=1
  plot(pcX$x[,1:2],xlab=xlab,ylab=ylab, col=colors, pch=formapunts, 
       xlim=c(min(pcX$x[,1])-10, max(pcX$x[,1])+10),ylim=c(min(pcX$x[,2])-10, max(pcX$x[,2])+10))
  text(pcX$x[,1],pcX$x[,2], labels, pos=3, cex=myCex)
  title(paste("Plot of first 2 PCs for expressions in", dataDesc, sep=" "), cex=0.8)
}

plotPCA(exprs(eset), labels=sampleNames, dataDesc="NormData", colors=sampleColor,
        formapunts=c(rep(16,4),rep(17,4)), myCex=0.6)


#' 
#' 
#' 
#' #SAVE TO A FILE
## ------------------------------------------------------------------------
pdf(file.path(resultsDir, "QCPlots_Norm.pdf"))
boxplot(eset, las=2, main="Intensity distribution of Normalized data", cex.axis=0.6, 
        col=sampleColor, names=sampleNames)
plot(clust.euclid.average, labels=sampleNames, main="Hierarchical clustering of NormData", 
     cex=0.7,  hang=-1)
plotPCA(exprs(eset), labels=sampleNames, dataDesc="selected samples", colors=sampleColor,
        formapunts=c(rep(16,4),rep(17,4)), myCex=0.6)
dev.off()

#' 
#' 
## ----eval=FALSE, include=FALSE-------------------------------------------
## install.packages("gridSVG")
## source("http://bioconductor.org/biocLite.R")
## biocLite('arrayQualityMetrics')
## 

#' 
#' #ARRAY QUALITY METRICS
## ------------------------------------------------------------------------
arrayQualityMetrics(eset,  reporttitle="QualityControl", force=TRUE)

#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###FILTER OUT THE DATA
#' #---------------------------------------------------------------------------------------------
#' 
## ------------------------------------------------------------------------

annotation(eset) <- "org.Mm.eg.db"
eset_filtered <- nsFilter(eset, var.func=IQR,
                          var.cutoff=0.75, var.filter=TRUE,
                          filterByQuantile=TRUE)
#NUMBER OF GENES OUT
print(eset_filtered$filter.log$numLowVar)

#NUMBER OF GENES IN
print(eset_filtered$eset)



#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###DIFERENTIAL EXPRESSED GENES SELECTION. LINEAR MODELS. COMPARITIONS
#' #---------------------------------------------------------------------------------------------
#' 
#' 
## ------------------------------------------------------------------------
help(make.names)

#' 
#' 
## ------------------------------------------------------------------------

#CONTRAST MATRIX.lINEAR MODEL
treat <- targets$group
treat
lev <- factor(treat, levels = unique(treat))
lev
design <-model.matrix(~0+lev)
design
colnames(design) <- levels(lev)
rownames(design) <- as.vector(sampleNames)
print(design)

#COMPARISON
cont.matrix1 <- makeContrasts( 
  CD103.vs.CD14lo_cDCs = CD103-CD14lo_cDCs,
  CD103.vs.CD14hi_moDCs = CD103-CD14hi_moDCs,
  CD103.vs.inf.moDCs	= CD103-inf.moDCs,
  
  CD14lo_cDCs.vs.CD14hi_moDCs = CD14lo_cDCs-CD14hi_moDCs,
  CD14lo_cDCs.vs.inf.moDCs = CD14lo_cDCs-inf.moDCs,
        
  CD14hi_moDCs.vs.inf.moDCs = CD14hi_moDCs-inf.moDCs,
  
  levels = design)
cont.matrix1
comparison1 <- "CD103.vs.CD14lo_cDCs"
comparison2 <- "CD103.vs.CD14hi_moDCs"
comparison3 <- "CD103.vs.inf.moDCs"
comparison4 <- "CD14lo_cDCs.vs.CD14hi_moDCs"
comparison5 <- "CD14lo_cDCs.vs.inf.moDCs"
comparison6 <- "CD14hi_moDCs.vs.inf.moDCs"



#' 
#' 
## ------------------------------------------------------------------------
 
#MODEL FIT
fit1 <- lmFit(eset_filtered$eset, design)
fit.main1 <- contrasts.fit(fit1, cont.matrix1)
fit.main1
fit.main1 <- eBayes(fit.main1)
fit.main1


#' 
#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###DIFERENTIAL EXPRESSED GENES LISTS.TOPTABLES
#' #---------------------------------------------------------------------------------------------
#' 
#' 
#' 
## ------------------------------------------------------------------------
#FILTER BY FALSE DISCOVERY RATE AND FOLD CHANGE
topTab1 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison1, adjust="fdr",lfc=abs(3))
topTab2 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison2, adjust="fdr",lfc=abs(3))
topTab3 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison3, adjust="fdr",lfc=abs(3))
topTab4 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison4, adjust="fdr",lfc=abs(3))
topTab5 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison5, adjust="fdr",lfc=abs(3))
topTab6 <-  topTable (fit.main1, number=nrow(fit.main1), coef=comparison6, adjust="fdr",lfc=abs(3))

#EXPORTED TO CSV AND HTML FILE
write.csv2(topTab1, file= file.path(resultsDir,paste("Selected.Genes.in.comparison.",
                                                    comparison1, ".csv", sep = "")))

print(xtable(topTab1,align="lllllll"),type="html",html.table.attributes="",
      file=paste("Selected.Genes.in.comparison.",comparison1,".html", sep=""))


#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###VOLCANO PLOTS
#' #---------------------------------------------------------------------------------------------
#' 
#' 
## ------------------------------------------------------------------------

volcanoplot(fit.main1, highlight=10, names=fit.main1$ID, 
            main = paste("Differentially expressed genes", colnames(cont.matrix1), sep="\n"))
abline(v = c(-3, 3))


pdf(file.path(resultsDir,"Volcanos.pdf"))
volcanoplot(fit.main1, highlight = 10, names = fit.main1$ID, 
            main = paste("Differentially expressed genes", colnames(cont.matrix1), sep = "\n"))
abline(v = c(-3, 3))
dev.off()


#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###HEATMAP PLOTS
#' #---------------------------------------------------------------------------------------------
#' 
#' 
## ------------------------------------------------------------------------

#PREPARE THE DATA
my_frame <- data.frame(exprs(eset))
head(my_frame)
HMdata <- merge(my_frame, topTab1, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata2 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata2)
write.csv2(HMdata2, file = file.path(resultsDir,"Data2HM.csv"))


#' 
#' 
## ------------------------------------------------------------------------

#HEATMAP PLOT
#---------------------------------------------------------------------------------------------
###HEATMAP PLOTS
#---------------------------------------------------------------------------------------------

#PREPARE THE DATA
my_frame <- data.frame(exprs(eset))
head(my_frame)


HMdata <- merge(my_frame, topTab1, by.x = 0, by.y = 0)
rownames(HMdata1) <- HMdata1$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata1 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata1)

HMdata <- merge(my_frame, topTab2, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata2 <- HMdata2[, -c(1,10:15)]
head(HMdata)
HMdata2 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata2)

HMdata <- merge(my_frame, topTab3, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata3 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata2)

HMdata <- merge(my_frame, topTab4, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata4 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata4)

HMdata<- merge(my_frame, topTab5, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata5 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata5)

HMdata <- merge(my_frame, topTab6, by.x = 0, by.y = 0)
rownames(HMdata) <- HMdata$Row.names
HMdata <- HMdata[, -c(1,10:15)]
head(HMdata)
HMdata6 <- data.matrix(HMdata, rownames.force=TRUE)
head(HMdata6)


#HEATMAP PLOT
my_palette <- colorRampPalette(c("blue", "red"))(n = 299)


#EXPORT TO PDF FILE
pdf(file.path(resultsDir,"HeatMap1"))
heatmap.2(HMdata1,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap1",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
dev.off()
pdf(file.path(resultsDir,"HeatMap2"))
heatmap.2(HMdata2,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap2",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
dev.off()
pdf(file.path(resultsDir,"HeatMap3"))
heatmap.2(HMdata3,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap3",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
dev.off()
pdf(file.path(resultsDir,"HeatMap4"))
heatmap.2(HMdata4,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap4",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
dev.off()
pdf(file.path(resultsDir,"HeatMap5"))
heatmap.2(HMdata5,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap5",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
dev.off()
pdf(file.path(resultsDir,"HeatMap6"))
heatmap.2(HMdata6,
          Rowv=TRUE,
          Colv=TRUE,
          main="HeatMap6",
          scale="row",
          col=my_palette,
          sepcolor="white",
          sepwidth=c(0.05,0.05),
          cexRow=0.5,
          cexCol=0.9,
          key=TRUE,
          keysize=1.5,
          density.info="histogram",
          ColSideColors=sampleColor,
          tracecol=NULL,
          srtCol=30)
purl("test.Rmd", output = "test2.R", documentation = 2)dev.off()



#' 
#' 
#' 
#' 
#' #---------------------------------------------------------------------------------------------
#' ###DATA ANNOTATION
#' #---------------------------------------------------------------------------------------------
#' 
## ------------------------------------------------------------------------

require(pd.mouse430.2)



probes_tot<-rownames(unique(topTab1))
annotateEset(probes_tot,pd.mouse430.2)

write.csv(select(pd.mouse430.2,probes_tot,
                     columns = c("SYMBOL","ENSEMBL","ENTREZID","PROBEID","UNIGENE","UNIPROT","REFSEQ","GENENAME")),"anotations.csv")



#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
