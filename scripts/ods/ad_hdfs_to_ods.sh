#!/bin/bash

APP=ad
DO_DATE=$2

if [ -z "$DO_DATE" ]; then
    echo "Usage: $0 {table|all} YYYY-MM-DD"
    exit 1
fi

get_source_path() {
  case "$1" in
    ods_ads_info_full)
      echo "/origin_data/ad/db/ads_full"
      ;;
    ods_platform_info_full)
      echo "/origin_data/ad/db/platform_info_full"
      ;;
    ods_product_info_full)
      echo "/origin_data/ad/db/product_full"
      ;;
    ods_ads_platform_full)
      echo "/origin_data/ad/db/ads_platform_full"
      ;;
    ods_server_host_full)
      echo "/origin_data/ad/db/server_host_full"
      ;;
    ods_ad_log_inc)
      echo "/origin_data/ad/log/ad_log"
      ;;
  esac
}

load_data() {
  SQL=""

  for TABLE in "$@"
  do
    BASE_PATH=$(get_source_path "$TABLE")
    SOURCE_PATH="${BASE_PATH}/${DO_DATE}"

    echo "========================================"
    echo "Table:  $TABLE"
    echo "Source: $SOURCE_PATH"
    echo "========================================"

    docker exec ad-namenode hdfs dfs -test -e "$SOURCE_PATH"

    if [ $? -eq 0 ]; then
      SQL="${SQL}
LOAD DATA INPATH '${SOURCE_PATH}'
OVERWRITE INTO TABLE ${APP}.${TABLE}
PARTITION(dt='${DO_DATE}');
"
    else
      echo "Skip: $SOURCE_PATH does not exist"
    fi
  done

  if [ -n "$SQL" ]; then
    docker exec -i ad-hiveserver2 beeline \
      -u jdbc:hive2://localhost:10000/default \
      -e "$SQL"
  fi
}

case "$1" in
  ods_ads_info_full)
    load_data ods_ads_info_full
    ;;
  ods_platform_info_full)
    load_data ods_platform_info_full
    ;;
  ods_product_info_full)
    load_data ods_product_info_full
    ;;
  ods_ads_platform_full)
    load_data ods_ads_platform_full
    ;;
  ods_server_host_full)
    load_data ods_server_host_full
    ;;
  ods_ad_log_inc)
    load_data ods_ad_log_inc
    ;;
  all)
    load_data \
      ods_ads_info_full \
      ods_platform_info_full \
      ods_product_info_full \
      ods_ads_platform_full \
      ods_server_host_full \
      ods_ad_log_inc
    ;;
  *)
    echo "Usage: $0 {table|all} [date]"
    exit 1
    ;;
esac