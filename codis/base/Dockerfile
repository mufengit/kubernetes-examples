# Use the base images
FROM java:7

MAINTAINER xiaohu.nie <xiaohu.nie@baifendian.com>

ENV SRC_DIR /opt
ENV CODIS_HOME /opt/codis

RUN apt-get update && apt-get  install -y vim
RUN apt-get install -y net-tools
RUN unzip codis-master.zip
ADD codis-master $SRC_DIR/codis
