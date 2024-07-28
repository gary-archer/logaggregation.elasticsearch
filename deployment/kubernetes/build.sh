#!/bin/bash

####################################################
# Build resources used in the Elasticsearch init job
####################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Use a timestamp based tag and support both KIND and DockerHub repositories
#
TAG=$(date +%Y%m%d%H%M%S)
echo $TAG > ./dockertag.txt
if [ "$DOCKER_REPOSITORY" == "" ]; then
  DOCKER_IMAGE="elasticjob:$TAG"
else
  DOCKER_IMAGE="$DOCKER_REPOSITORY/elasticjob:$TAG"
fi

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
# On Windows, fix problems with trailing newline characters in Docker scripts downloaded from Git
#
if [ "$PLATFORM" == 'WINDOWS' ]; then
  sed -i 's/\r$//' ../shared/initdata.sh
fi

#
# Build a small Docker image containing curl and bash tools
#
docker build --no-cache -t "$DOCKER_IMAGE" .
if [ $? -ne 0 ]; then
  echo '*** Elastic job docker build problem encountered'
  exit 1
fi

#
# Push the docker image
#
if [ "$DOCKER_REPOSITORY" == "" ]; then
  kind load docker-image "$DOCKER_IMAGE" --name oauth
else
  docker image push "$DOCKER_IMAGE"
fi
if [ $? -ne 0 ]; then
  echo '*** Elastic job docker push problem encountered'
  exit 1
fi
