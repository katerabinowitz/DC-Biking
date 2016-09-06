import requests
from bs4 import BeautifulSoup
import pandas as pd

weather=['temperature','humidity','precipitation']
wList=[]

###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
###Get hourly bike count for BTWD 2016###
#humidity data only starts at 11/2014
for wType in weather:
	url = 'http://webservices.commuterpage.com/weatherdata.cfc?wsdl&method=GetData&dates=20141101-20160901&code='+wType
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	value=[]
	date=[]
	code=[]

	weather=pd.DataFrame()

	for i in range(0, len(soup.findAll("date"))):
		d=soup.findAll("date")[i]["value"]
		date.append(d)

	for i in range(0, len(soup.findAll("data"))):
		c=soup.findAll("data")[i]["code"]
		code.append(c)

		v=soup.findAll("data")[i]["value"]
		value.append(v)

	counter= [wType] * len(soup.findAll("date"))
	innerColumns = {'code':code,'date': date, 'value': value}
	weather = pd.DataFrame(innerColumns)
	wList.append(weather)
weatherDay = pd.concat(wList)
weatherDay.to_csv('weatherDaily.csv')

