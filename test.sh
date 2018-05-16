#!/bin/bash

if [ "$1" == "restart" ] || [ "$1" == "stop" ]
then
	docker stop es-geo-test
	
	if [ "$1" == "stop" ]
	then
		exit 0
	fi
fi

ALREADY_RUNNING=`docker inspect -f {{.State.Running}} es-geo-test`

if [ $ALREADY_RUNNING == "true" ]  
then
	echo "elastic search demo is already running, stop it first for a clean environment"
	exit 1
else 
	docker rm es-geo-test # remove the old image
fi

ES_CONTAINER=`docker run --name "es-geo-test" -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.2.4`

IS_RUNNING=false

for (( i=1; i<=10; i++)) 
do
	echo "Attempt $i to check elastic search is running"
	IS_RUNNING=`docker inspect -f {{.State.Running}} $ES_CONTAINER`
	
	if [ $IS_RUNNING ] 
	then
		ES_STARTED=$(curl --write-out %{http_code} --silent --output /dev/null localhost:9200)
		if [ $ES_STARTED == "200" ]
		then
			echo "elastic search started"
			break
		else
			sleep 5
		fi
	fi
done

if [ $IS_RUNNING == "false" ]
then
	echo "Could not start docker"
	exit 1
elif [ $ES_STARTED != "200" ]
then
	echo "Elastic search did not start fast enough"
	exit 1
fi

# import data
python3 dataToEs.py
