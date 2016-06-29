FROM niexiaohu/codis

ENV CODIS_HOME /opt/codis

COPY conf/config.ini $CODIS_HOME/codisconf/config.ini
COPY run.sh $CODIS_HOME/run.sh
RUN chmod a+x $CODIS_HOME/run.sh

EXPOSE 18087

CMD ["/opt/codis/run.sh"]
