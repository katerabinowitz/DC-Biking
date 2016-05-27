library(dplyr)
library(ggplot2)

###Read in Data###
###Read in Data###
###Read in Data###
bc<-read.csv("/Users/katerabinowitz/Documents/DataLensDC Org/bikeCount.csv",
             fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
loc<-read.csv("/Users/katerabinowitz/Documents/DataLensDC Org/counterLocation.csv",
             fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)
bcHour<-read.csv("/Users/katerabinowitz/Documents/DataLensDC Org/bikeCountHour.csv",
                 fill = FALSE, strip.white = TRUE,stringsAsFactors=FALSE)

###Bike counts for BTWD 2015, 2016, and Avg May Weekday###
###Bike counts for BTWD 2015, 2016, and Avg May Weekday###
###Bike counts for BTWD 2015, 2016, and Avg May Weekday###
bikeCounts<-merge(bc,loc,by="counter")
str(bikeCounts)
bikeCounts$Date<-as.Date(bikeCounts$date,format = "%m/%d/%Y")

events<-subset(bikeCounts,bikeCounts$date=="05/15/2015" | bikeCounts$date=="05/20/2016")
events<-subset(events,events$bikeCount>500)
rightCount<-as.data.frame(table(events$name,events$date))
rightCount<-subset(rightCount, rightCount$Freq!=0)
rightCounter<-as.data.frame(table(rightCount$Var1))
rightCounter<-subset(rightCounter,rightCounter$Freq==2)[c(1)]

allDays<-merge(x=bikeCounts,y=rightCounter,by.x="name",by.y="Var1", all.y=TRUE)
may<-subset(allDays,allDays$date=="05/15/2015" | allDays$Date>"2016-05-01")
may$Day<-substr(may$date,4,5)
mayWork<-subset(may,may$Day %in% c("02","03","04","05","06","09","10","11","12","13",
                                  "15","16","17","18","19","20"))
mayWork<-subset(mayWork,mayWork$date!="05/15/2016")

mayWork$name<-ifelse(grepl("Key Bridge",mayWork$name),"Key Bridge",mayWork$name)
eventHist<-aggregate(mayWork$bikeCount, by=list(name=mayWork$name,date=mayWork$Date), FUN=sum)

btwd<-subset(eventHist,eventHist$date=="2016-05-20" | eventHist$date=="2015-05-15")

mayAvg<-subset(eventHist,eventHist$date!="2016-05-20" & eventHist$date!="2015-05-15")
WkdAvg<-aggregate(mayAvg$x, by=list(name=mayAvg$name), FUN=mean)
WkdAvg$date<-"2016-05-15"

bcView<-rbind(btwd,WkdAvg)
str(bcView)
bcView<-bcView[order(bcView[,1],bcView[,2]),]
bcView$day<-ifelse(bcView$date=="2015-05-15", "BTWD\n2015",
                   ifelse(bcView$date=="2016-05-15", "May 2016\nweekday avg",
                          ifelse(bcView$date=="2016-05-20", "BTWD\n2016","")))
bcView$day <- factor(bcView$day, levels = c("BTWD\n2015", "May 2016\nweekday avg", "BTWD\n2016"))
bcView<-subset(bcView,bcView$name!="W&OD Bon Air Park")
bcView$loc<-ifelse(bcView$name=="15th Street NW", "15th + N St NW\n(DC)",
              ifelse(bcView$name=="CC Connector", "Mt Vernon Trail +\nGW Parkway(VA)",
                ifelse(bcView$name=="Custis Rosslyn", "Custis + 20th St N\n(VA)",
                  ifelse(bcView$name=="Rosslyn Bikeometer","Custis + N Lynn St\n(VA)",
                  ifelse(bcView$name=="Key Bridge", "Key Bridge\n(VA)",
                    ifelse(bcView$name=="Metropolitan Branch Trail North", "Met Branch Trail,\nNorth (DC)",
                      ifelse(bcView$name=="TR Island Bridge", "TR Island Bridge,\n(VA)",
                        ifelse(bcView$name=="W&OD Bon Air West", "W&OD Bon Air West,\n(VA)",
                          ifelse(bcView$name=="W&OD Columbia Pike", "W&OD Columbia Pike,\n(VA)",
                             as.character(bcView$name))))))))))
###correct Met Branch 2015 BTWD to DDOT report
bcView$x<-ifelse(bcView$loc=="Met Branch Trail,\nNorth (DC)" & bcView$day== "BTWD\n2015",
                 1180,bcView$x)

col<-c("#F8AFA8", "#FDDDA0", "#74A089")
ggplot(data=bcView, aes(x=day,y=x, y)) +
  geom_bar(stat="identity",aes(fill=factor(day))) +
  scale_fill_manual(values = col)+
  facet_wrap(~loc) +
  theme(axis.text.x = element_text()) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(text = element_text(size=16)) +
  theme(legend.position="none") +
  theme(axis.title.y = element_text(color="#505050")) +
  scale_x_discrete(name="") +
  labs(x="Date", y="Number of bikes counted", title="")


### Hourly Bike Counts for BTWD 2016 ###
### Hourly Bike Counts for BTWD 2016 ###
### Hourly Bike Counts for BTWD 2016 ###
bcH<-merge(bcHour,loc,by="counter")
bcH$name<-ifelse(grepl("Key Bridge",bcH$name),"Key Bridge",bcH$name)
bcHSub<-subset(bcH,bcH$name %in% bcView$name)
hourSum<-aggregate(bcHSub$bikeCount, by=list(name=bcHSub$name,hour=bcHSub$hour), FUN=sum)

nameMatch=bcView[c(1,5)]
nameMatch<-nameMatch[!duplicated(nameMatch[,c('name')]),]
hourGraph<-merge(x=hourSum,y=nameMatch,"name")
hourGraph$hour12<-ifelse(hourGraph$hour==0, "12a",
                  ifelse(hourGraph$hour==12, "12p",
                    ifelse(hourGraph$hour<12, paste0(hourGraph$hour,"a"),
                         paste0((hourGraph$hour-12),"p"))))
hourGraph$hour12<-factor(hourGraph$hour12,
levels=c("12a","1a","2a","3a","4a","5a","6a","7a","8a","9a","10a","11a",
"12p","1p","2p","3p","4p","5p","6p","7p","8p","9p","10p","11p"))
str(hourGraph)
ggplot(data=hourGraph, aes(x=hour12,y=x)) +
  geom_bar(stat="identity", fill="#46ACC8") +
  facet_wrap(~loc) +
  theme(plot.background = element_rect(fill = '#EFF0F1'))+
  theme(axis.text.x = element_text()) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.position="none") +
  theme(text = element_text(size=16)) +
  theme(axis.title.y = element_text(color="#505050")) +
  scale_x_discrete(breaks=c("3a","6a","9a","12p","3p","6p","9p"),name="") +
  labs(x="Hour", y="Number of bikes counted", title="") 



