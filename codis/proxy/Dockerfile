FROM niexiaohu/codis

USER root
ENV CODIS_HOME /opt/codis

COPY conf/config.ini $CODIS_HOME/proxyconf/config.ini
COPY run.sh $CODIS_HOME/run.sh
RUN chmod a+x $CODIS_HOME/run.sh

EXPOSE 11000 19000


CMD ["/opt/codis/run.sh"]
