#!/bin/bash

#################################################################################################
# A script to deploy the Elastic Stack to Docker Compose on a development computer
# https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-stack-docker.html
#################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Get the platform
#
case "$(uname -s)" in

  Darwin)
    PLATFORM="MACOS"
 	;;

  MINGW64*)
    PLATFORM="WINDOWS"
	;;

  Linux)
    PLATFORM="LINUX"
	;;
esac

#
# Elastic Stack parameters
#
ELASTIC_URL='https://logs.authsamples-dev.com:9200'
ELASTIC_USER='elastic'
ELASTIC_PASSWORD='Password1'
KIBANA_SYSTEM_USER='kibana_system'
KIBANA_PASSWORD='Password1'
SCHEMA_FILE_PATH='../data/schema.json'
INGESTION_PIPELINE_FILE_PATH='../data/ingestion-pipeline-cloudnative.json'

#
# Download development SSL certificates if required
#
./downloadcerts.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Export environment variables to the Docker Compose file and scripts
#
export ELASTIC_URL
export ELASTIC_USER
export ELASTIC_PASSWORD
export KIBANA_SYSTEM_USER
export KIBANA_PASSWORD
export SCHEMA_FILE_PATH
export INGESTION_PIPELINE_FILE_PATH

#
# Run the docker deployment to deploy Elasticsearch, Kibana and Filebeat
#
echo 'Deploying the Elastic Stack ...'
docker compose --project-name elasticstack up --force-recreate --detach
if [ $? -ne 0 ]; then
  echo "Problem encountered running Docker image"
  exit 1
fi

#
# Run the script to create the initial Elasticsearch data
#
../shared/initdata.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Wait a little to ensure that Kibana is ready
#
sleep 10

#
# Open the Kibana URL and login with the following test credentials
# - elastic
# - Password1
#
KIBANA_URL='http://logs.authsamples-dev.com:5601/app/dev_tools#/console'
if [ "$PLATFORM" == 'MACOS' ]; then

  open "$KIBANA_URL"

elif [ "$PLATFORM" == 'WINDOWS' ]; then

  start "$KIBANA_URL"

elif [ "$PLATFORM" == 'LINUX' ]; then

  xdg-open "$KIBANA_URL"

fi
