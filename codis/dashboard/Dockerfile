FROM niexiaohu/codis
MAINTAINER xiaohu.nie <xiaohu.nie@baifendian.com>

COPY conf/config.ini $CODIS_HOME/conf/config.ini
COPY run.sh $CODIS_HOME/run.sh
RUN chmod a+x $CODIS_HOME/run.sh

EXPOSE 18087

CMD ["/opt/codis/run.sh"]