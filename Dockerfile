FROM alpine:3.17
ENV LANG C.UTF-8
COPY rest_api.py /app/rest_api.py
COPY flask.key /tls/flask.key
COPY flask.crt /tls/flask.crt
COPY requirements.txt /app/requirements.txt
RUN apk add --no-cache openssl ca-certificates pkgconfig wget python3 python3-dev py3-pip     && /usr/bin/pip3 install -r /app/requirements.txt 
CMD /usr/bin/python3 -B /app/rest_api.py
