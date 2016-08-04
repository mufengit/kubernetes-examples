#!/bin/bash

HOST_IP=`ip addr show eth0 | grep "inet " | awk '{print $2}'|awk -F'/' '{print $1}'`
sed -i "s/LOCAL_IP/${HOST_IP}/g" $CODIS_HOME/conf/config.ini
sed -i "s/ZOOKEEPER_IP/${ZOOKEEPER}/g" $CODIS_HOME/conf/config.ini
sed -i "s/PRODUCT_NAME/${PRODUCT}/g" $CODIS_HOME/conf/config.ini

$CODIS_HOME/bin/codis-config -c $CODIS_HOME/conf/config.ini -L $CODIS_HOME/logs/dashboard.log dashboard --addr=${HOST_IP}:18087 --http-log=$CODIS_HOME/logs/requests.log