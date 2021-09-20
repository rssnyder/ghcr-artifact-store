#!/bin/bash

# arguments: <artifact>

if [ -z "$REGISTRY_USER" ]
then
      REGISTRY_USER=$GITHUB_ACTOR
fi

if [ -z "$METHOD" ]
then
      METHOD="GET"
fi

if [ -z "$IMAGE" ]
then
      IMAGE="ghcr.io/$GITHUB_REPOSITORY"
fi

if [ -z "$TAG" ]
then
      TAG="artifacts"
fi

if [ "$1" ]
then
      ARTIFACT=$1
fi

# Create image name
IMAGE_NAME="$IMAGE:$TAG"

echo "--Targeting: $IMAGE_NAME\n--User: $REGISTRY_USER\n--Dir: $PWD"

# Log into ghcr
echo $TOKEN | docker login ghcr.io -u $REGISTRY_USER --password-stdin

if [ "$METHOD" = "GET" ]
then
    echo "--GET $ARTIFACT"

    # Pull docker image from ghcr
    docker pull $IMAGE_NAME

    # Create instance of image
    ID=$(docker create $IMAGE_NAME)

    # Copy saved file
    docker cp $ID:/$ARTIFACT ./$ARTIFACT

elif [ "$METHOD" = "PUT" ]
then
    echo "--PUT $ARTIFACT"

    # Pull docker image from ghcr, or bootstrap image
    docker pull $IMAGE_NAME

    # Create dockerfile
    if [ $? ]
    then
        echo "from busybox" > Dockerfile
    else
        echo "from $IMAGE_NAME" > Dockerfile
    fi

    echo "ARG ARTIFACT" >> Dockerfile
    echo "COPY $ARTIFACT ./$ARTIFACT" >> Dockerfile

    cat Dockerfile

    # Add file to image
    docker build -t $IMAGE_NAME --build-arg ARTIFACT=$ARTIFACT .

    # Upload new version
    docker push $IMAGE_NAME

else
    echo "Allowed methods: GET, PUT"
fi
