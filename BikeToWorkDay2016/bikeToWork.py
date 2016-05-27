import requests
from bs4 import BeautifulSoup
import pandas as pd

counterID=range(1,46)
dfList=[]
dfHourList=[]

###Get Daily Bike Counts for Past Year###
###Get Daily Bike Counts for Past Year###
###Get Daily Bike Counts for Past Year###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=04/20/2015&endDate=05/21/2016&mode=B&interval=d'
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	bikeCount=[]
	date=[]
	direction=[]
	mode=[]

	bikeCounts=pd.DataFrame()

	for i in range(0, len(soup.findAll("count"))):
		bc=soup.findAll("count")[i]["count"]
		bikeCount.append(bc)

		d=soup.findAll("count")[i]["date"]
		date.append(d)

		direct=soup.findAll("count")[i]["direction"]
		direction.append(direct)

		m=soup.findAll("count")[i]["mode"]
		mode.append(m)

	counter= [num] * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode}
	bikeCounts = pd.DataFrame(innerColumns)
	dfList.append(bikeCounts)
bikeCountDF = pd.concat(dfList)
bikeCountDF.to_csv('bikeCount.csv')


###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=05/20/2016&endDate=05/20/2016&mode=B&interval=h'
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	bikeCount=[]
	date=[]
	direction=[]
	mode=[]
	hour=[]

	bikeCounts=pd.DataFrame()

	for i in range(0, len(soup.findAll("count"))):
		bc=soup.findAll("count")[i]["count"]
		bikeCount.append(bc)

		d=soup.findAll("count")[i]["date"]
		date.append(d)

		direct=soup.findAll("count")[i]["direction"]
		direction.append(direct)

		h=soup.findAll("count")[i]["hour"]
		hour.append(h)

		m=soup.findAll("count")[i]["mode"]
		mode.append(m)

	counter= [num] * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode, 'hour':hour}
	bikeCounts = pd.DataFrame(innerColumns)
	dfHourList.append(bikeCounts)
bikeCountHour = pd.concat(dfHourList)
bikeCountHour.to_csv('bikeCountHour.csv')


### Get bike counter location###
### Get bike counter location###
### Get bike counter location###
url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetAllCounters'
r = requests.get(url)
soup = BeautifulSoup(r.text)
counter=[]
name=[]
latitude=[]
longitude=[]

for i in range(0, len(soup.findAll("counter"))):
		counterID=soup.findAll("counter")[i]["id"]
		counter.append(counterID)

		n=soup.findAll("counter")[i].findAll("name")[0].getText()
		name.append(n)

		lat=soup.findAll("latitude")[i].getText()
		latitude.append(lat)

		lon=soup.findAll("longitude")[i].getText()
		longitude.append(lon)
counterLocation = pd.DataFrame({'counter':counter, 'name':name, 'latitude':latitude, 'longitude':longitude})
counterLocation.to_csv('counterLocation.csv')

