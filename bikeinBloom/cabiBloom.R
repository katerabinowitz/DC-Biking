library(dplyr)
library(broom)
library(rgdal)
require(classInt)
setwd("/Users/katerabinowitz/Documents/DataLensDC/DC-Biking/bikeinBloom")

### Create clean Cabi 2016 H1 dataset ###
### Create clean Cabi 2016 H1 dataset ###
### Create clean Cabi 2016 H1 dataset ###
files = list.files(pattern="*.csv")
names<-c("cabiQ1","cabiQ2")

for (i in 1:length(files)) 
  assign(names[i], read.csv(files[i],stringsAsFactors = FALSE,fill = FALSE,strip.white = TRUE))

colnames(cabiQ1)[9]<-"Account.type"

cabi <- rbind(cabiQ1, cabiQ2)

cabiCB <- cabi %>%
          mutate(startDT=as.POSIXct(strptime(cabi$Start.date, "%m/%d/%Y %H:%M")),
                 endDT=as.POSIXct(strptime(cabi$End.date, "%m/%d/%Y %H:%M"))) %>%
          subset((as.Date(startDT) > as.Date("2016-03-19")) &
                 (as.Date(endDT) < as.Date("2016-04-17")))
rm(cabi, cabiQ1, cabiQ2, files, i, names)

### Calculate rides and times ###
### Calculate rides and times ###
### Calculate rides and times ###
cabiCount <- as.data.frame(table(cabiCB$Bike.number)) %>% 
              arrange(desc(Freq)) %>%
              subset(Freq>15)

cabiCB <- cabiCB %>% subset(cabiCB$Bike.number %in% cabiCount$Var1)
                  
cabiDuration <- cabiCB %>% select(Bike.number, Duration..ms.) %>%
  mutate(DurationM=Duration..ms./60000) %>%
  group_by(Bike.number) %>%
  do(tidy(t(quantile(.$DurationM))) ) %>%
  arrange(desc(X50.))
  
cabiTotalTime <- cabiCB %>% select(Bike.number, Duration..ms.) %>%
    group_by(Bike.number) %>%
    summarise(totalTime=sum(Duration..ms.)) %>%
    arrange(desc(totalTime)) %>%
    mutate(hours=totalTime/3600000)

### Look at bloom bike locations and downtime ###
### Look at bloom bike locations and downtime ###
### Look at bloom bike locations and downtime ###
# Rename stations that have been renamed or moved (a short distance)
bloom <- subset(cabiCB,cabiCB$Bike.number=="XXXXXX") %>%
         arrange(startDT) %>%
         mutate(lagTime=lag(endDT), 
                downTime=startDT-lagTime, 
                Start.station = ifelse(Start.station=="Smithsonian / Jefferson Dr & 12th St SW","Smithsonian-National Mall / Jefferson Dr & 12th St SW",
                                  ifelse(Start.station=="7th & F St NW / National Portrait Gallery","7th & F St NW/Portrait Gallery",
                                     ifelse(Start.station=="MLK Library/9th & G St NW","10th & G St NW",
                                            ifelse(Start.station=="N Quincy St & Wilson Blvd","Wilson Blvd & N Quincy St",
                                                   ifelse(Start.station=="5th & Kennedy St NW","4th & Kennedy St NW",
                                                          ifelse(Start.station=="20th & Bell St","Eads St & 15th St S",
                                                                 ifelse(Start.station=="Lee Hwy & N Nelson St","Lee Hwy & N Monroe St",
                                                                        as.character(Start.station)))))))),
                End.station = ifelse(End.station=="Smithsonian / Jefferson Dr & 12th St SW","Smithsonian-National Mall / Jefferson Dr & 12th St SW",
                                       ifelse(End.station=="7th & F St NW / National Portrait Gallery","7th & F St NW/Portrait Gallery",
                                              ifelse(End.station=="MLK Library/9th & G St NW","10th & G St NW",
                                                     ifelse(End.station=="N Quincy St & Wilson Blvd","Wilson Blvd & N Quincy St",
                                                            ifelse(End.station=="5th & Kennedy St NW","4th & Kennedy St NW",
                                                                   ifelse(End.station=="20th & Bell St","Eads St & 15th St S",
                                                                          ifelse(End.station=="Lee Hwy & N Nelson St","Lee Hwy & N Monroe St",
                                                                                 as.character(End.station)))))))),
                lagEnd=lag(End.station))

#where bike was rebalanced, append end station to start station to account for that bike location
bloomMove <- bloom %>% subset(Start.station != lagEnd) %>% 
                       select(lagEnd) %>%
                       rename(Start.station = lagEnd)

bloomStation <- bloom %>% select(Start.station)
bloomStation <- rbind(bloomStation, bloomMove)
bloomStation <- as.data.frame(table(bloomStation$Start.station)) %>%
                arrange(desc(Freq)) 

cabiLocs <- readOGR("http://opendata.dc.gov/datasets/a1f7acf65795451d89f0a38565a975b3_5.geojson","OGRGeoJSON")

cabiBloomMap <- merge(cabiLocs, bloomStation, by.x="ADDRESS",by.y="Var1")
cabiBloomMap <- cabiBloomMap[!(is.na(cabiBloomMap@data$Freq)),]  

bloomDT <- bloom %>% arrange(desc(downTime)) %>%
                     mutate(move=ifelse(Start.station != lagEnd,1,0), 
                            startHr=as.POSIXlt(startDT)$hour, 
                            endHr=as.POSIXlt(lagTime)$hour,
                            minDT=downTime/60,
                            hrDT=downTime/3600) %>%
                     filter(move==0)

bloomDTStation <- bloomDT %>% group_by(Start.station) %>% 
                              summarise(meanDT=mean(minDT)) %>%
                              mutate(meanDT=as.numeric(meanDT)) %>%
                              arrange(desc(meanDT))
str(bloomDTStation)

nat = classIntervals(bloomDTStation[[2]], n = 10, style = 'jenks')$brks
nat

cabiBloomMap <- merge(cabiBloomMap, bloomDTStation, by.x="ADDRESS",by.y="Start.station")
writeOGR(cabiBloomMap, 'cabiBloomMap.geojson','cabiBloomMap', driver='GeoJSON',check_exists = FALSE)
