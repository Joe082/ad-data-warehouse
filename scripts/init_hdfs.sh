#!/bin/bash
set -e

echo "========== Initialize HDFS =========="

docker compose exec -T namenode hdfs dfs -mkdir -p /tmp
docker compose exec -T namenode hdfs dfs -chmod 1777 /tmp

docker compose exec -T namenode hdfs dfs -mkdir -p /user/hive/warehouse
docker compose exec -T namenode hdfs dfs -chown -R hive:supergroup /user/hive
docker compose exec -T namenode hdfs dfs -chmod -R 775 /user/hive

docker compose exec -T namenode hdfs dfs -mkdir -p /warehouse/ad
docker compose exec -T namenode hdfs dfs -chown -R hive:supergroup /warehouse
docker compose exec -T namenode hdfs dfs -chmod -R 775 /warehouse

docker compose exec -T namenode hdfs dfs -mkdir -p /origin_data
docker compose exec -T namenode hdfs dfs -chown -R hive:supergroup /origin_data
docker compose exec -T namenode hdfs dfs -chmod -R 775 /origin_data

echo "HDFS initialization complete."
