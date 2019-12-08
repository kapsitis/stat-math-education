### 
# Scenaarijs, kas atrod vidusskolas, kuraas neviens nekaarto 
# fizikas, kjiimijas un biologijas eksaamenus
###

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
#setwd("c:/Users/kapsitis/WebstormProjects/schoolmap/visc2016-dati/")
# Ielasa VISC datus kaa dataframe
# Datus (!visi0_dati.xlsx) savaac no VISC maajaslapas:
# http://visc.gov.lv/vispizglitiba/eksameni/statistika/2016/
visiDati <- read.table(file = "!visi0_dati.csv",
                        header = TRUE, sep = ",", encoding = "UTF-8")

require(plyr)
# saskaita, cik katraa skolaa kaartoja katru priekshmetu
SkPr <- 
  ddply(visiDati, .(nosaukums, prieksmets), 
        summarize, 
        skoleni = length(prieksmets))

require(reshape2)
# paartaisa par matricu ar priekshmetu kolonnaam
mm <- dcast(SkPr, nosaukums ~ prieksmets, value.var="skoleni")
# saraksta nulles tur, kur nav neviena skoleena
mm[is.na(mm)] <- 0

# kur neviens nelika BIO, KIM, FIZ
skolas <- mm[mm$BIO == 0 & mm$KIM == 0 & mm$FIZ == 0,]

# pievieno skolu registracijas numurus
skoluDati <- read.table(file = "adreses_1516.csv",
                       header = TRUE, sep = ",", encoding = "UTF-8")
skoluDati <- skoluDati[,c("RegNr","Nosaukums")]
skolasReg <- merge(skolas, skoluDati, by.x = "nosaukums", by.y = "Nosaukums", all.x = TRUE)

# nav vispaarizgliitojosho skolu adresu sarakstaa
skolasReg$RegNr[is.na(skolasReg$RegNr)] <- "9999"

# No registraacijas numura atlasa 3. un 4. ciparu
skolasReg <- mutate(skolasReg, tips = substr(RegNr, 3, 4))
# Atlasa dienas vidusskolas(RegNr attieciigie cipari ir "13")
srf <- skolasReg[skolasReg$tips=="13",]

lines <- "<table><tr><td>&nbsp;</td><td>Skola</td><td>ANG</td><td>BIO</td><td>FIZ</td><td>FRA</td><td>KIM</td><td>KRV</td><td>LV9</td><td>MAT</td><td>VAC</td><td>VES</td><td>VLL</td></tr>"

for (i in 1:nrow(srf)) {
  lines <- c(lines, sprintf("<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>",
                            i, srf$nosaukums[i], srf$ANG[i], srf$BIO[i], 
                            srf$FIZ[i], srf$FRA[i], srf$KIM[i],srf$KRV[i],
                            srf$LV9[i],srf$MAT[i],srf$VAC[i],srf$VES[i],srf$VLL[i]))
}

lines <- c(lines,"<table>")

fileConn<-file("../skolas-bez-izveles-eksameniem.html", encoding="UTF-8")
writeLines(lines, fileConn, useBytes=TRUE)
close(fileConn)



