import requests
from bs4 import BeautifulSoup
import pandas as pd

counterID=range(1,26)
dfList=[]
dfHourList=[]


###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate=09/01/2013&endDate=09/20/2016&mode=B&interval=d'
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	bikeCount=[]
	date=[]
	direction=[]
	mode=[]
	ib=[]
	ob=[]

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
	dfHourList.append(bikeCounts)
bikeCountHour = pd.concat(dfHourList)
bikeCountHour.to_csv('tempBikeCount.csv')

