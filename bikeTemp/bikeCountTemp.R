library(dplyr)
library(reshape2)
library(lubridate)
library(ggplot2)
library(scales)
setwd("/Users/katerabinowitz/Documents/DataLensDC/DC-Biking/bikeTemp")

bc<-read.csv("tempBikeCount.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
table(bc$counter,bc$direction)
bc<-filter(bc,counter %in% c(3,10,12,14,19,20,22,23,24,25))

bc<-ddply(bc, c("counter","date"), function(df)sum(df$bikeCount))
bc<-mutate(bc,date=as.Date(bc$date,format = "%m/%d/%Y"),counter=factor(counter))
bc<-mutate(bc,day=weekdays(bc$date))
bc<-mutate(bc,dayType=ifelse(bc$day=="Saturday"|bc$day=="Sunday","weekend","weekday"))


wd<-read.csv("temperatureDaily.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
weather<- dcast(wd, date ~ code, value.var="value")
weather<-mutate(weather,temperature=as.numeric(weather$temperature),precipitation=as.numeric(weather$precipitation),
                date=as.Date(paste0(substr(weather$date,5,6),"/",substr(weather$date,7,8),"/",substr(weather$date,1,4)),format = "%m/%d/%Y"))
str(weather)
summary(weather)

bcw<-merge(bc,weather,by="date")
bcw<-arrange(bcw,date)

bcw<-mutate(bcw, tempG=cut(bcw$temperature,c(10,40,50,60,70,80,100)),tempC=cut(bcw$temperature,5))
table(bcw$tempG)

bcwc<-ddply(bcw, c("tempG", "counter", "dayType"), function(df)median(df$V1))
bcWD<-filter(bcwc,dayType=="weekend")
bcWK<-filter(bcwc,dayType=="weekday")
bc25<-filter(bcwc,counter=="12")

ggplot(data=bcWK, aes(x=tempG, y=V1, fill=counter)) +
  geom_bar(stat="identity", position=position_dodge())

bc25<-filter(bcw,counter=="12" & dayType=="weekday")
bc25<-filter(bc25,V1>1300)
ggplot(data=bc25, aes(x=temperature, y=V1, group=counter, colour=counter)) +
  geom_line() +
  stat_smooth(method = "lm", formula = y ~ x)

