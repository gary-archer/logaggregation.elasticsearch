#!/bin/bash

################################################################################
# A script to deploy Functionbeat to AWS to run as a Serverless Lambda
# This then ships logs for my APIs to Elasticsearch running as a managed service
# https://authguidance.com/cloud-elastic-search-setup
################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# The API key must be provided as an environment variable
#
if [ "$ELASTICSEARCH_API_KEY" == '' ]; then
  echo '*** The ELASTICSEARCH_API_KEY parameter must be provided'
  exit
fi

#
# Define other properties
#
RESOURCES_FOLDER='../../resources'
FUNCTIONBEAT_FOLDER='functionbeat-8.11.2-darwin-x86_64'
FUNCTIONBEAT_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/beats/functionbeat/$FUNCTIONBEAT_FOLDER.tar.gz"

#
# Download functionbeat
#
echo 'Downloading functionbeat ...'
cd ../..
rm -rf resources 2>/dev/null
mkdir resources
cd resources
HTTP_STATUS=$(curl -s -O "$FUNCTIONBEAT_DOWNLOAD_URL" -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered downloading functionbeat: $HTTP_STATUS"
  exit
fi

#
# Unpack resources
#
echo 'Unzipping functionbeat ...'
tar xf "$FUNCTIONBEAT_FOLDER.tar.gz" 2>/dev/null
if [ $? -ne 0 ]; then
  echo '*** Problem encountered unzipping functionbeat'
  exit
fi
cd "$FUNCTIONBEAT_FOLDER"

#
# Update the configuration by replacing the functionbeat.yml file
#
echo 'Updating functionbeat configuration ...'
FUNCTIONBEAT_TEMPLATE_FILE='../../deployment/aws-serverless/functionbeat.8.11.2.template.yml'
export ELASTICSEARCH_API_KEY
envsubst < "$FUNCTIONBEAT_TEMPLATE_FILE" > functionbeat.yml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered running the envsubst tool to update configuration'
  exit
fi

#
# Finally recreate the AWS lambda and use a name not greater than 11 characters 
# https://github.com/elastic/beats/issues/30270
#
echo 'Uploading AWS logshipper lambda ...'
./functionbeat -v -e -d "*" remove logshipper
./functionbeat -v -e -d "*" deploy logshipper
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating functionbeat lambda in AWS'
  exit
fi
