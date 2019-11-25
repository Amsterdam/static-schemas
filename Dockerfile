FROM nginx:alpine

RUN apk add curl
RUN apk add git
RUN apk add bash

COPY default.conf /etc/nginx/conf.d/default.conf

RUN mkdir /app
COPY ./static-files.sh /app
WORKDIR /app
RUN /app/static-files.sh /usr/share/nginx/html

# Healthcheck
COPY health/index.html /usr/share/nginx/html/health/index.html
HEALTHCHECK --interval=60s --timeout=1s CMD curl --fail http://localhost:80/health/index.html || exit 1
