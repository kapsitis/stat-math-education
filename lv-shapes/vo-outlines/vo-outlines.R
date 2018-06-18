# divas bibliotēkas, lai strādātu ar SHP failiem
require(maptools)
require(sp)
# lai ērtāk sadalīt vektoru vairākos intervālos (mūsu gadījumā 11 intervāli)
require(classInt)
require(RColorBrewer)

# https://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# https://gis.stackexchange.com/questions/63577/joining-polygons-in-r?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
require(rgdal)
require(gridExtra)


## visas instalē, 
## plus arī install.package("rgeos")



# Uzstāda to direktoriju, kuraa ir visi R skripti un CSV faili
# "C:/" neraksta; lieto parastas daļsvītras, nevis apgrieztās (\)
setwd("/Users/kalvi/workspace/schoolmap/lv-shapes/vo-outlines")




# nolasa CSV failu kā data.frame
vpd <- read.table(
  file="Pasvaldibas_pec_VPD.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

# saskaita, cik pavisam iedzīvotāju ir katrā novadā (visi statusi)
totalCount <- 
  aggregate(Kopa ~ Novads,
            data = vpd,
            FUN=sum)

# izfiltrē katram novadam nepilsoņu rindiņu
noncitCount <- 
  vpd[vpd$Statuss == "LATVIJAS NEPILSONIS",]


# apvieno vienā tabuliņā visus iedzīvotājus un nepilsoņus vienam novadam
# atbilstošos ierakstus atrod pēc kopīgās kolonnas "Novads"
noncitMain <- merge(totalCount, noncitCount, 
                    by="Novads")

# atrod nepilsoņu īpatsvaru procentos
noncitMain$Frac <- 
  round(100*noncitMain$Kopa.y/noncitMain$Kopa.x,digits=2)

# Ja vēlas, var sakārtot pašvaldības nepilsoņu īpatsvaru dilšanas secībā
#noncitOrdered <- noncitMain[with(noncitMain, order(-Frac, Novads)), ]

# Nokopē data.frame kolonnu kā vektoru, 
# bet nevelk līdzi "factor levels", kas bija data.frame
fixedNovads <- as.vector(noncitMain$Novads)
# Atbrīvojas no diakritiskajām zīmītēm: Č, Š, Ž
fixedNovads[grepl("ADA.U NOVADS",fixedNovads)] <- "ADAZU NOVADS"
fixedNovads[grepl("IK.KILES NOVADS",fixedNovads)] <- "IKSKILES NOVADS"
fixedNovads[grepl("LIMBA.U NOVADS",fixedNovads)] <- "LIMBAZU NOVADS"
fixedNovads[grepl("NAUK.ENU NOVADS",fixedNovads)] <- "NAUKSENU NOVADS"
fixedNovads[grepl("ROPA.U NOVADS",fixedNovads)] <- "ROPAZU NOVADS"

# Izveido attīrītu data.frame, kur ir tikai 
# novadu nosaukumi (bez diakritiskajām zīmītēm) un nepilsoņu procenti
noncitFrame <- data.frame(loc=fixedNovads, per = noncitMain$Frac)



novFrame <- read.table(
  file="lv-municipalities.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8", colClasses=c("character","character","character","character"))


mapSHP <-  readShapePoly(fn = "../shape-data/Export_Output")
mapaDat <- as.data.frame(mapSHP)

panel.str <- deparse(panel.polygonsplot, width=500)
panel.str <- sub("grid.polygon\\((.*)\\)",
                 "grid.polygon(\\1, name=paste('ID', slot(pls\\[\\[i\\]\\], 'ID'\\), sep=':'))",
                 panel.str)
panel.polygonNames <- eval(parse(text=panel.str),
                           envir=environment(panel.polygonsplot))

bigdata <- merge(mapaDat, novFrame, sort=FALSE, 
                 by.x="ATVK", by.y="Classifier")

biggerdata <- merge(bigdata,noncitFrame, sort=FALSE, 
                    by.x="UpperName", by.y="loc")

n <- 11
# workaround - stretch the interval a little bit
theVector <- c(min(biggerdata$per)*0.999,
               as.vector(biggerdata$per),max(biggerdata$per)*1.001)
int <- classIntervals(theVector, n, style='jenks')
pal <- rev(brewer.pal(n, "Spectral"))

Total <- biggerdata$per
mapSHP@data <- cbind(mapSHP@data, Total)


#####
OlympiadRegion <- as.character(biggerdata$OlympiadRegion)
mapSHP@data <- cbind(mapSHP@data, OlympiadRegion)

mapSHP.union <- unionSpatialPolygons(mapSHP, mapSHP@data$OlympiadRegion)


png("vo-outlines.png", width=720, height=440)
par(mar=c(0.1,0.1,0.1,0.1))
plot(mapSHP, border = "gray60", lwd = 1)
plot(mapSHP.union, add = TRUE, border = "red3", lwd = 2)
dev.off()

