#!/bin/bash

do_date=$1

if [ -z "$do_date" ]; then
    echo "Usage: $0 <yyyy-MM-dd>"
    exit 1
fi

echo "========== DWD -> ClickHouse =========="
echo "do_date=${do_date}"

docker exec ad-spark spark-submit \
  --class com.atguigu.ad.spark.Hive2ClickHouse \
  --master 'local[*]' \
  /app/hive-to-clickhouse/target/hive-to-clickhouse-1.0-SNAPSHOT-jar-with-dependencies.jar \
  --hive_db ad \
  --hive_table dwd_ad_event_inc \
  --hive_partition "${do_date}" \
  --ck_url 'jdbc:clickhouse://ad-clickhouse:8123/ad_report?user=default&password=000000' \
  --ck_table dwd_ad_event_inc \
  --batch_size 10000