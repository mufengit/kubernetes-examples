FROM niexiaohu/codis

USER root
ENV CODIS_HOME /opt/codis

COPY conf/server.conf $CODIS_HOME/serverconf/conf/server_6900.conf
COPY run.sh $CODIS_HOME/run.sh
RUN chmod a+x $CODIS_HOME/run.sh

EXPOSE 6900
CMD ["/opt/codis/run.sh"]
