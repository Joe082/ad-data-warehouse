FROM ad-hadoop:3.3.6 AS hadoop

FROM eclipse-temurin:11-jdk

ARG FLUME_VERSION=1.11.0

RUN apt-get update \
    && apt-get install -y curl \
    && curl -fSL "https://archive.apache.org/dist/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz" -o /tmp/flume.tar.gz \
    && tar -xzf /tmp/flume.tar.gz -C /opt \
    && mv /opt/apache-flume-${FLUME_VERSION}-bin /opt/flume \
    && rm /tmp/flume.tar.gz \
    && rm -rf /var/lib/apt/lists/*

# Copy Hadoop from our existing Hadoop image
COPY --from=hadoop /opt/hadoop /opt/hadoop

ENV FLUME_HOME=/opt/flume
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH="${FLUME_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"

# Make Hadoop libraries available to Flume
ENV FLUME_CLASSPATH="/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/hdfs/lib/*"

WORKDIR /opt/flume