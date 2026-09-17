#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "========== Initialize ClickHouse =========="

docker exec -i ad-clickhouse clickhouse-client \
  --user default \
  --password 000000 \
  --multiquery \
  < "$PROJECT_ROOT/sql/clickhouse/init.sql"

echo "==> Verifying ClickHouse schema"

docker exec -i ad-clickhouse clickhouse-client \
  --user default \
  --password 000000 \
  -q "EXISTS DATABASE ad_report"

docker exec -i ad-clickhouse clickhouse-client \
  --user default \
  --password 000000 \
  -q "EXISTS TABLE ad_report.dwd_ad_event_inc"

echo "ClickHouse initialization complete."
