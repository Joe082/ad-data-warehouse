FROM eclipse-temurin:8-jdk

ARG DATAX_URL=https://datax-opensource.oss-cn-hangzhou.aliyuncs.com/202308/datax.tar.gz

RUN apt-get update && \
    apt-get install -y python3 curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSL "${DATAX_URL}" -o /tmp/datax.tar.gz && \
    mkdir -p /opt && \
    tar -xzf /tmp/datax.tar.gz -C /opt && \
    rm /tmp/datax.tar.gz

COPY datax-config-generator.jar /opt/gen_datax_config/datax-config-generator.jar

ENV DATAX_HOME=/opt/datax
ENV PATH=$PATH:$DATAX_HOME/bin

WORKDIR /opt/datax

CMD ["sleep", "infinity"]