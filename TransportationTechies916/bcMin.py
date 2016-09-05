import requests
from bs4 import BeautifulSoup
import pandas as pd

counterID=range(1,48)
minList=[]

###Get Daily Bike Counts for Past Year###
###Get Daily Bike Counts for Past Year###
###Get Daily Bike Counts for Past Year###
startDate=[]
counter=[]

for num in counterID:
	url = 'http://webservices.commuterpage.com/counters.cfc?wsdl&method=GetMinDates&CounterID='+str(num)
	r = requests.get(url)

	soup = BeautifulSoup(r.text)
	s=soup.getText()
	startDate.append(s)
minList.append(startDate)
minBC = pd.DataFrame(minList)
minBC.to_csv('minBC.csv')


