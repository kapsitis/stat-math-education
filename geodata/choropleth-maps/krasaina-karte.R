# Darba direktorija ir tekošā (kur atrodas dotais R scenārijs)
# Var aizstāt arī ar absolūto ceļu: setwd("c:/Users/username/.../subdirectory")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# nolasa CSV failu kā data.frame
skoleni <- read.table(
  file="school-data/vo_results_2018.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

skoleni <- skoleni[skoleni$Summa!="n",]

# nolasa CSV failu kā data.frame
skolaPasvaldiba <- read.table(
  file="skola-pasvaldiba.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

skoleniExt <- merge(skoleni, skolaPasvaldiba, 
                    by.x="Skola", by.y="School", all.x=TRUE)

lvMunicipalities <- read.table(
  file="lv-municipalities.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8", 
  colClasses=c("character","character","character","character"))

lvMunicipalitiesReduced <- lvMunicipalities[,c("AsciiName","OlympiadRegion")]

asciiNovads <- as.vector(skoleniExt$Municipality)
asciiNovads[grepl("Ada.u novads",asciiNovads)] <- "Adazu novads"
asciiNovads[grepl("Ik.kiles novads",asciiNovads)] <- "Ikskiles novads"
asciiNovads[grepl("Limba.u novads",asciiNovads)] <- "Limbazu novads"
asciiNovads[grepl("Nauk.enu novads",asciiNovads)] <- "Nauksenu novads"
asciiNovads[grepl("Ropa.u novads",asciiNovads)] <- "Ropazu novads"

skoleniExt <- cbind(skoleniExt,asciiNovads)

skoleniExt <- merge(skoleniExt, lvMunicipalitiesReduced, 
                    by.x="asciiNovads", by.y="AsciiName", all.x=TRUE)

numSumma <- as.numeric(skoleniExt$Summa)
skoleniExt <- cbind(skoleniExt,numSumma)


# saskaita, cik pavisam iedzīvotāju ir katrā novadā (visi statusi)
totalCount <- 
  aggregate(numSumma ~ OlympiadRegion,
            data = skoleniExt,
            FUN=mean)



# divas bibliotēkas, lai strādātu ar SHP failiem
require(maptools)
require(sp)
# lai ērtāk sadalīt vektoru vairākos intervālos (mūsu gadījumā 11 intervāli)
require(classInt)
require(RColorBrewer)

# https://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# https://gis.stackexchange.com/questions/63577/joining-polygons-in-r?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
require(rgdal)
require(maptools)
require(gridExtra)

# novFrame <- read.table(
#   file="lv-municipalities.csv", 
#   sep=",",
#   header=TRUE,
#   row.names=NULL,  
#   fileEncoding="UTF-8", colClasses=c("character","character","character","character"))


#mapSHP <-  readShapePoly(fn = "shape-data/Export_Output")
mapSHP <- readOGR(dsn = "shape-data/Export_Output.shp")
#mapaDat <- as.data.frame(mapSHP)

# Try to fix gpclibPermitStatus() - it should be TRUE
if (!require(gpclib)) install.packages("gpclib", type="source")
gpclibPermit()


bigdata <- merge(mapSHP@data, lvMunicipalities, sort=FALSE, 
    by.x="ATVK", by.y="Classifier")


OlympiadRegion <- as.character(bigdata$OlympiadRegion)
mapSHP@data <- cbind(mapSHP@data, OlympiadRegion)
mapSHP.union <- unionSpatialPolygons(mapSHP, mapSHP@data$OlympiadRegion)



row.names(totalCount) <- as.character(totalCount$OlympiadRegion)

#######################################################################
## mapSHP.union has 39 Polygons objects, but totalCount has 26 rows
#######################################################################
mapSHP.agg <- SpatialPolygonsDataFrame(mapSHP.union, totalCount)


panel.str <- deparse(panel.polygonsplot, width=500)
panel.str <- sub("grid.polygon\\((.*)\\)",
                 "grid.polygon(\\1, name=paste('ID', slot(pls\\[\\[i\\]\\], 'ID'\\), sep=':'))",
                 panel.str)
panel.polygonNames <- eval(parse(text=panel.str),
                           envir=environment(panel.polygonsplot))

# bigdata <- merge(mapaDat, novFrame, sort=FALSE, 
#                  by.x="ATVK", by.y="Classifier")

#biggerdata <- merge(bigdata,noncitFrame, sort=FALSE, 
#                    by.x="UpperName", by.y="loc")

n <- 11
# workaround - stretch the interval a little bit
theVector <- c(min(totalCount$numSumma)*0.999,
               as.vector(totalCount$numSumma),max(totalCount$numSumma)*1.001)
int <- classIntervals(theVector, n, style='jenks')
pal <- rev(brewer.pal(n, "Spectral"))

#Total <- totalCount$numSumma
#mapSHP@data <- cbind(mapSHP@data, Total)


#####
## Tikai kontūras?
#########

png("overlay.png", width=720, height=440)
par(mar=c(0.1,0.1,0.1,0.1))
plot(mapSHP, border = "gray60", lwd = 1)
plot(mapSHP.union, add = TRUE, border = "red3", lwd = 2)
dev.off()





png("overlay2.png", width=720, height=440)
par(mar=c(0.1,0.1,0.1,0.1))
spplot(mapSHP.agg["numSumma"], panel=panel.polygonNames,
            col.regions=pal, at=int$brks)
dev.off()

