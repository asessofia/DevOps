FROM openshift/base-centos7

# common env settings
#ENV REDIS_VERSION=3.2.8 \
ENV REDIS_VERSION=4.0.8 \
    REDIS_CONFIG_PATH=/etc/redis/redis.conf

# expose the redis port
EXPOSE 6379

# set some labels for openshift
LABEL io.k8s.description="Redis 3 KeyValue store" \
      io.k8s.display-name="Redis 3" \
      io.openshift.expose-services="6379:redis" \
      io.openshift.tags="builder,redis"

USER root

# install redis
RUN yum -y install bind-utils && \
    cd /tmp && \
    wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz && \
    tar xvzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make && \
    make install && \
    cp -f src/redis-sentinel /usr/local/bin && \
    mkdir -p /etc/redis && \
    cp -f *.conf /etc/redis && \
    rm -rf /tmp/redis-stable* && \
    chmod -R a+rwx /etc/redis/redis.conf

#RUN chmod a+xwr /proc/sys/net/core/somaxconn

# disable THP for better redis performance
RUN echo "never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
RUN echo "sysctl -w net.core.somaxconn=65535" >> /etc/rc.local

#RUN echo "2048" > /proc/sys/net/core/somaxconn

# copy our custom redis config
COPY ./config/* /usr/local/bin/
RUN chmod 777 /usr/local/bin/*

# create a data storage volume
RUN mkdir /data && chmod -R a+rwx /data
VOLUME ["/data"]
#RUN chmod +x /etc/rc.local


# execute the redis server with our custom config
ENTRYPOINT /usr/local/bin/startredis
# openshift requires user 1001
USER 1001
