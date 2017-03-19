FROM alpine

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add curl "libpq@edge<9.7" "postgresql-client@edge<9.7" "postgresql@edge<9.7" "postgresql-contrib@edge<9.7" "pwgen" "supervisor" "nginx" "redis" "sed" && \
    mkdir /docker-entrypoint-initdb.d && \
    curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu && \
    apk del curl && \
    rm -rf /var/cache/apk/*

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /
COPY picostats/picostats /
COPY config.json /
COPY supervisor.ini /etc/supervisor.d/
COPY redis.conf /etc/
COPY picostats/public /public
COPY picostats/templates /templates
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir /run/nginx

ENTRYPOINT ["/docker-entrypoint.sh"]

USER root

EXPOSE 80

CMD ["supervisord", "-n"]