#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Building parse-ip UDF"
cd "$PROJECT_ROOT/udf/parse-ip"
mvn clean package -DskipTests

echo "==> Building parse-ua UDF"
cd "$PROJECT_ROOT/udf/parse-ua"
mvn clean package -DskipTests

cd "$PROJECT_ROOT"

echo "==> Uploading ip2region.xdb to HDFS"

docker compose exec -T namenode \
  hdfs dfs -mkdir -p /ip2region

docker compose exec -T namenode \
  hdfs dfs -put -f - /ip2region/ip2region.xdb \
  < "$PROJECT_ROOT/udf/parse-ip/ip2region.xdb"

echo "==> Verifying UDF artifacts"

test -f "$PROJECT_ROOT/udf/parse-ip/target/ad-hive-udf-parse-ip-1.0-SNAPSHOT-jar-with-dependencies.jar"
test -f "$PROJECT_ROOT/udf/parse-ua/target/ad-hive-udf-parse-ua-1.0-SNAPSHOT-jar-with-dependencies.jar"

docker compose exec -T namenode \
  hdfs dfs -test -e /ip2region/ip2region.xdb

echo "==> UDF initialization complete"
