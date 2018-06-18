# divas bibliotēkas, lai strādātu ar SHP failiem
require(maptools)
require(sp)
# lai ērtāk sadalīt vektoru vairākos intervālos
require(classInt)
require(RColorBrewer)

# https://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# https://gis.stackexchange.com/questions/63577/joining-polygons-in-r?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
require(rgdal)
require(rgeos)
require(lattice)
require(maptools)
require(gridExtra)


setwd("c:/Users/kalvi/workspace/schoolmap/lv-shapes/vo-colored-regions")

# nolasa CSV failu kā data.frame
skoleniExt <- read.table(
  file="skola-pasvaldiba.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")


lvMunicipalities <- read.table(
  file="lv-municipalities.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8", 
  colClasses=c("character","character","character","character"))

lvMunicipalitiesReduced <- lvMunicipalities[,c("AsciiName","OlympiadRegion")]


## Replace modified Latin letters by regular Latin/ASCII letters. 
## (They are read from the CSV files incorrectly).
## This affects only the letters "Č", "Š", "Ž".
asciiNovads <- as.vector(skoleniExt$Municipality)
asciiNovads[grepl("Ada.u novads",asciiNovads)] <- "Adazu novads"
asciiNovads[grepl("Ik.kiles novads",asciiNovads)] <- "Ikskiles novads"
asciiNovads[grepl("Limba.u novads",asciiNovads)] <- "Limbazu novads"
asciiNovads[grepl("Nauk.enu novads",asciiNovads)] <- "Nauksenu novads"
asciiNovads[grepl("Ropa.u novads",asciiNovads)] <- "Ropazu novads"

skoleniExt <- cbind(skoleniExt,asciiNovads)

skoleniExt <- merge(skoleniExt, lvMunicipalitiesReduced, 
                    by.x="asciiNovads", by.y="AsciiName", all.x=TRUE)

skoleniExt$numSumma <- rep(1,nrow(skoleniExt))


totalCount <- 
 aggregate(numSumma ~ OlympiadRegion,
      data = skoleniExt,
        FUN=sum)
 

mapSHP <- readOGR(dsn = "../shape-data/Export_Output.shp")

panel.str <- deparse(panel.polygonsplot, width=500)
panel.str <- sub("grid.polygon\\((.*)\\)",
                 "grid.polygon(\\1, name=paste('ID', slot(pls\\[\\[i\\]\\], 'ID'\\), sep=':'))",
                 panel.str)
panel.polygonNames <- eval(parse(text=panel.str),
                           envir=environment(panel.polygonsplot))


bigdata <- merge(mapSHP@data, lvMunicipalities, sort=FALSE, 
    by.x="ATVK", by.y="Classifier")


OlympiadRegion <- as.character(bigdata$OlympiadRegion)
mapSHP@data <- cbind(mapSHP@data, OlympiadRegion)
mapSHP.union <- unionSpatialPolygons(mapSHP, mapSHP@data$OlympiadRegion)



row.names(totalCount) <- as.character(totalCount$OlympiadRegion)
mapSHP.agg <- SpatialPolygonsDataFrame(mapSHP.union, totalCount)


###################################
## PICK COLOR PALETTE
###################################
# Color palettes for maps:
# https://color.adobe.com/explore/?filter=most-popular&time=month

# Uncomment just one "pal" variable

# "Spectral" - 7 colors
# pal <- rev(brewer.pal(7, "Spectral"))
# "Dark2" - 7 colors
# pal <- brewer.pal(7, "Dark2")
# "Zodiaco 1" - 5 colors
pal <- c("#FF5353","#A972E8","#63BFFF","#62E88E","#FBFF5F")
# "Pastel Rainbow" - 5 colors
# pal <- c("#A8E6CF", "#DCEDC1", "#FFD3B6","#FFAAA5","#FF8B94")
# "Saturated" - 5 colors
# pal <- c("#6F80FF","#65E88D","#FFE67C","#E89D98","#AAA4FF")
# "Muted Disco Rainbow" - 5 colors
# pal <- c("#E94128","#F18229","#EDD569","#458955","#3F628F")
# "Capture 1" - 5 colors
# pal <- c("#FFB6C1","#87CEFA","#90EE90","#FFFF99","#FFFFFF")
# "Starbrusht" - 5 colors
# pal <- c("#FF225A","#6713E8","#22A6FF","#13E864","#D9FF24")


# n - total number of colors
# The number n should be at least 5. Not sure if 4-color theorem applies
# since some regions are disjoint.
n <- length(pal)



###################################################################
### WE WANT TO COLOR BORDERING REGIONS DIFFERENTLY
###################################################################

# Compute 39x39 matrix that contains value a_ij = TRUE,
# if and only if i-th and j-th regions are different, but
# have some common border. 
borderMatrix <- rgeos::gTouches(mapSHP.agg, byid=TRUE)


# The meaning of function "sample" is counter-intuitive, if 
# vector is of length 1, so we re-define it.
resample <- function(x, ...) x[sample.int(length(x), ...)]

colorColision <- TRUE
theSeed <- 0
while (colorColision) {
  theSeed <- theSeed + 1
  set.seed(theSeed)
    
  colorColision <- FALSE
  
  theHash <- numeric(0)
  for (i in 1:nrow(mapSHP.agg@data)) {
    cc <- mapSHP.agg@data$OlympiadRegion[i]
    allColors <- 1:n
    if (i > 1) {
      neighbors <- which(borderMatrix[cc,])
      badColors <- theHash[neighbors]
      allColors <- setdiff(allColors,badColors)
      if (length(allColors) == 0) {
        print(sprintf("ERROR: Cannot assign color for %s, seed=%d",cc, theSeed))
        allColors <- 1:n
        colorColision <- TRUE
      }
    }
    myColor <- resample(allColors,size=1)
    
    theHash <- c(theHash,myColor)
  }
}


#####################################################
### PREPARE TO DRAW THE POLYGONS
#####################################################


mapSHP.agg@data <- cbind(mapSHP.agg@data, theHash)

# workaround - stretch the interval a little bit
theVector <- c(min(mapSHP.agg@data$theHash)*0.999,
               as.vector(mapSHP.agg@data$theHash),max(mapSHP.agg@data$theHash)*1.001)
#int <- classIntervals(theVector, n, style='jenks')



regionCenters <- SpatialPointsDataFrame(gCentroid(mapSHP.agg, byid=TRUE), 
                                      mapSHP.agg@data, match.ID=FALSE)

# (Marupe, Baldone, Ropazi), (Garkalne, Sigulda), (Livani, Ilukste)
disjoint.coord = data.frame(
  name='DisjointRegions', 
  x=c(500000, 520000, 536000, 528000, 545000, 640000, 640000),
  y=c(306000, 290000, 310000, 322000, 322000, 220000, 240000)
)
coordinates(disjoint.coord) = c('x', 'y')



# Each color 1:n falls in some interval with both ends among "breaks"
breaks <- (0:n)+0.5

# Open a device to output a PNG file
png("vo-colored-regions.png", width=720, height=440)

# Define white margins around the image
par(mar=c(0.1,0.1,0.1,0.1))
# remove the rectangular border around the map
trellis.par.set(axis.line=list(col=NA)) 
spplot(mapSHP.agg["theHash"], panel=panel.polygonNames,
       sp.layout = c('sp.points', disjoint.coord, 
                     col="white", pch=16, cex=1.5),
            col.regions=pal, at=breaks, colorkey=FALSE)
# Close the output device = save the file

dev.off()

