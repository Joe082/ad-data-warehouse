CREATE DATABASE IF NOT EXISTS ad_report;

CREATE TABLE IF NOT EXISTS ad_report.dwd_ad_event_inc
(
    event_time Int64,
    event_type String,
    ad_id String,
    ad_name String,
    ad_product_id String,
    ad_product_name String,
    ad_product_price Decimal(16, 2),
    ad_material_id String,
    ad_material_url String,
    ad_group_id String,
    platform_id String,
    platform_name_en String,
    platform_name_zh String,
    client_country String,
    client_area String,
    client_province String,
    client_city String,
    client_ip String,
    client_device_id String,
    client_os_type String,
    client_os_version String,
    client_browser_type String,
    client_browser_version String,
    client_user_agent String,
    is_invalid_traffic UInt8
)
ENGINE = MergeTree()
ORDER BY (event_time, ad_id);


