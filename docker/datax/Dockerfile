FROM eclipse-temurin:8-jdk

RUN apt-get update && \
    apt-get install -y python3 && \
    rm -rf /var/lib/apt/lists/*

COPY datax.tar.gz /tmp/datax.tar.gz

RUN mkdir -p /opt && \
    tar -xzf /tmp/datax.tar.gz -C /opt && \
    rm /tmp/datax.tar.gz

COPY datax-config-generator.jar /opt/gen_datax_config/datax-config-generator.jar

ENV DATAX_HOME=/opt/datax
ENV PATH=$PATH:$DATAX_HOME/bin

WORKDIR /opt/datax

CMD ["sleep", "infinity"]