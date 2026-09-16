#!/bin/bash

do_date=$1

if [ -z "$do_date" ]; then
    echo "Usage: $0 YYYY-MM-DD"
    exit 1
fi

echo "=========================================="
echo "Running DWD ETL for date: ${do_date}"
echo "=========================================="

docker cp \
    /opt/ad/sql/dwd/ad_ods_to_dwd.sql \
    ad-hiveserver2:/tmp/ad_ods_to_dwd.sql

docker exec -i ad-hiveserver2 \
    beeline \
    -u jdbc:hive2://localhost:10000/default \
    --hivevar do_date="${do_date}" \
    -f /tmp/ad_ods_to_dwd.sql