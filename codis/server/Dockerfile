FROM niexiaohu/codis
MAINTAINER xiaohu.nie <xiaohu.nie@baifendian.com>

USER root

COPY conf/6379.conf $CODIS_HOME/conf/6379.conf
COPY run.sh $CODIS_HOME/run.sh
RUN chmod a+x $CODIS_HOME/run.sh

EXPOSE 6379
CMD ["/opt/codis/run.sh"]