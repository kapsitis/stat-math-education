if (!"haven" %in% installed.packages()) {
  install.packages("tidyverse")
}

library(haven)
library(ggplot2)
library(Cairo)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


df <- read_sav("Smekesana.sav")
df$Valoda <- as.factor(df$Valoda)
df$Dzimums <- as.factor(df$Dzimums)
df$Attiecibas <- as.factor(df$Attiecibas)
df$PastavigsDarbs <- as.factor(df$PastavigsDarbs)
df$VecakiSmeke <- as.factor(df$VecakiSmeke)
df$Smeke <- as.factor(df$Smeke)
df$SmekesanasDaudzums <- as.factor(df$SmekesanasDaudzums)
df$MeginajisAtmest <- as.factor(df$MeginajisAtmest)


#######################################################
## Question 1
#######################################################

p<-ggplot(data=df, aes(Dzimums)) +
  geom_bar() + 
  theme_bw() +
  xlab("Pazīmes 'Dzimums' vērtības") + 
  ylab("Rindu skaits") +
  scale_x_discrete("Pazīme Dzimums", labels = c("2" = "Sievietes","4" = "Vīrieši")) +
  theme(axis.text.x = element_text(face="bold", color="#993333", 
                                   size=14, angle=0))

Cairo(file="question1.png", 
      type="png",
      units="in", 
      width=4,
      height=3, 
      pointsize=12*92/72, 
      dpi=96)
p
dev.off()


#######################################################
## Question 2
#######################################################
## https://www.isixsigma.com/tools-templates/hypothesis-testing/making-sense-mann-whitney-test-median-comparison/
## https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1120984/

fivenum(df$Vecums[df$Dzimums == 4])
fivenum(df$Vecums[df$Dzimums == 2])


#dataset$Valoda <- sapply(dataset$Valoda,function(x){return(ifelse(x == "Krievu", 2, 3))})



# Unused approach to read SPSS files
# library("memisc")
#df <- data.frame(as.data.set(spss.system.file("Smekesana.sav")))


