FROM golang:1.9.3-alpine
LABEL maintainer="Siri Chongasamethaworn <siri@omise.co>"

RUN apk add --update --no-cache git

ADD . "/go/src/source.developers.google.com/golang/web"

WORKDIR /go/src/source.developers.google.com/golang/web
RUN go get ./...
RUN go install .

VOLUME /data
ENTRYPOINT [ "/go/bin/web" ]
