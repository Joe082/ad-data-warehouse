# ---------- Build Spark application ----------
FROM maven:3.9-eclipse-temurin-8 AS spark-app-builder

WORKDIR /build

COPY spark/hive-to-clickhouse/pom.xml .
COPY spark/hive-to-clickhouse/src ./src

RUN mvn -q -DskipTests package


# ---------- Spark runtime ----------
FROM eclipse-temurin:8-jre

ENV SPARK_VERSION=3.3.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

RUN apt-get update \
    && apt-get install -y curl bash procps \
    && curl -fSL \
       https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
       -o /tmp/spark.tgz \
    && tar -xzf /tmp/spark.tgz -C /opt \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm /tmp/spark.tgz \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/hive-to-clickhouse/target

COPY --from=spark-app-builder \
    /build/target/hive-to-clickhouse-1.0-SNAPSHOT-jar-with-dependencies.jar \
    /app/hive-to-clickhouse/target/hive-to-clickhouse-1.0-SNAPSHOT-jar-with-dependencies.jar

WORKDIR /app

CMD ["bash"]