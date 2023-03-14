#setwd("/home/st/ddgatve-stat/reports/")
setwd("/Users/kapsitis/workspace/ddgatve-stat/reports/")

# sal <- read.table(
#   file="skolotaju-algas-large.csv",
#   sep=",",
#   header=TRUE,
#   row.names=NULL,
#   fileEncoding="UTF-8")
#
# sal <- sal[sal$Alga > 0,]
#
# nrow(sal[sal$Alga < 420,])/nrow(sal)
# nrow(sal[sal$Alga >= 420 & sal$Alga < 600,])/nrow(sal)
# nrow(sal[sal$Alga >= 600 & sal$Alga < 800,])/nrow(sal)
# nrow(sal[sal$Alga >= 800 & sal$Alga < 1000,])/nrow(sal)
# nrow(sal[sal$Alga >= 1000 & sal$Alga < 1200,])/nrow(sal)
# nrow(sal[sal$Alga >= 1200,])/nrow(sal)


library(knitr)
source("school-utilities.R")
source("amo-report-helper.R")

knit("amo41-report.Rnw")
#knit("amo-report-notes.Rnw")
