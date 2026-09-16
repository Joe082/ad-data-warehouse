FROM apache/dolphinscheduler-standalone-server:3.2.2

USER root

RUN apt-get update \
    && apt-get install -y docker.io wget \
    && wget -O /opt/dolphinscheduler/libs/standalone-server/mysql-connector-j-8.0.33.jar \
       https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar \
    && rm -rf /var/lib/apt/lists/*
    