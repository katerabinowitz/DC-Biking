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
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetMinDates&CounterID='+str(num)
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	startDate=soup.getText()

	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetMaxDates&CounterID='+str(num)
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	endDate=soup.findAll("string")[1].getText()

	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetCountInDateRange&counterid='+str(num)+'&startDate='+startDate+'&endDate='+endDate+'&mode=B&interval=d'
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

	counter= num * len(soup.findAll("count"))
	innerColumns = {'counter':counter,'bikeCount': bikeCount, 'date': date, 'direction': direction, 'mode': mode}
	bikeCounts = pd.DataFrame(innerColumns)
dfList.append(bikeCounts)
print dfList
bikeCountDF = pd.concat(dfList)
bikeCountDF.to_csv('bikeCountScrape.csv')