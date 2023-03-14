if (!"reshape" %in% installed.packages()) install.packages("reshape")
library(reshape)
library(ggplot2)

results <- getExtResults()
pupilsPerGrade <- as.vector(table(results$Grade))
pupilsPerGradePercent <- 100*pupilsPerGrade/sum(pupilsPerGrade)

AlphaVals <- 100*as.vector(table(results$Grade[
  results$Dzimums=="Male" & results$Language=="L"]))/pupilsPerGrade
BetaVals <- 100*as.vector(table(results$Grade[
  results$Dzimums=="Female" & results$Language=="L"]))/pupilsPerGrade
GammaVals <- 100*as.vector(table(results$Grade[
  results$Dzimums=="Male" & results$Language=="K"]))/pupilsPerGrade
DeltaVals <- 100*as.vector(table(results$Grade[
  results$Dzimums=="Female" & results$Language=="K"]))/pupilsPerGrade


df <- data.frame(
  segment = 5:12, 
  segpct = pupilsPerGradePercent, 
  lv.males = AlphaVals, 
  lv.females = BetaVals,
  ru.males = GammaVals, 
  ru.females = DeltaVals)

df$xmax <- cumsum(df$segpct)
df$xmin <- df$xmax - df$segpct
df$segpct <- NULL

head(df)



dfm <- melt(df, id = c("segment", "xmin", "xmax"))
head(dfm)

dfm1 <- ddply(dfm, .(segment), transform, ymax = cumsum(value))
dfm1 <- ddply(dfm1, .(segment), transform,
              ymin = ymax - value)


dfm1$xtext <- with(dfm1, xmin + (xmax - xmin)/2)
dfm1$ytext <- with(dfm1, ymin + (ymax - ymin)/2)

p <- ggplot(dfm1, aes(ymin = ymin, ymax = ymax,
                      xmin = xmin, xmax = xmax, fill = variable))

p1 <- p + geom_rect(colour = I("grey"))

p2 <- p1 + geom_text(
  aes(x = xtext, y = ytext,
      label = ifelse(segment == "A", 
                     paste(variable," - ", value, "%", sep = ""), 
                     sprintf("%2.1f%%", value))), 
  size = 3.5)



p3 <- p2 + geom_text(aes(x = xtext, y = 103,
                         label = sprintf("G%d", segment)), size = 4)


p3 + theme_bw() + 
  labs(x = NULL, y = NULL,fill = NULL) +  
  scale_fill_brewer(palette = "Set2") + 
  theme(#legend.position = "none",
       panel.grid.major = element_line(colour = NA),
       panel.grid.minor = element_line(colour = NA))

