FROM eclipse-temurin:11-jre

WORKDIR /opt/module/ad_mock

COPY NginxDataGenerator-1.0-SNAPSHOT-jar-with-dependencies.jar .

COPY nginxLogGen.setting .

CMD ["java", "-jar", "NginxDataGenerator-1.0-SNAPSHOT-jar-with-dependencies.jar"]