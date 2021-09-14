FROM timescale/timescaledb:1.4.1-pg10
# Install python 3.9.6
COPY *.sh ./
RUN sh build-deps.sh && sh install_python.sh \
    && python3 --version \
    && apk del --no-network .build-deps \
    && rm -f *.sh \
    && apk update && apk add --no-cache --virtual .patroni-deps gcc musl-dev linux-headers python3-dev postgresql-dev \
    && pip install --no-cache-dir psycopg2 kazoo patroni[zookeeper] \
    && apk del --no-network .patroni-deps

