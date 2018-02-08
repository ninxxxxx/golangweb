FROM golang:1.9.3-alpine
LABEL maintainer="Siri Chongasamethaworn <siri@omise.co>"

RUN apk add --update --no-cache git

ADD . "/go/src/github.com/KongZ/golangweb"

WORKDIR /go/src/github.com/KongZ/golangweb
RUN go get ./...
RUN go install .

VOLUME /data

ENTRYPOINT [ "/go/bin/golangweb" ]