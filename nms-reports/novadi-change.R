library(grid)
library(lattice)

if (!"gridSVG" %in% installed.packages()) install.packages("gridSVG")
library(gridSVG)

if (!"pxR" %in% installed.packages()) install.packages("pxR")
library(pxR)

if (!"sp" %in% installed.packages()) install.packages("sp")
library(sp)

if (!"latticeExtra" %in% installed.packages()) install.packages("latticeExtra")
library(latticeExtra)

if (!"maptools" %in% installed.packages()) install.packages("maptools")
library(maptools)

if (!"classInt" %in% installed.packages()) install.packages("classInt")
library(classInt)

if (!"colorspace" %in% installed.packages()) install.packages("colorspace")
library(colorspace)

if (!"RCurl" %in% installed.packages()) install.packages("RCurl")
library(RCurl)

if (!"gdata" %in% installed.packages()) install.packages("gdata")
library(gdata)

if (!"Unicode" %in% installed.packages()) install.packages("Unicode")
library(Unicode)


setwd("/home/st/ddgatve-stat/reports/")
source("school-utilities.R")

source("amo-report-helper.R")


chMun <- read.table(
  file="children-municipalities-2015-01-01.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

allChMun <- chMun[chMun$Category == "School.All", c("Location","Total")]

allChMun$Location <- 
  sapply(as.vector(allChMun$Location),strFromUnicode)

results41 <- getExtResults(41)
results42 <- getExtResults(42)
results41$UpperMunicipality <- 
  toupper(sapply(as.vector(results41$Municipality),strFromUnicode))
results42$UpperMunicipality <- 
  toupper(sapply(as.vector(results42$Municipality),strFromUnicode))


olympParticipation <- numeric()
olympCC <- numeric()
olympPP41 <- numeric()
olympPP42 <- numeric()

for (theLoc in allChMun$Location) {
  theChTotal <- allChMun$Total[allChMun$Location == theLoc]
  pp41 <- nrow(results41[results41$UpperMunicipality == theLoc,])
  pp42 <- nrow(results42[results42$UpperMunicipality == theLoc,])
  cc <- allChMun$Total[allChMun$Location == theLoc]*(8/11)
  olympParticipation <- c(olympParticipation, (pp42-pp41)/cc)
  olympCC <- c(olympCC,round(cc))
  olympPP41 <- c(olympPP41, pp41)
  olympPP42 <- c(olympPP42, pp42)
}

intensityFrame <- 
  data.frame(loc = allChMun$Location, 
             per = olympParticipation,
             cc = olympCC,
             pp41 = olympPP41,
             pp42 = olympPP42)

novFrame <- read.table(
  file="maps/lv-municipalities.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

## Standardize every municipality ID to 7 digits
novFrame$Classifier <- 
  sapply(novFrame$Classifier, function(arg) { sprintf("%07.0f",arg) })


mapSHP <-  readShapePoly(fn = "maps/Export_Output")
mapaDat <- as.data.frame(mapSHP)
mapaIDs <- as.numeric(rownames(mapaDat))

panel.str <- deparse(panel.polygonsplot, width=500)
panel.str <- sub("grid.polygon\\((.*)\\)",
  "grid.polygon(\\1, name=paste('ID', slot(pls\\[\\[i\\]\\], 'ID'\\), sep=':'))",
  panel.str)
panel.polygonNames <- eval(parse(text=panel.str),
                           envir=environment(panel.polygonsplot))



bigdata <- merge(mapaDat, novFrame, sort=FALSE, 
                 by.x="ATVK", by.y="Classifier")
biggerdata <- merge(bigdata,intensityFrame, sort=FALSE, 
                    by.x="UpperName", by.y="loc")
						   
n=7
# workaround - stretch the interval a little bit
theVector = c(min(biggerdata$per)*0.999,
              as.vector(biggerdata$per),max(biggerdata$per)*1.001)
int <- classIntervals(theVector, n, style='jenks')
pal <- brewer.pal(9, 'PRGn')[3:9]
#palWhite <- c("#ffffff", pal)
#brksWhite <- c(0, 0.000001,int$brks[-1])
# Possible palettes: Blues BuGn BuPu GnBu Greens Greys Oranges 
# OrRd PuBu PuBuGn PuRd Purples RdPu Reds YlGn 
# YlGnBu YlOrBr YlOrRd

Total <- biggerdata$per
mapSHP@data <- cbind(mapSHP@data, Total)
p <- spplot(mapSHP["Total"], panel=panel.polygonNames,
            col.regions=pal, at=int$brks)
p

## grobs in the graphical output
grobs <- grid.ls()
## only interested in those with "GRID." in the name
nms <- grobs$name[grobs$type == "grobListing"]
idxNames <- grep("GRID", nms)
IDs <- nms[idxNames]


theCount <- 1
for (id in unique(IDs)){
  dat <- biggerdata[which(bigdata$Grob==id),]
  info <-  paste0(dat$FullName, ": ", round(100*dat$per,2), "%")  
  g <- grid.get(id)
  
  thePP41 <- intensityFrame$pp41[intensityFrame$loc == dat$UpperName]
  thePP42 <- intensityFrame$pp42[intensityFrame$loc == dat$UpperName]
  theCC <- intensityFrame$cc[intensityFrame$loc == dat$UpperName]
  info2 <- sprintf("%1.0f&#8594;%1.0f no %1.0f",thePP41, thePP42, theCC)
  ## attach SVG attributes
  grid.garnish(id,
               onmouseover=paste("showTooltip(evt, '", info, "','",info2,"')"),
               onmouseout="hideTooltip()")
  theCount <- theCount + 1 
}

grid.script(filename="maps/tooltip.js")

grid.export("olympiad-participation-change.svg")
