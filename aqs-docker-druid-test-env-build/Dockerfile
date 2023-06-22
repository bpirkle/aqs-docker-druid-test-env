FROM adoptopenjdk/openjdk11:debian-jre

LABEL authors="Bill Pirkle <bpirkle@wikimedia.org>"

WORKDIR /druid

ENV DRUID_VERSION 0.20.2
ENV DRUID_ARCHIVE apache-druid-$DRUID_VERSION-bin.tar.gz
ENV DRUID_DIR /druid/apache-druid-${DRUID_VERSION}

# Add various things we need, download druid, remove unnecessary files, and do other setup
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && apt-get install -y --no-install-recommends netcat \
    && rm -rf /var/lib/apt/lists/* \
    && curl --output $DRUID_ARCHIVE https://archive.apache.org/dist/druid/$DRUID_VERSION/$DRUID_ARCHIVE \
    && tar -xzf $DRUID_ARCHIVE \
    && rm $DRUID_ARCHIVE \
    && rm -rf $DRUID_DIR/extensions \
    && rm -rf $DRUID_DIR/hadoop-dependencies \
    && rm -rf $DRUID_DIR/quickstart \
    && addgroup --system druid \
    && adduser --system druid --ingroup druid \
    && chown -R druid $DRUID_DIR \
    && mkdir /data \
    && chown -R druid /data

# Switch to Druid user
USER druid

COPY ["./run.sh", "$DRUID_DIR/run.sh"]
COPY ["./log4j2.properties", "$DRUID_DIR/log4j2.properties"]
COPY ["./test-data.csv", "/data/test-data.csv"]
COPY ["./test-data_spec.json", "/data/test-data_spec.json"]
COPY ["./ingest.sh", "$DRUID_DIR/ingest.sh"]

ENV CLUSTER_SIZE micro-quickstart
ENV LOG4J_PROPERTIES_FILE ${DRUID_DIR}/log4j2.properties
ENV ENABLE_JAVASCRIPT true

ENV START_MIDDLE_MANAGER true

# Ingest the rows.
RUN mkdir -p $DRUID_DIR/var/tmp \
    && $DRUID_DIR/ingest.sh

ENV CLUSTER_SIZE nano-quickstart
ENV START_MIDDLE_MANAGER false

# coordinator/overlord
EXPOSE 8081
# broker
EXPOSE 8082
# historical
EXPOSE 8083
# router
EXPOSE 8888
# middle manager
EXPOSE 8091

ENTRYPOINT $DRUID_DIR/run.sh
