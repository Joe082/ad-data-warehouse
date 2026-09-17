# ---------- Hadoop ----------
FROM ad-hadoop:3.3.6 AS hadoop


# ---------- Build Flume interceptor ----------
FROM maven:3.9-eclipse-temurin-11 AS interceptor-builder

WORKDIR /build

COPY flume-interceptor/pom.xml .
COPY flume-interceptor/src ./src

RUN mvn -q -DskipTests package


# ---------- Flume runtime ----------
FROM eclipse-temurin:11-jdk

ARG FLUME_VERSION=1.11.0

RUN apt-get update \
    && apt-get install -y curl \
    && curl -fSL \
       "https://archive.apache.org/dist/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz" \
       -o /tmp/flume.tar.gz \
    && tar -xzf /tmp/flume.tar.gz -C /opt \
    && mv /opt/apache-flume-${FLUME_VERSION}-bin /opt/flume \
    && rm /tmp/flume.tar.gz \
    && rm -rf /var/lib/apt/lists/*

# Hadoop
COPY --from=hadoop /opt/hadoop /opt/hadoop

# Custom interceptor
COPY --from=interceptor-builder \
    /build/target/flume-interceptor-1.0-SNAPSHOT.jar \
    /opt/flume/lib/flume-interceptor.jar

ENV FLUME_HOME=/opt/flume
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH="${FLUME_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"

ENV FLUME_CLASSPATH="/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/hdfs/lib/*"

WORKDIR /opt/flume