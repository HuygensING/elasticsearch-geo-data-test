import json
import requests
from pprint import pprint

es_uri='http://elastic:changeme@localhost:9200/index/type'

with open ('testData.json') as raw:
	data = json.load(raw)

for value in data['features']:
	request_data = json.dumps(value)
	headers = {'Content-type': 'application/json'}
	response = requests.post(es_uri, data=request_data, headers=headers)
	pprint(response.json())
	#break
