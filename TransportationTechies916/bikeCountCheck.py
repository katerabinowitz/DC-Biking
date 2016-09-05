import requests
from bs4 import BeautifulSoup
import pandas as pd

counterID=[7,8,30,31,43]
dfList=[]
dfHourList=[]


###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=06/05/2013&endDate=06/12/2013&mode=B&interval=h'
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

		m=soup.findAll("count")[i]["mode"]
		mode.append(m)

		h=soup.findAll("count")[i]["hour"]
		hour.append(h)

	counter= [num] * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode, 'hour':hour}
	bikeCounts = pd.DataFrame(innerColumns)
	dfHourList.append(bikeCounts)
bikeCountHour = pd.concat(dfHourList)
bikeCountHour.to_csv('bridgeCheck13.csv')

###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=07/10/2014&endDate=07/30/2014&mode=B&interval=h'
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

		m=soup.findAll("count")[i]["mode"]
		mode.append(m)

		h=soup.findAll("count")[i]["hour"]
		hour.append(h)

	counter= [num] * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode, 'hour':hour}
	bikeCounts = pd.DataFrame(innerColumns)
	dfHourList.append(bikeCounts)
bikeCountHour = pd.concat(dfHourList)
bikeCountHour.to_csv('bridgeCheck14.csv')

###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=07/09/2015&endDate=08/12/2015&mode=B&interval=h'
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

		m=soup.findAll("count")[i]["mode"]
		mode.append(m)

		h=soup.findAll("count")[i]["hour"]
		hour.append(h)

	counter= [num] * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode, 'hour':hour}
	bikeCounts = pd.DataFrame(innerColumns)
	dfHourList.append(bikeCounts)
bikeCountHour = pd.concat(dfHourList)
bikeCountHour.to_csv('bridgeCheck15.csv')



