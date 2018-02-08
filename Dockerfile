FROM golang:1.9.3-alpine
LABEL maintainer="Siri Chongasamethaworn <siri@omise.co>"

RUN apk add --update --no-cache git

ADD . "/go/src/github.com/KongZ/golangweb"

WORKDIR /go/src/github.com/KongZ/golangweb
RUN go get ./...
RUN go install .

VOLUME /data
ENTRYPOINT [ "/go/bin/golangweb" ]



#build
#run  -e [environment] (-p [image's port :os's port]) [imagename:tag]

#docker exec -it a4f12d281281 /bin/sh  , -it = i(intercative) t(terminal)

#Differ between RUN and ENTRYPOINT is
# RUN use for we need to prepare image
# ENTRYPOINT use for command next step when we have prepared image

#Should be priority step from huge process to small 
#when we edit command 4th and run again it will 1 - 3 will not run again but 4 - end will

#Remove trash with 'docker system prune'