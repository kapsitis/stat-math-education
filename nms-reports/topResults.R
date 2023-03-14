


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

tensByGend = maxPointLists$tbg
gendParticip <- table(results$Dzimums[results$Grade %in% grades])[c("Male","Female")]
gendTens <- sapply(c("Male","Female"), function(arg) {tensByGend[[arg]]})

barplot(
  height=gendTens/gendParticip,
  width=gendParticip,
  col=c("darkblue","darkred"), 
  names.arg=sprintf(c("Males\n%s","Females\n%s"),gendParticip), 
  ylab="Max-scores/participants",
  space=0, main="10-point Scores in a Single Paper (by Gender)")


maleMaxShare <- numeric(0)
femaleMaxShare <- numeric(0)
for (ii in 5:12) {
  grades <- ii
  maxPointLists <- getMaxPointLists(grades)
  tensByGend = maxPointLists$tbg
  gendParticip <- 
    table(results$Dzimums[results$Grade %in% grades])[c("Male","Female")]
  gendTens <- sapply(c("Male","Female"), function(arg) {tensByGend[[arg]]})
  maleMaxShare <- c(maleMaxShare,(gendTens/gendParticip)[1])
  femaleMaxShare <- c(femaleMaxShare,(gendTens/gendParticip)[2])
  
}

plot(5:12, 
     maleMaxShare, 
     ylab="Max-scores/Participants",
     xlab="Grade",
     main="Max-scores per Grade and Gender",
     type="o", 
     col="darkblue", 
     lwd=2, 
     ylim=c(0,max(maleMaxShare)))

points(5:12, 
     femaleMaxShare, 
     type="o", 
     col="darkred", 
     lwd=2, 
     ylim=c(0,max(maleMaxShare)))
grid(col="black")

