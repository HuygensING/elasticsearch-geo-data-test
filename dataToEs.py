import json
from pprint import pprint
import requests
import sys

index_name="geo_data"
type_name="feature"
index_uri="http://elastic:changeme@localhost:9200/" + index_name
type_uri= index_uri + "/" + type_name


headers = {"Content-type": "application/json"}

# create mapping
mapping = { 
	"mappings": {
		type_name: {
			"properties": {
				"geometry.coordinates": {
					"type": "geo_point"
				}
			}
		}
		
	}
}

#pprint(mapping)

request_mapping = json.dumps(mapping)
response = requests.put(index_uri, data=request_mapping, headers=headers)
if not response.ok:
	print("mapping failed" + response.text)
	sys.exit()

# read data from disk
with open ("testData.json") as raw:
	data = json.load(raw)

# index data
print("start import data")
for value in data["features"]:
	request_data = json.dumps(value)
	response = requests.post(type_uri, data=request_data, headers=headers)
	pprint(response.json())
	#break
