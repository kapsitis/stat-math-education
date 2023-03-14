# http://ritvars.wordpress.com/2013/01/10/tautibas-latvija-izvietojums/ -- diagrammas paraugs

# http://gislounge.com/making-maps-with-r/
# http://spatialanalysis.co.uk/2010/09/rmaps/
# http://geography.uoregon.edu/GeogR/examples/maps_examples01.htm

if (!"classInt" %in% installed.packages()) install.packages("classInt")
library(classInt)
if (!"grid" %in% installed.packages()) install.packages("grid")
library(grid)
if (!"gridBase" %in% installed.packages()) install.packages("gridBase")
library(gridBase)
if (!"maptools" %in% installed.packages()) install.packages("maptools")
library(maptools)
if (!"RColorBrewer" %in% installed.packages()) install.packages("RColorBrewer")
library(RColorBrewer)
if (!"RCurl" %in% installed.packages()) install.packages("RCurl")
library(RCurl)

setwd("/home/st/ddgatve-stat/reports/")

source("school-utilities.R")
source("amo41-report-helper.R")

#results <- getExtResults(41)

## READ THE SHAPEFILE FOR CITIES
# Modify this directory, if you store the shapefiles elsewhere
cities<- readShapePoints("maps/lielas_pilsetas.shp")
names(cities)

## DRAW CITIES AS GRAY CROSSES
old.par <- par(mar=c(5,4,4,0)+0.1)
plot(cities, col="white", lwd=2, axes=F)
#box()
title(paste ("Participants by Language in Cities"))

## DRAW OUTLINE
axx <- readShapeLines("maps/robezas_line.shp")
plot(axx, col="darkblue", lwd=1, add=TRUE)


# SET THE NAMES OF BIG CITIES AND THEIR INDICIES IN THE SHAPEFILE
bigCityNames <- c("Riga", "Daugavpils", "Jelgava", 
                  "Jekabpils", "Jurmala", "Liepaja", 
                  "Rezekne", "Valmiera", "Ventspils",
                  "Ogre","Tukums","Cesis")
bigMunicipalityNames <- c("Riga", "Daugavpils", "Jelgava", 
                          "Jekabpils", "Jurmala", "Liepaja", 
                          "Rezekne", "Valmiera", "Ventspils",
                          "Ogres novads",
                          "Tukuma novads",
                          "Cesu novads")

# Indices of the 9 big cities in the shapefile table
bigCities <- c(10,25,17,22,12,27,21,2,4,
               15,13,6)
# Extract coordinates of these 9 cities. 
cityLocations <- coordinates(cities[bigCities,])

## PREPARE THE DATA THAT WILL BE DISPLAYED IN DIAGRAMS
langAll <- as.vector(table(
  results$Municipality)[bigMunicipalityNames])
langLV <- as.vector(table(
  results$Municipality[results$Language=="L"])[bigMunicipalityNames])
langRU <- as.vector(table(
  results$Municipality[results$Language=="K"])[bigMunicipalityNames])

# langLV <- as.vector(table(
#   results$Municipality[results$Dzimums=="Male"])[bigMunicipalityNames])
# langRU <- as.vector(table(
#   results$Municipality[results$Dzimums=="Female"])[bigMunicipalityNames])

langLV[is.na(langLV)] <- 0
langRU[is.na(langRU)] <- 0

#langOther <- langAll - langLV - langRU

# PREPARE TO DRAW PIE-CHARTS
oldpar <- par(no.readonly = TRUE)
vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)

# COMPUTE PIE-CHART SIZES
# city with 3000 inhabitants would look as a dot on the map
smallestCity <- 10
# the largest city is represented as a circle with a half-inch diameter
maxpiesize <- unit(1.00, "inches")
# all the other cities are represented on logarithmic scale from 0 to 0.5in
#totals <- log(langAll) - log(smallestCity)
totals <- sqrt(langAll)
sizemult <- totals/max(totals)

# SET THE COLORSCHEME
colorScheme <- c("darkgreen","red","gray")

# DRAW ALL 9 PIE-CHARTS
for (i in 1:length(bigCityNames)) {
  pushViewport(
    viewport(x = unit(cityLocations[i,1], "native"), 
             y = unit(cityLocations[i,2], "native"), 
             width = sizemult[i] * maxpiesize, 
             height = sizemult[i] * maxpiesize))
  par(plt = gridPLT(), new = TRUE)
  pie(c(langLV[i],langRU[i]), 
      radius = 1, labels = rep("", 2), col=colorScheme)
  popViewport()
}


# text(0,0,"Liepaja2",adj=4)
# text(0,-1,"Liepaja3",adj=4)


# RETURN TO THE ORIGINAL VIEWPORT
current.vpTree()
popViewport(3)
par(oldpar)

# DRAW SCALE-BAR, NORTH-ARROW AND LEGEND
# draw scale-bar with annotation (40km)
SpatialPolygonsRescale(layout.scale.bar(), offset= c(600000,6150000), scale= 50000, fill= c("transparent", "black"), plot.grid= F)
text(620000,6130000, "40km", cex= 1)
SpatialPolygonsRescale(layout.north.arrow(1), offset= c(350000,6450000), scale = 30000, plot.grid=F)
legend(x=400000, y=6200000, 
       legend=c("Latvie\u0161u", 
                "Krievu"), fill=colorScheme, bty="n")

par(old.par)
