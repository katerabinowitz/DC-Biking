library(dplyr)
library(broom)
library(rgdal)
setwd("/Users/katerabinowitz/Documents/DataLensDCOrg/CaBiBloom")

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
bloom <- subset(cabiCB,cabiCB$Bike.number=="######") %>%
         arrange(startDT) %>%
         mutate(lagEnd=lag(End.station),
                lagTime=lag(endDT), 
                downTime=startDT-lagTime)

#where bike was rebalanced, append end station to start station to account for that bike location
bloomMove <- bloom %>% subset(Start.station != lagEnd) %>% 
                       select(lagEnd) %>%
                       rename(Start.station = lagEnd)

bloomStation <- bloom %>% select(Start.station)

bloomStation <- rbind(bloomStation, bloomMove)

# Rename stations that have been renamed or moved (a short distance)
bloomStation <- as.data.frame(table(bloomStation$Start.station)) %>%
                arrange(desc(Freq)) %>%
                mutate(Var1 = ifelse(Var1=="Smithsonian / Jefferson Dr & 12th St SW","Smithsonian-National Mall / Jefferson Dr & 12th St SW",
                                     ifelse(Var1=="7th & F St NW / National Portrait Gallery","7th & F St NW/Portrait Gallery",
                                            ifelse(Var1=="MLK Library/9th & G St NW","10th & G St NW",
                                                   ifelse(Var1=="N Quincy St & Wilson Blvd","Wilson Blvd & N Quincy St",
                                                          ifelse(Var1=="5th & Kennedy St NW","4th & Kennedy St NW",
                                                                 ifelse(Var1=="20th & Bell St","Eads St & 15th St S",
                                                                        ifelse(Var1=="Lee Hwy & N Nelson St","Lee Hwy & N Monroe St",
                                                                               as.character(Var1)))))))))

cabiLocs <- readOGR("http://opendata.dc.gov/datasets/a1f7acf65795451d89f0a38565a975b3_5.geojson","OGRGeoJSON")
cabiBloomMap <- merge(cabiLocs, bloomStation, by.x="ADDRESS",by.y="Var1")

cabiBloomMap <- cabiBloomMap[!(is.na(cabiBloomMap@data$Freq)),]  

writeOGR(cabiBloomMap, 'cabiBloomMap.geojson','cabiBloomMap', driver='GeoJSON',check_exists = FALSE)

bloomDT <- bloom %>% arrange(desc(downTime))