CREATE DATABASE IF NOT EXISTS ad;

USE ad;

-- 1. 广告信息表
DROP TABLE IF EXISTS ods_ads_info_full;

CREATE EXTERNAL TABLE ods_ads_info_full
(
    id           STRING COMMENT '广告编号',
    product_id   STRING COMMENT '产品id',
    material_id  STRING COMMENT '素材id',
    group_id     STRING COMMENT '广告组id',
    ad_name      STRING COMMENT '广告名称',
    material_url STRING COMMENT '素材地址'
)
    partitioned by (dt STRING)
    row format delimited fields terminated by '\t'
    location '/warehouse/ad/ods/ods_ads_info_full';


-- 2. 推广平台表
DROP TABLE IF EXISTS ods_platform_info_full;

CREATE EXTERNAL TABLE ods_platform_info_full
(
    id               STRING COMMENT '平台id',
    platform_name_en STRING COMMENT '平台名称(英文)',
    platform_name_zh STRING COMMENT '平台名称(中文)'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/ad/ods/ods_platform_info_full';


-- 3. 产品表
DROP TABLE IF EXISTS ods_product_info_full;

CREATE EXTERNAL TABLE ods_product_info_full
(
    id    STRING COMMENT '产品id',
    name  STRING COMMENT '产品名称',
    price DECIMAL(16,2) COMMENT '产品价格'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/ad/ods/ods_product_info_full';


-- 4. 广告投放表
DROP TABLE IF EXISTS ods_ads_platform_full;

CREATE EXTERNAL TABLE ods_ads_platform_full
(
    id          STRING COMMENT '编号',
    ad_id       STRING COMMENT '广告id',
    platform_id STRING COMMENT '平台id',
    create_time STRING COMMENT '创建时间',
    cancel_time STRING COMMENT '取消时间'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/ad/ods/ods_ads_platform_full';


-- 5. 日志服务器列表
DROP TABLE IF EXISTS ods_server_host_full;

CREATE EXTERNAL TABLE ods_server_host_full
(
    id   STRING COMMENT '编号',
    ipv4 STRING COMMENT 'ipv4地址'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/ad/ods/ods_server_host_full';


-- 6. 广告监测日志
DROP TABLE IF EXISTS ods_ad_log_inc;

CREATE EXTERNAL TABLE ods_ad_log_inc
(
    time_local     STRING COMMENT '日志服务器收到请求的时间',
    request_method STRING COMMENT 'HTTP请求方法',
    request_uri    STRING COMMENT '请求路径',
    status         STRING COMMENT '日志服务器响应状态',
    server_addr    STRING COMMENT '日志服务器自身ip'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\u0001'
LOCATION '/warehouse/ad/ods/ods_ad_log_inc';