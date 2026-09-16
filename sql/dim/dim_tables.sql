CREATE DATABASE IF NOT EXISTS ad;

USE ad;

-- ============================================================
-- 1. 广告信息维度表
-- 来源：
--   ods_ads_info_full
--   ods_product_info_full
-- 粒度：一行一个广告
-- ============================================================

DROP TABLE IF EXISTS dim_ads_info_full;

CREATE EXTERNAL TABLE dim_ads_info_full
(
    ad_id         STRING COMMENT '广告id',
    ad_name       STRING COMMENT '广告名称',
    product_id    STRING COMMENT '广告产品id',
    product_name  STRING COMMENT '广告产品名称',
    product_price DECIMAL(16,2) COMMENT '广告产品价格',
    material_id   STRING COMMENT '素材id',
    material_url  STRING COMMENT '物料地址',
    group_id      STRING COMMENT '广告组id'
)
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/ad/dim/dim_ads_info_full'
TBLPROPERTIES ('orc.compress'='snappy');


-- ============================================================
-- 2. 平台信息维度表
-- 来源：
--   ods_platform_info_full
-- 粒度：一行一个平台
-- ============================================================

DROP TABLE IF EXISTS dim_platform_info_full;

CREATE EXTERNAL TABLE dim_platform_info_full
(
    id               STRING COMMENT '平台id',
    platform_name_en STRING COMMENT '平台名称(英文)',
    platform_name_zh STRING COMMENT '平台名称(中文)'
)
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/warehouse/ad/dim/dim_platform_info_full'
TBLPROPERTIES ('orc.compress'='snappy');