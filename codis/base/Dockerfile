# Use the base images
FROM golang:1.6
MAINTAINER xiaohu.nie <xiaohu.nie@baifendian.com>
RUN apt-get update -y

ENV CODIS_HOME /opt/codis

RUN go get -u -d github.com/CodisLabs/codis
# godep mostly works the same way as the go command line tool. If you have go 1.5.X and set GO15VENDOREXPERIMENT=1 or have go1.6.X (or devel) vendor/ is enabled. Unless you already have a Godeps/_workspace. This is a safety feature and godep warns you about this.
RUN export GO15VENDOREXPERIMENT=1
WORKDIR $GOPATH/src/github.com/CodisLabs/codis
RUN make && make test

RUN mkdir -p $CODIS_HOME/{bin,logs,conf,data}/ 
RUN cp -rf $GOPATH/src/github.com/CodisLabs/codis/bin/* /$CODIS_HOME/bin/  
RUN cp $GOPATH/src/github.com/CodisLabs/codis/config.ini   $CODIS_HOME/conf/config.ini 
RUN cp $GOPATH/src/github.com/CodisLabs/codis/extern/redis-test/conf/6379.conf  $CODIS_HOME/conf/config.ini 
RUN cp $GOPATH/src/github.com/CodisLabs/codis/extern/redis-2.8.21/src/redis-cli  $CODIS_HOME/bin/redis-cli


