#!/bin/bash

TABLE=$1
DO_DATE=$2

if [ -z "$DO_DATE" ]; then
    echo "Usage: $0 {product|ads|server_host|ads_platform|platform_info|all} YYYY-MM-DD"
    exit 1
fi

sync_table() {
    TABLE_NAME=$1
    TARGET_DIR="/origin_data/ad/db/${TABLE_NAME}_full/${DO_DATE}"
    TABLE_DIR="/origin_data/ad/db/${TABLE_NAME}_full"
    JOB_FILE="/opt/datax/job/import/ad.${TABLE_NAME}.json"

    echo "========================================"
    echo "同步表: ${TABLE_NAME}"
    echo "目标路径: ${TARGET_DIR}"
    echo "========================================"

    # 如果目录已经存在，删除旧数据
    docker compose exec -T namenode \
        hdfs dfs -rm -r -f "${TARGET_DIR}" 2>/dev/null || true

    # 创建当天目录
    docker compose exec -T namenode \
        hdfs dfs -mkdir -p "${TARGET_DIR}"

    # 执行 DataX
    docker exec ad-datax \
        python3 /opt/datax/bin/datax.py \
        -p"-Dtargetdir=${TARGET_DIR}" \
        "${JOB_FILE}"

    # 让 Hive LOAD DATA 可以移动该目录
    docker compose exec -T namenode \
        hdfs dfs -chown -R hive:supergroup "${TABLE_DIR}"

    docker compose exec -T namenode \
        hdfs dfs -chmod -R 775 "${TABLE_DIR}"
}

case "$TABLE" in
    product)
        sync_table product
        ;;
    ads)
        sync_table ads
        ;;
    server_host)
        sync_table server_host
        ;;
    ads_platform)
        sync_table ads_platform
        ;;
    platform_info)
        sync_table platform_info
        ;;
    all)
        sync_table product
        sync_table ads
        sync_table server_host
        sync_table ads_platform
        sync_table platform_info
        ;;
    *)
        echo "Usage: $0 {product|ads|server_host|ads_platform|platform_info|all} [date]"
        exit 1
        ;;
esac