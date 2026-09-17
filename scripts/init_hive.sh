#!/bin/bash
set -e

run_sql() {
    docker exec -i ad-hiveserver2 beeline \
        -u jdbc:hive2://localhost:10000/default \
        -f "$1"
}

run_sql /opt/ad/sql/ods/ods_tables.sql
run_sql /opt/ad/sql/dim/dim_tables.sql
run_sql /opt/ad/sql/dim/dim_crawler_user_agent.sql
run_sql /opt/ad/sql/dwd/dwd_tables.sql

echo "Hive initialization complete."
