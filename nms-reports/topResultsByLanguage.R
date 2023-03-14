setwd("/home/st/ddgatve-stat/reports/")

source("school-utilities.R")
source("amo-report-helper.R")

# listInit <- function(tensBySch, tensByLang, tensByMun, tensByGend, 
#                      sch, lang, mun, gend) {
#   if (!sch %in% names(tensBySch)) {
#     tensBySch[[sch]] <- 0
#   }
#   if (!lang %in% names(tensByLang)) {
#     tensByLang[[lang]] <- 0
#   }
#   if (!mun %in% names(tensByMun)) {
#     tensByMun[[mun]]  <- 0
#   }
#   if (!gend %in% names(tensByGend)) {
#     tensByGend[[gend]] <- 0
#   }
#   
# }


results <- getExtResults(41)

getMaxPointLists <- function(grades) { 
  tensBySch <- list()
  tensByLang <- list()
  tensByMun <- list()
  tensByGend <- list()
  
  for(i in 1:nrow(results)) {
    #  print(paste0("i=",i))
    sch <- as.character(results[i,"Skola"])
    lang <- as.character(results[i,"Language"])
    mun <- as.character(results[i,"Municipality"])
    gend <- as.character(results[i,"Dzimums"])
    
    for (j in 1:5) {
      cName <- paste0("Uzd",j)
      if (results[i,cName] == 10 & results[i,"Grade"] %in% grades) {
        
        
        if (!sch %in% names(tensBySch)) {
          tensBySch[[sch]] <- 0
        }
        if (!lang %in% names(tensByLang)) {
          tensByLang[[lang]] <- 0
        }
        if (!mun %in% names(tensByMun)) {
          tensByMun[[mun]]  <- 0
        }
        if (!gend %in% names(tensByGend)) {
          tensByGend[[gend]] <- 0
        }
        
        tensBySch[[sch]] <- tensBySch[[sch]] + 1
        tensByLang[[lang]] <- tensByLang[[lang]] + 1
        tensByMun[[mun]] <-  tensByMun[[mun]] + 1
        tensByGend[[gend]] <- tensByGend[[gend]] + 1
      }
    }
  }
  return(list(tbs = tensBySch, 
              tbl = tensByLang,
              tbm = tensByMun,
              tbg = tensByGend))
}


grades <- c(5:12)
maxPointLists <- getMaxPointLists(grades)

tensByLang = maxPointLists$tbl
langParticip <- table(results$Language[results$Grade %in% grades])[c("L","K")]
langTens <- sapply(c("L","K"), function(arg) {tensByLang[[arg]]})

barplot(
  height=langTens/langParticip,
  width=langParticip,
  col=c("darkgreen","red"), 
  names.arg=sprintf(c("Latvian\n%s","Russian\n%s"),langParticip), 
  ylab="Max-scores/participants",
  space=0, main="10-point Scores in a Single Paper (by Language)")


lvMaxShare <- numeric(0)
ruMaxShare <- numeric(0)
for (ii in 5:12) {
  grades <- ii
  maxPointLists <- getMaxPointLists(grades)
  tensByLang = maxPointLists$tbl
  langParticip <- 
    table(results$Language[results$Grade %in% grades])[c("L","K")]
  langTens <- sapply(c("L","K"), function(arg) {tensByLang[[arg]]})
  lvMaxShare <- c(lvMaxShare,(langTens/langParticip)[1])
  ruMaxShare <- c(ruMaxShare,(langTens/langParticip)[2])
  
}

plot(5:12, 
     lvMaxShare, 
     ylab="Max-scores/Participants",
     xlab="Grade",
     main="Max-scores per Grade and Language",
     type="o", 
     col="darkgreen", 
     lwd=2, 
     ylim=c(0,max(ruMaxShare)))

points(5:12, 
       ruMaxShare, 
       type="o", 
       col="red", 
       lwd=2, 
       ylim=c(0,max(maleMaxShare)))
grid(col="black")


