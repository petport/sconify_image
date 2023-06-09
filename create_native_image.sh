#!/bin/bash
#
# tasks performed:
#
# - creates a docker image of a simple Flask-based application running in native mode
#
# show what we do (-x), export all variables (-a), and abort of first error (-e)

set -x -a -e
trap "echo Unexpected error! See log above; exit 1" ERR

# CONFIG Parameters (might change)

export NATIVE_IMAGE=${NATIVE_IMAGE:-native_flask_restapi_image}
export BASE_IMAGE=${BASE_IMAGE:-alpine:3.17}

# Create a native Python image with the same version as the Scone curated image

docker build -t python-3.11-alpine3.17 -f Dockerfile-native-python .
# Create debug certificate

## note: this is not completely correct...

openssl req -x509 -newkey rsa:4096 -keyout flask.key -out flask.crt -days 365 -nodes -subj '/CN=api'
openssl req -x509 -newkey rsa:4096 -keyout redis.key -out redis.crt -days 365 -nodes -subj '/CN=redis'

# Create Dockerfile to create image

cat >Dockerfile <<EOF
FROM $BASE_IMAGE
ENV LANG C.UTF-8
COPY rest_api.py /app/rest_api.py
COPY flask.key /tls/flask.key
COPY flask.crt /tls/flask.crt
COPY requirements.txt /app/requirements.txt
RUN apk add --no-cache openssl ca-certificates pkgconfig wget python3 python3-dev py3-pip \
    && /usr/bin/pip3 install -r /app/requirements.txt 
CMD /usr/bin/python3 -B /app/rest_api.py
EOF

# create a native image for the flask service
docker build -t $NATIVE_IMAGE .

echo "OK"
