# Links for R resource
#http://www.cookbook-r.com/
#http://www.sthda.com/english/

#Set the working directory 
setwd('/home/shivaram/UPB/CMS_C2X_Lab/C2X_Labs/Lab01/edca/simulations/results/csvFiles/csvCopies')

# Load the required libraries
library(tidyverse)
library(ggplot2)
library(dplyr)

# read the csv files
voDelayVec = read_csv('only_vo_two_nodes_vodelay.csv')
viDelayVec = read_csv('only_vi_two_nodes_videlay.csv')
beDelayVec <- read_csv('only_be_two_nodes_bedelay.csv')
bkDelayVec <- read_csv('only_bk_two_nodes_bkdelay.csv')
# specify col_type for avoiding wrong types being assigned
allDelayVec <- read_csv('all_ac_two_nodes_alldelay.csv', col_types = "ddccddddd")

#aggregate data
voAggDelay <- voDelayVec %>% group_by(repetition) %>% summarise(mean = mean(`VOdelay:vector`, na.rm = TRUE), sd = sd(`VOdelay:vector`, na.rm = TRUE))
viAggDelay <- viDelayVec %>% group_by(repetition) %>% summarise(mean = mean(`VIdelay:vector`, na.rm = TRUE), sd = sd(`VIdelay:vector`, na.rm = TRUE))
beAggDelay <- beDelayVec %>% group_by(repetition) %>% summarise(mean = mean(`BEdelay:vector`, na.rm = TRUE), sd = sd(`BEdelay:vector`, na.rm = TRUE))
bkAggDelay <- bkDelayVec %>% group_by(repetition) %>% summarise(mean = mean(`BKdelay:vector`, na.rm = TRUE), sd = sd(`BKdelay:vector`, na.rm = TRUE))
allAggDelay <- allDelayVec %>% group_by(repetition) %>% summarise(voMean = mean(`VOdelay:vector`, na.rm = TRUE), voSD = sd(`VOdelay:vector`, na.rm = TRUE), viMean = mean(`VIdelay:vector`, na.rm = TRUE), viSD = sd(`VIdelay:vector`, na.rm = TRUE), beMean = mean(`BEdelay:vector`, na.rm = TRUE), beSD = sd(`BEdelay:vector`, na.rm = TRUE), bkMean = mean(`BKdelay:vector`, na.rm = TRUE), bkSD = sd(`BKdelay:vector`, na.rm = TRUE))

View(beAggDelay)
View(bkAggDelay)
View(viAggDelay)
View(allDelayVec)
View(allAggDelay)

# Create column vectors for final data frame
voMean <- c(mean(voAggDelay$mean), mean(allAggDelay$voMean))
voCI <- c(1.96*(sd(voAggDelay$mean)/sqrt(length(voAggDelay$mean))), 1.96*(sd(allAggDelay$voMean)/sqrt(length(allAggDelay$voMean))))
viMean <- c(mean(viAggDelay$mean), mean(allAggDelay$viMean))
viCI <- c(1.96*(sd(viAggDelay$mean)/sqrt(length(viAggDelay$mean))), 1.96*(sd(allAggDelay$viMean)/sqrt(length(allAggDelay$viMean))))
beMean <- c(mean(beAggDelay$mean), mean(allAggDelay$beMean))
beCI <- c(1.96*(sd(beAggDelay$mean)/sqrt(length(beAggDelay$mean))), 1.96*(sd(allAggDelay$beMean)/sqrt(length(allAggDelay$beMean))))
bkMean <- c(mean(bkAggDelay$mean), mean(allAggDelay$bkMean))
bkCI <- c(1.96*(sd(bkAggDelay$mean)/sqrt(length(bkAggDelay$mean))), 1.96*(sd(allAggDelay$bkMean)/sqrt(length(allAggDelay$bkMean))))

# aggregate column vectors, no summarise function
mean <- c(voMean, viMean, beMean, bkMean)
CI <-c(voCI, viCI, beCI, bkCI)
categ <- c('vo','vo','vi','vi','be','be','bk','bk')
typ <- c('vo_only','all','vi_only','all','be_only','all','bk_only','all')

#Example for creating the data frame
finData <- data.frame(typ,categ,mean,CI)
remove(finData)

# assiging level will ensure that when the below column is used as an axis in a plot then the data is not aplhabetically ordered
typ1 <- factor(c('vo_only','all','vi_only','all','be_only','all','bk_only','all'), levels=c('vo_only','vi_only','be_only','bk_only','all'))

# creating a data frame as ggplot works only with data frames
finData <- data.frame(typ1,categ,mean,CI)

# Example line plot using ggplot2
g <- ggplot(finData, aes(x=typ, y=mean, group=categ, colour=categ)) + 
     geom_errorbar(aes(ymin=mean-CI, ymax=mean+CI), width=.1) + 
     geom_line() + 
     geom_point(position = position_dodge(0.7)) +
     labs(title = "End-to-end Delay for EDCA Packets", x = "Channel Access", y = "Time(s)") +
     theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 18), axis.title = element_text(size = 14), legend.title = element_blank(), legend.box.background = element_rect()) +
     ylim(c(0,65))
plot(g)

# Example for converting y axis into log10 scale
g <- ggplot(finData, aes(x=typ1, y=mean, group=categ, colour=categ)) + 
     geom_errorbar(aes(ymin=mean-CI, ymax=mean+CI), width=.1) +
     geom_line() + geom_point()+ ylim(c(0,65))
g + scale_y_continuous(trans='log10')

# example bar plot using ggplot2
g <- ggplot(finData, aes(x=categ, y=mean, group=typ, fill=typ)) + 
     geom_bar(stat = "identity", position = position_dodge()) +
     geom_errorbar(aes(ymin=mean-CI, ymax=mean+CI), width=.1) +
     ylim(c(0,65))
plot(g)

# Creating new column vector for x axis
categ1 <- factor(c('vo','vo','vi','vi','be','be','bk','bk'), levels = c('vo','vi','be','bk'))
pltData <- data.frame(typ1,categ1,mean,CI)

# Stacked Bar plot, time vs access category
# Plot with error bar and data point
g <- ggplot(pltData, aes(x=categ1, y=mean, group=typ1, fill=typ1)) + 
     geom_bar(stat = "identity", position = position_dodge(0.9)) +
     geom_errorbar(aes(ymin=mean-CI, ymax=mean+CI), width=.1, size=0.3, position=position_dodge(.9)) +
     geom_point(position = position_dodge(0.9)) +
     ylim(c(0,65)) + 
     scale_fill_brewer(palette="Paired") + theme_minimal() + 
     geom_text(aes(label=round(mean, 4)), vjust=1.6, color="black", position = position_dodge(0.9), size=3.5) +
     labs(title="End-to-end delay", x="Access categories", y = "time (s)")
plot(g)

# Example for plotting multiple variable and guides
p <- ggplot(pltData, aes(x=RSUs, y=delayT, colour=queueType)) +
  geom_point(aes(shape=arrival_time, size=15)) +
  geom_line(aes(linetype=arrival_time)) +
  scale_x_continuous(breaks = c(10,25,50)) + 
  ylim(c(0,65)) + 
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  labs(title = "End-to-end Delay for EDCA Packets", x = "Number of RSUs", y = "Time(s)") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 18), axis.title = element_text(size = 14), 
        legend.box.background = element_rect()) +
  guides(size=FALSE)
