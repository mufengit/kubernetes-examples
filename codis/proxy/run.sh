#!/bin/bash

HOST_IP=`ip addr show eth0 | grep "inet " | awk '{print $2}'|awk -F'/' '{print $1}'`

sed -i "s/ZOOKEEPER_IP/${ZOOKEEPER}/g" $CODIS_HOME/proxyconf/config.ini
sed -i "s/DASHBOARD_ADDR/${DASHBOARD}/g" $CODIS_HOME/proxyconf/config.ini
sed -i "s/PRODUCT_NAME/${PRODUCT}/g" $CODIS_HOME/proxyconf/config.ini
sed -i "s/PROXY_ID/${PROXYID}/g" $CODIS_HOME/proxyconf/config.ini

$CODIS_HOME/bin/codis-proxy -c $CODIS_HOME/conf/config.ini -L ${CODIS_HOME}/logs/proxy.log  --cpu=${CPU} --addr=${HOST_IP}:19000 --http-addr=${HOST_IP}:11000 