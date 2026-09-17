#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo " Initializing AD Data Warehouse"
echo "=========================================="

# --------------------------------------------------
# 1. Wait for HDFS
# --------------------------------------------------

echo "[1/5] Waiting for HDFS..."

for i in {1..30}; do
    if docker compose exec -T namenode \
        hdfs dfs -ls / >/dev/null 2>&1
    then
        echo "HDFS is ready."
        break
    fi

    if [ "$i" -eq 30 ]; then
        echo "ERROR: HDFS did not become ready."
        docker compose logs --tail=100 namenode
        exit 1
    fi

    sleep 5
done

echo "Initializing HDFS directories and permissions..."
bash scripts/init_hdfs.sh


# --------------------------------------------------
# 2. Restart and wait for HiveServer2
# --------------------------------------------------

echo "[2/5] Recreating HiveServer2 after HDFS initialization..."
docker compose up -d --force-recreate hiveserver2

echo "Waiting for HiveServer2..."

for i in {1..30}; do
    if docker compose exec -T hiveserver2 \
        beeline \
        -u jdbc:hive2://localhost:10000/default \
        -e "SHOW DATABASES;" >/dev/null 2>&1
    then
        echo "HiveServer2 is ready."
        break
    fi

    if [ "$i" -eq 30 ]; then
        echo "ERROR: HiveServer2 did not become ready."
        docker compose logs --tail=100 hiveserver2
        exit 1
    fi

    sleep 5
done


# --------------------------------------------------
# 3. Hive schema
# --------------------------------------------------

echo "[3/5] Initializing Hive schema..."

bash scripts/init_hive.sh


# --------------------------------------------------
# 4. Hive UDFs
# --------------------------------------------------

echo "[4/5] Building and installing Hive UDFs..."

bash scripts/init_udf.sh


# --------------------------------------------------
# 5. ClickHouse
# --------------------------------------------------

echo "[5/5] Waiting for ClickHouse..."

for i in {1..30}; do
    if docker compose exec -T clickhouse \
        clickhouse-client \
        --user default \
        --password 000000 \
        -q "SELECT 1" >/dev/null 2>&1
    then
        echo "ClickHouse is ready."
        break
    fi

    if [ "$i" -eq 30 ]; then
        echo "ERROR: ClickHouse did not become ready."
        docker compose logs --tail=100 clickhouse
        exit 1
    fi

    sleep 5
done

echo "Initializing ClickHouse schema..."

bash scripts/init_clickhouse.sh


echo
echo "=========================================="
echo " Initialization complete."
echo "=========================================="
