library(lubridate)
library(rgdal)
library(reshape)
###Read in Data###
BikeCount<-read.csv('https://raw.githubusercontent.com/HackShopDC/October29-VisionZeroData/master/BikeCountData/BikeCounts2002-2015.csv',na.strings=c("", "NA"),
                   strip.white=TRUE) 
###Explore and Factor###
str(BikeCount)
BikeCount$Date2 <- as.Date(as.character(BikeCount$Date), "%m/%d/%Y")
BikeCount0815<-subset(BikeCount, year(BikeCount$Date2)>2007)
BikeCount0815$year<-year(BikeCount0815$Date2)
summary(BikeCount0815)
BikeCount0814<-subset(BikeCount0815,BikeCount0815$year==2008 | BikeCount0815$year==2012
                      | BikeCount0815$year==2014)
table(BikeCount0814$Station.ID)
BikeCountFin<-subset(BikeCount0814, BikeCount0814$Station.ID<38)
table(BikeCountFin$Day)
table(BikeCountFin$Duration)
table(BikeCountFin$Start.Time)
table(BikeCountFin$End.Time)

### Create 2008,2012,2014 bike count maps ###
Counts<-BikeCountFin[c(2,26,28)]
Sums<-cast(Counts, Station.ID~year, sum, value="Total")
colnames(Sums)<-c("OBJECTID","Sum08","Sum12","Sum14")

locations = readOGR("http://opendata.dc.gov/datasets/13ced1ecaa9c4354bf774e27fe3c00ab_66.geojson", "OGRGeoJSON")

BCMap<-merge(Sums,locations,by="OBJECTID")
