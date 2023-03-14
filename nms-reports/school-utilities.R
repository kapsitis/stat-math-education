## These functions are called to complement math olympiad data tables

## Given the firstname, return the gender of the person (Male/Female)
getGender <- function(name) {
  sex <- "Other"
  # extract first name (if there are multiple names)
  firstName <- sub("(^[^ ]+)( ([^ ]+))?", "\\1",name) 
  if (firstName == "Adam" |
        firstName == "Alexander" |
        firstName == "Aliaksandr" |
        firstName == "Andrey" |
        firstName == "Anton" |
        firstName == "Artem" |
        firstName == "Bruno" |
        firstName == "Čiro" |
        firstName == "Dmitry" |
        firstName == "Dmytro" |
        firstName == "Hugo" |
        firstName == "Ivo" |
        firstName == "Nikita" | 
        firstName == "Ņikita" |
        firstName == "Nikolay" |
        firstName =="Oleksandr" |
        firstName == "Oto" |        
        firstName == "Raivo" |
        firstName == "Uko" |
        firstName == "Vladimir") {
    sex <- "Male"
  } else if (firstName == "Nelli" | 
               firstName == "Fani" |
               firstName == "Romi") {
    sex <- "Female"
  } else if (length(grep("[sš]$", firstName)) > 0) {
    sex <- "Male"
  } else if (length(grep("[ae]$", firstName)) > 0) {
    sex <- "Female"
  } else {
    nch <- nchar(firstName)
    lst <- substr(firstName,nch,nch)
    if (lst == "š") {
      sex <- "Male"
#    } else if (as.u_char(utf8ToInt(lst)) == "U+009A") {
#      sex <- "Male"
    } else {      
#      print(paste0("***** Unidentified name:***** ",name))
      sex <- "Male"
    }
  }
  return(sex)
}


getSchoolLanguageList <- function() {
  filenames <- c("dalibnieki-pa-pilsetam-riga.csv",
                 "dalibnieki-pa-pilsetam-daugavpils.csv",
                 "dalibnieki-pa-pilsetam-liepaja.csv")
  schoolLanguageList = ldply(filenames, function(filename) {    
    dum = read.table(
      file=filename, 
      sep=",",
      header=TRUE,
      row.names=NULL,  
      fileEncoding="UTF-8")
    return(dum)
  })
  return(schoolLanguageList)
}


getResultTables <- function(amoNum) {
  schoolLanguageList <- ldply(5:12, function(gg) {    
    dum = read.table(
      file=sprintf("amo%02d-results-%02dkl.csv",amoNum,gg), 
      sep=",",
      header=TRUE,
      row.names=NULL,  
      fileEncoding="UTF-8")
    dum$Grade <- gg
    return(dum)
  })
  return(schoolLanguageList)
}

getSchoolsForLanguage <- function(lang) {
  
  schoolLanguageList <- getSchoolLanguageList()
  skolas <- names(table(schoolLanguageList$Skola))
  
  result <- character(0)
  for (skola in skolas) {
    subThis <- schoolLanguageList[schoolLanguageList$Skola == skola
                                  & schoolLanguageList$Valoda == lang,]
    subOther <- schoolLanguageList[schoolLanguageList$Skola == skola
                                   & schoolLanguageList$Valoda != lang,]
    numThis <- nrow(subThis)
    numOther <- nrow(subOther)
    #  print(sprintf("%s: %d %d", skola,numLV, numRU))
    if (numThis > 0 & numOther == 0) {
      result <- c(result,skola)
    } else if (numThis > 0 & numOther > 0) {
      print(paste0("***************** WARNING: Multi-language school: ",skola ))
    } 
  }
  return(result)
}

schoolsLanguages <- read.table(
  file="schools-lang.csv", 
  sep=",",
  header=TRUE,
  row.names=NULL,  
  fileEncoding="UTF-8")

# Remove special symbols from school name; normalize spaces
normalizeName <- function(x) {
  x1 <- gsub("[\\.\"()]|-|\\\\", " ", x)
  x2 <- gsub("^\\s+|\\s+$","",x1)
  x3 <- gsub("\\s+"," ",x2)
  return(x3)  
}

rawSchools <- as.vector(schoolsLanguages$School)
allSchools <- as.vector(sapply(rawSchools,normalizeName))


# Given school and teacher strings, try to deduce participant's language
getLang <- function(school, teacher) {
  spacedSchool <- normalizeName(school)
  #  allSchools <- as.vector(schoolsLanguages$School)
  
  currSchoolLocations <- which(school == allSchools | spacedSchool == allSchools)
  if (length(currSchoolLocations) == 0) {
    # "school" is not found in the schools-languages.csv file
    # Return "L" - global default
    print(sprintf("WARNING - Missing school: %s",spacedSchool))
    return("L")
  } else if (length(currSchoolLocations) == 1) {
    # There is exactly one "school" entry; return its language
    lang <- schoolsLanguages[currSchoolLocations[1],"Language"]
    return(as.character(lang))
  } else {
    # "school" is probably multi-lingual. 
    # Find a matching teacher, or return school's default (teacher=*).  
    defaultLang <- ""
    lang <- ""
    for (i in currSchoolLocations) {
      tt <- as.character(schoolsLanguages[i,"Teacher"])
      if (tt == "*") {
        defaultLang <- schoolsLanguages[i,"Language"]
      } else if (tt != "*" & grepl(tt,teacher)) {
        lang <- schoolsLanguages[i,"Language"]
      } 
    }    
    if (lang == "") {
      return(as.character(defaultLang))
    } else {
      return(as.character(lang))
    }    
  }
}



