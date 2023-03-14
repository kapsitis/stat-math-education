require(plyr)
require(Unicode)

source("school-utilities.R")

#schoolLanguageList <- getSchoolLanguageList()

skoleniALL = read.table(
  file="vs-apmac-val_all-2014.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")[1:14,]

skoleniALL$Region6 = c("Kurzeme","Latgale","Pierīga","Vidzeme","Zemgale",
                       "Zemgale","Vidzeme","Latgale","Zemgale",
                       "Pierīga","Kurzeme","Latgale","Kurzeme","Rīga")

xx <- aggregate(. ~ Region6, data=skoleniALL, FUN=sum)


skolaPasvaldiba <- read.table(
  file="skola-pasvaldiba.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

sp <- list()
for(i in 1:length(skolaPasvaldiba$School)) {
  aa <- as.vector(skolaPasvaldiba$School[i])
  bb <- as.vector(skolaPasvaldiba$Municipality[i])
  sp[[aa]] <- bb
}


pasvaldibas <- read.table(
  file="pasvaldibas.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")



pr <- list()
pr14 <- list()
for(i in 1:length(pasvaldibas$Municipality)) {
  aa <- as.vector(pasvaldibas$Municipality[i])
  bb <- as.vector(pasvaldibas$Region6[i])
  cc <- as.vector(pasvaldibas$Region14[i])
  pr[[aa]] <- bb
  pr14[[aa]] <- cc
}


getMunicipality <- function(school) {
  if (!(school %in% names(sp))) {
    spacedSchool <- gsub("\\.", ". ", school)
    if (!(spacedSchool %in% names(sp))) {
      return("NNN")
    } else {
      return(sp[[spacedSchool]])
    }  
  } else {
    return(sp[[school]])
  }
}

getRegion <- function(theMunicipality) {
  theRegion <- pr[[theMunicipality]]
  return(theRegion)
}

getRegion14 <- function(theMunicipality) {
  theRegion14 <- pr14[[theMunicipality]]
  return(theRegion14)
}


# results <- read.table(
#   file="results-10kl.csv", 
#   sep=",",
#   header=TRUE,
#   row.names=NULL,  
#   fileEncoding="UTF-8")

library(stringr)
getMinutes <- function(arg) {
  if (!grepl("^[0-9][0-9]:[0-9][0-9]$",arg)) {
    return(NA)
  } else {
    hour <- as.numeric(gsub(":[0-9][0-9]","",arg))
    minute <- as.numeric(gsub("[0-9][0-9]:","",arg))
    return(60*hour + minute - 630)
  }
}

getMinuteString <- function(grade, threshold, results) {
  return(results$Minutes[which(results$Grade == grade & 
                          results$Summa >= threshold & 
                          !is.na(results$Minutes))])
}

getExtResults <- function(amoNum) {
  results <- getResultTables(amoNum)
  
  dzimums <- sapply(as.vector(results$Vards), getGender)
  results$Dzimums <- dzimums
  
  municipalities <- as.vector(sapply(as.vector(results$Skola), getMunicipality))
  regions <- as.vector(sapply(municipalities,getRegion))
  regions14 <- as.vector(sapply(municipalities,getRegion14))
  
  results$Municipality <- municipalities
  results$Region6 <- regions
  results$Region14 <- regions14
  
  
  
  # skolasLV <- getSchoolsForLanguage("L")
  # skolasRU <- getSchoolsForLanguage("K")
  languages <- character(0) 
  
  for (i in 1:nrow(results)) {
    theSchool <- results$Skola[i]
    theTeacher <- results$Skolotaji[i]
    if (theTeacher == "") {
      theTeacher <- "NA"
    }
    theLanguage <- getLang(theSchool,theTeacher)
    languages <- c(languages,theLanguage)
    #  print(sprintf("%d - %d",i,length(languages)))
  }
  
  results$Language <- languages
  results$Minutes <- as.vector(sapply(results$Darbu.nodeva, getMinutes))
  
  return(results)
}

results <- getExtResults(42)

getAllPupils <- function(year) {
  result <- read.table(
    file=sprintf("vs-apmac-val_all-%d.csv",year), 
    sep=",",
    header=TRUE,
    row.names=NULL,  
    fileEncoding="UTF-8")
  return(result[1:14,])
}


getNumTeachers <- function(results) {
  allTeachers <- character(0)
  numTeachers <- numeric(0)
  teacherList <- strsplit(as.vector(results$Skolotaji),"[;,] +")
  for (tt in 1:length(teacherList)) {
    #  allTeachers <- c(allTeachers,teacherList[[tt]])
    numTeachers <- c(numTeachers,length(teacherList[[tt]]))
  }
  return(numTeachers)
}

getUpperQuartiles <- function(results) {
  upperQuartiles <- numeric(0)
  for (theGrade in 5:12) {
    upperQuartiles <- c(upperQuartiles,
                        fivenum(results$Summa[results$Grade == theGrade])[4])
  }
  return(upperQuartiles)
}


replaceUnicode <- function(arg) {
  arg <- gsub("\u0100","A",arg)
  arg <- gsub("\u010C","C",arg)
  arg <- gsub("\u0112","E",arg)
  arg <- gsub("\u0122","G",arg)
  arg <- gsub("\u012A","I",arg)
  arg <- gsub("\u0136","K",arg)
  arg <- gsub("\u013B","L",arg)
  arg <- gsub("\u0145","N",arg)
  arg <- gsub("\u0160","S",arg)
  arg <- gsub("\u016A","U",arg)
  arg <- gsub("\u017D","Z",arg)
  
  
  arg <- gsub("\u0101","a",arg)
  arg <- gsub("\u010D","c",arg)
  arg <- gsub("\u0113","e",arg)
  arg <- gsub("\u01E7","g",arg)
  arg <- gsub("\u012B","i",arg)
  arg <- gsub("\u0137","k",arg)
  arg <- gsub("\u013C","l",arg)
  arg <- gsub("\u0146","n",arg)
  arg <- gsub("\u0161","s",arg)
  arg <- gsub("\u016B","u",arg)
  arg <- gsub("\u017E","z",arg)
  return(arg)
}


letterFromUnicode <- function(arg) {
  if (arg == "\u0100") return("A")
  if (arg == "\u010C") return("C")
  if (arg == "\u0112") return("E")
  if (arg == "\u0122") return("G")
  if (arg == "\u012A") return("I")
  if (arg == "\u0136") return("K")
  if (arg == "\u013B") return("L")
  if (arg == "\u0145") return("N")
  if (arg == "\u0160") return("S")
  if (arg == "\u016A") return("U")
  if (arg == "\u017D") return("Z")  
  if (arg == "\u0101") return("a")
  if (arg == "\u010D") return("c")
  if (arg == "\u0113") return("e")
  if (arg == "\u01E7") return("g")
  if (arg == "\u012B") return("i")
  if (arg == "\u0137") return("k")
  if (arg == "\u013C") return("l")
  if (arg == "\u0146") return("n")
  if (arg == "\u0161") return("s")
  if (arg == "\u016B") return("u")
  if (arg == "\u017E") return("z")
  return(arg)
}

strFromUnicode <- function(arg) {
  xx <- as.vector(strsplit(arg,"")[[1]])
  yy <- as.vector(sapply(xx, letterFromUnicode))
  return(paste(yy,sep="",collapse=""))
}

getSkoloFrame <- function() {
  allGuys <- list()
  goodGuys <- list()
  allPoints <- list()
  allSchools <- list()
  
  # Where start the upper quartiles for each class 5 to 12
  upperQuartiles <- getUpperQuartiles(results)
  
  for (skNum in 1:nrow(results)) {
    theSks <- as.vector(strsplit(as.character(results[skNum,5]),"[;,] +"))
    theGrade <- as.numeric(results[skNum,"Grade"])
    for (theSk in theSks[[1]]) {
      if (theSk %in% names(allGuys)) {
        allGuys[[theSk]] <- allGuys[[theSk]] + 1
        allPoints[[theSk]] <- 
          allPoints[[theSk]] + as.numeric(results[skNum,"Summa"])
        goodGuys[[theSk]] <- goodGuys[[theSk]] + (as.numeric(results[skNum,"Summa"]) > 
                                                    upperQuartiles[theGrade -4])        
      } else {
        allGuys[[theSk]] <- 1
        allPoints[[theSk]] <-  as.numeric(results[skNum,"Summa"])
        goodGuys[[theSk]] <- as.numeric(as.numeric(results[skNum,"Summa"]) > 
                                          upperQuartiles[theGrade -4])
        allSchools[[theSk]] <- as.character(results[skNum,4])
      }
    }
    
  }
  
  sNames <- as.vector(names(allGuys))
  sParticipants <- sapply(sNames,function(name) {as.numeric(allGuys[[name]])})
  sPoints <- sapply(sNames,function(name) {as.numeric(allPoints[[name]])})
  sQ3 <- sapply(sNames,function(name) {as.numeric(goodGuys[[name]])})
  sSchools <- sapply(sNames, function(name) {as.character(allSchools[[name]])})
  
  skoloFrame <- data.frame(    
    Name = as.vector(sapply(sNames, replaceUnicode)), 
    Participants = as.vector(sParticipants),                            
    Q3 = as.vector(sQ3),
    Points = as.vector(sPoints),
    School = as.vector(sapply(sSchools, replaceUnicode)))
  
  return(skoloFrame)
}


getLookingGlass <- function() {
  # Pupils per teacher
  LGTeachers <- numeric(0)
  for (i in 1:2400) {
    LGTeachers <- c(LGTeachers, sample(0:100, size=1))
  }
  
  # Olympians per teacher
  LGTeachOlymp <- numeric()
  for (i in 1:2400) {
    LGTeachOlymp <- c(LGTeachOlymp,sum(runif(LGTeachers[i])<=0.02)) 
  }
  
  # Random results for olympians
  LGTeachResults <- list()
  for (i in 1:2400) {
    theRes <- rep(0,LGTeachOlymp[i])
    if (LGTeachOlymp[i] > 0) {
      for (j in 1:LGTeachOlymp[i]) {
        trunkNormal <- -1
        while (trunkNormal < 0 | trunkNormal > 50) {
          trunkNormal <- rnorm(1,mean=15,sd=10)
        }
        theRes[j] <- trunkNormal
      }
    }
    LGTeachResults[[i]] <- theRes
  }
  
  LGQ3 <- numeric()
  LGPoints <- numeric()
  LGcutOffScore <- qnorm(0.75, mean=15, sd=10)
  for (i in 1:2400) {
    LGQ3 <- c(LGQ3, sum(LGTeachResults[[i]] > LGcutOffScore))
    LGPoints <- c(LGPoints,sum(LGTeachResults[[i]]))
  }
  
  theResult <- list()
  theResult[["LGParticipants"]] <- LGTeachOlymp[LGTeachOlymp > 0]
  theResult[["LGQ3"]] <- LGQ3[LGTeachOlymp > 0]
  theResult[["LGPoints"]] <- LGPoints[LGTeachOlymp > 0]
  return(theResult)
}



