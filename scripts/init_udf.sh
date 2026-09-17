#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Building parse-ip UDF"
cd "$PROJECT_ROOT/udf/parse-ip"
mvn clean package

echo "==> Building parse-ua UDF"
cd "$PROJECT_ROOT/udf/parse-ua"
mvn clean package

cd "$PROJECT_ROOT"

echo "==> Uploading ip2region.xdb to HDFS"
docker cp \
  udf/parse-ip/ip2region.xdb \
  ad-datanode:/tmp/ip2region.xdb

docker exec ad-datanode \
  hdfs dfs -mkdir -p /ip2region

docker exec ad-datanode \
  hdfs dfs -put -f \
  /tmp/ip2region.xdb \
  /ip2region/ip2region.xdb

echo "==> UDF initialization complete"
