#!/bin/bash

APP=ad

do_date=$2

if [ -z "$do_date" ]; then
    echo "Usage: $0 {dim_ads_info_full|dim_platform_info_full|all} YYYY-MM-DD"
    exit 1
fi

dim_platform_info_full="
INSERT OVERWRITE TABLE ${APP}.dim_platform_info_full
PARTITION (dt='$do_date')
SELECT
    id,
    platform_name_en,
    platform_name_zh
FROM ${APP}.ods_platform_info_full
WHERE dt='$do_date';
"

dim_ads_info_full="
SET hive.auto.convert.join=false;

INSERT OVERWRITE TABLE ${APP}.dim_ads_info_full
PARTITION (dt='$do_date')
SELECT
    ad.id,
    ad.ad_name,
    ad.product_id,
    pro.name,
    pro.price,
    ad.material_id,
    ad.material_url,
    ad.group_id
FROM
(
    SELECT
        id,
        ad_name,
        product_id,
        material_id,
        group_id,
        material_url
    FROM ${APP}.ods_ads_info_full
    WHERE dt='$do_date'
) ad
LEFT JOIN
(
    SELECT
        id,
        name,
        price
    FROM ${APP}.ods_product_info_full
    WHERE dt='$do_date'
) pro
ON ad.product_id = pro.id;
"

run_hive() {
    docker exec -i ad-hiveserver2 beeline \
        -u jdbc:hive2://localhost:10000/default \
        -e "$1"
}

case $1 in

"dim_ads_info_full")
    run_hive "$dim_ads_info_full"
    ;;

"dim_platform_info_full")
    run_hive "$dim_platform_info_full"
    ;;

"all")
    run_hive "$dim_ads_info_full"
    run_hive "$dim_platform_info_full"
    ;;

*)
    echo "Usage: $0 {dim_ads_info_full|dim_platform_info_full|all} [date]"
    exit 1
    ;;

esac