library(plyr)
library(reshape2)
library(lubridate)
library(ggplot2)
library(scales)
setwd("/Users/katerabinowitz/Documents/DataLensDC/DC-Biking/TransportationTechies916")


###Bon Air Bike Comparison###
###Bon Air Bike Comparison###
###Bon Air Bike Comparison###
ba<-read.csv("bonAirCountHour.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
ba$date<-as.Date(ba$date,format = "%m/%d/%Y")
ba$day<- weekdays(ba$date)
ba$dayType<-ifelse(ba$day=="Saturday"|ba$day=="Sunday","weekend","weekday")

baSum<-ddply(ba, c("counter","day","hour"), function(df)median(df$bikeCount))
baSumW <- dcast(baSum, dayType + hour ~ counter, value.var="V1")
colnames(baSumW)[c(3:5)]<-c("c2","c3","c25")

baSumWeek<-subset(baSum, baSum$dayType=="weekday")

baSum$DayHour<-paste(baSum$day,baSum$hour)
ggplot(data=baSum, aes(x=DayHour, y=V1, group=counter, colour=counter)) +
  geom_line() +
  geom_point()


###Bridge Directions###
###Bridge Directions###
###Bridge Directions###
bridge<-read.csv("bridgeCount.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
loc<-read.csv("https://raw.githubusercontent.com/katerabinowitz/DC-Biking/master/BikeToWorkDay2016/counterLocation.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)[c(2,5)]
table(bridge$counter)
bridge$date<-as.Date(bridge$date,format = "%m/%d/%Y")
dateCheck<-ddply(bridge, c("counter"), function(df)min(df$date))
bridge$day<- weekdays(bridge$date)
bridgeWD<-subset(bridge,bridge$day %in% c("Monday","Tuesday","Wednesday","Thursday","Friday"))

zeroCheck<-subset(bridgeWD,bridgeWD$counter==48 & bridgeWD$bikeCount==0)
zc<-as.data.frame(table(zeroCheck$date))
zc<-zc[order(-zc$Freq),]

table(bridgeWD$counter)
bridgeWD$counter1<-ifelse(bridgeWD$counter==7|bridgeWD$counter==8,"R",bridgeWD$counter)
bwdS<-ddply(bridgeWD, c("date","hour","direction", "counter1"), function(df)sum(df$bikeCount))
tdSum<-ddply(bwdS, c("hour","direction", "counter1"), function(df)median(df$V1))
colnames(tdSum)[c(3)]<-"counter"

kb<-c("R","Key Bridge")
locK<-rbind(loc,kb)
tdLocSum<-merge(locK,tdSum,by="counter")
tdLocSum$direction<-ifelse(tdLocSum$counter=="R" & tdLocSum$direction=="I","Southbound",
                           ifelse(tdLocSum$counter=="R" & tdLocSum$direction=="O","Northbound",
                                  ifelse(tdLocSum$counter!="R" & tdLocSum$direction=="I","Northbound",
                                         "Southbound")))


ggplot(data=tdLocSum, aes(x=hour,y=V1, group=direction,color=direction)) +
  facet_wrap(~name) +
  geom_line()+
  theme(axis.text.x = element_text()) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(text = element_text(size=16)) +
  theme(legend.position="top") +
  theme(legend.title=element_blank()) +
  theme(legend.background = element_rect(fill="#EFF0F1")) +
  theme(axis.title.y = element_text(color="#505050")) +
  labs(x="Hour (military time)", y="Number of bikes counted", title="Weekday Bike Flows")


###Weather Comparison###
###Weather Comparison###
###Weather Comparison###
bcd<-read.csv("bikeCountDaily.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
bcd$date<-as.Date(bcd$date,format = "%m/%d/%Y")
wd<-read.csv("weatherDaily.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)[c(2:4)]

dateCheck<-ddply(bcd, c("counter"), function(df)min(df$date))
dateCheck<-dateCheck[order(dateCheck$V1),]

b14<-subset(bcd, bcd$counter==10)
b14s<-ddply(b14, c("counter","date"), function(df)sum(df$bikeCount))
min(b14s$date)-max(b14s$date)
subset(b14s,b14s$V1==0)

weather<- dcast(wd, date ~ code, value.var="value")[c(1:2,4)]
weather$temperature<-as.numeric(weather$temperature)
weather$humidity<-as.numeric(weather$humidity)
weather$d<-paste0(substr(weather$date,5,6),"/",substr(weather$date,7,8),"/",substr(weather$date,1,4))
weather$date<-as.Date(weather$d,format = "%m/%d/%Y")

b14w<-merge(b14s,weather,by="date")
summary(b14w)
b14w$Temperature<-cut(b14w$temperature,c(10,40,50,60,70,80,100))
b14w$Humidity<-cut(b14w$humidity,c(25,50,60,70,80,100))
table(b14w$Humidity)
b14w$temp<-cut(b14w$temperature,5)
b14w$hum<-cut(b14w$humidity, 5)


b14wg<-ddply(b14w, c("Temperature","Humidity"), function(df)median(df$V1))
ggplot(b14wg, aes(x = Temperature, y = Humidity)) +
  geom_tile(aes(fill = V1)) + 
  scale_fill_gradient(name = 'Bike counts,\ndaily', low = '#f5edf7', high = '#431E1F') + 
  theme(axis.text.x = element_text()) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(text = element_text(size=14)) +
  theme(legend.background = element_rect(fill="#EFF0F1")) +
  theme(axis.title.y = element_text(color="#505050")) +
  labs(x="Temperature, daily avg", y="Humidity, daily avg", 
       title="Biking and Temperature on the Mt Vernon Trail")


### Manual Bike Count Comparison###
### Manual Bike Count Comparison###
### Manual Bike Count Comparison###
bikeCount<-read.csv('https://raw.githubusercontent.com/HackShopDC/October29-VisionZeroData/master/BikeCountData/BikeCounts2002-2015.csv',na.strings=c("", "NA"),
                    strip.white=TRUE)[c(3,5:6,8,11:12,26)]
bcb<-subset(bikeCount,bikeCount$Count.Location %in% c("Francis Scott Key Bridge","George Mason Brg (14th St Bridge)",
                                                      "Theodore Roosevelt Memorial Brg","15th St"))
bcb$Date <- as.Date(as.character(bcb$Date), "%m/%d/%Y")
bcb12<-subset(bcb, year(bcb$Date)>2012)

bcc13<-read.csv('bridgeCheck13.csv',fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
bcc13<-subset(bcc13,bcc13$date=="06/05/2013" & bcc13$hour %in% c(6,7,8,9,15,16,17,18))
bcc13$DT<-ifelse(bcc13$hour<10,"AM","PM")
bcc13<-ddply(bcc13, c("DT"), function(df)sum(df$bikeCount))

bcc14<-read.csv('bridgeCheck14.csv',fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
bcc14<-subset(bcc14,(((bcc14$counter==7 | bcc14$counter==8) & bcc14$date=="07/29/2014")| (bcc14$counter==30 & bcc14$date=="07/10/2014")|
                       (bcc14$counter==31 & bcc14$date=="07/30/2014")) & bcc14$hour %in% c(6,7,8,9,15,16,17,18))
bcc14$DT<-ifelse(bcc14$hour<10,"AM","PM")
bcc14<-ddply(bcc14, c("counter","DT"), function(df)sum(df$bikeCount))

bcc15<-read.csv('bridgeCheck15.csv',fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
bcc15<-subset(bcc15,(((bcc15$counter==43) & bcc15$date=="07/09/2015")| (bcc15$counter==30 & bcc15$date=="08/12/2015"))
                      & bcc15$hour %in% c(6,7,8,9,15,16,17,18))
bcc15$DT<-ifelse(bcc15$hour<10,"AM","PM")
bcc15<-ddply(bcc15, c("counter","DT"), function(df)sum(df$bikeCount))


### Min date for bike counters ###
### Min date for bike counters ###
### Min date for bike counters ###
mbc<-read.csv("minBC.csv", fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
mbc<-as.data.frame(t(mbc))
mbc<-subset(mbc,mbc$V1!=0)
mbc$bc<-1:47
mbc$date <- as.Date(mbc$V1, "%m/%d/%Y")
mbcY<-as.data.frame(table(year(mbc$date)))
mbcY$Freq<-ifelse(mbcY$Var1==2016,6,mbcY$Freq)
mbcYS<-as.data.frame(cumsum(mbcY$Freq))
minYr<-cbind(mbcY,mbcYS)
colnames(minYr)<-c("Year","n","cumulative")
  
ggplot(data=minYr, aes(x=Year,y=cumulative)) +
  geom_bar(stat="identity", position = 'dodge', fill="#3D84A8") +
  geom_text(aes(label=cumulative), position=position_dodge(width=0.9), vjust=-0.25) +
  theme(axis.text.x = element_text()) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(text = element_text(size=16)) +
  theme(legend.position="top") +
  theme(legend.title=element_blank()) +
  theme(legend.background = element_rect(fill="#EFF0F1")) +
  theme(axis.title.y = element_text(color="#505050"))+
  labs(x="Year", y="Bike counters", title="Number of DMV bike counters")
  

### Illustration of Broken Bike Count ###
### Illustration of Broken Bike Count ###
### Illustration of Broken Bike Count ###
broke<-subset(bcd,bcd$counter==18 & bcd$date>as.Date("2015-08-01") & bcd$date<as.Date("2016-06-01"))
as.Date("2016-06-01")-as.Date("2015-08-01")
allDates <- as.data.frame(seq(as.Date("2015-08-01"),as.Date("2016-06-01"), by="day"))
colnames(allDates)<-"date"

broke18<-merge(broke,allDates,by="date",all.y=TRUE)
broke18[is.na(broke18)] <- 0

ggplot(data=broke18, aes(x=date,y=bikeCount)) +
  geom_line(colour="#3D84A8") +
  scale_x_date(labels = date_format("%b %y")) +
  theme(axis.text.x = element_text()) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(text = element_text(size=16)) +
  theme(axis.title.y = element_text(color="#505050"))+
  labs(x=NULL,y="Bike counts", title="An unfortunate incident on Crystal Drive")
