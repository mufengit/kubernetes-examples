# Use the base images
FROM java:7

MAINTAINER xiaohu.nie <xiaohu.nie@baifendian.com>

ENV SRC_DIR /opt
ENV CODIS_HOME /opt/codis

ENV GOROOT /usr/local/go
ENV PATH=$PATH:$GOROOT/bin
ENV GOPATH=/opt/codis

RUN apt-get update && apt-get  install -y vim
RUN apt-get install -y net-tools
RUN apt-get install -y git


RUN curl -LO "https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz" \
 && tar xzvf go1.4.2.linux-amd64.tar.gz -C /usr/local/ \
 && rm -f go1.4.2.linux-amd64.tar.gz \
 
RUN go get -u -d github.com/CodisLabs/codis
RUN cp /opt/codis/bin/godep /opt/go/bin/godep
WORKDIR /opt/codis/src/github.com/CodisLabs/codis
RUN make
RUN make test

RUN mkdir -p /opt/codis/{logs,conf,data}/ 
RUN cp /opt/codis/src/github.com/CodisLabs/codis/bin/* /opt/codis/bin/  
RUN cp /opt/codis/src/github.com/CodisLabs/codis/config.ini /opt/local/codis/conf/config.ini 
RUN cp /opt/codis/src/github.com/CodisLabs/codis/extern/redis-2.8.21/src/redis-cli-2.8.21  /opt/local/codis/bin/redis-cli-2.8.21
RUN ln -s /opt/codis/bin/redis-cli-2.8.21 /opt/codis/redis-cli

