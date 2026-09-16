USE ad;

DROP TABLE IF EXISTS dwd_ad_event_inc;

CREATE EXTERNAL TABLE dwd_ad_event_inc
(
    event_time             BIGINT COMMENT '事件时间',
    event_type             STRING COMMENT '事件类型',

    ad_id                  STRING COMMENT '广告id',
    ad_name                STRING COMMENT '广告名称',

    ad_product_id          STRING COMMENT '商品id',
    ad_product_name        STRING COMMENT '商品名称',
    ad_product_price       DECIMAL(16,2) COMMENT '商品价格',

    ad_material_id         STRING COMMENT '素材id',
    ad_material_url        STRING COMMENT '素材url',
    ad_group_id            STRING COMMENT '广告组id',

    platform_id            STRING COMMENT '平台id',
    platform_name_en       STRING COMMENT '平台英文名',
    platform_name_zh       STRING COMMENT '平台中文名',

    client_country         STRING COMMENT '国家',
    client_area            STRING COMMENT '区域',
    client_province        STRING COMMENT '省份',
    client_city            STRING COMMENT '城市',

    client_ip              STRING COMMENT '客户端ip',
    client_device_id       STRING COMMENT '设备id',

    client_os_type         STRING COMMENT '操作系统类型',
    client_os_version      STRING COMMENT '操作系统版本',

    client_browser_type    STRING COMMENT '浏览器类型',
    client_browser_version STRING COMMENT '浏览器版本',

    client_user_agent      STRING COMMENT 'user agent',

    is_invalid_traffic     BOOLEAN COMMENT '是否异常流量'
)
PARTITIONED BY
(
    dt STRING COMMENT '日期'
)
STORED AS ORC
LOCATION '/warehouse/ad/dwd/dwd_ad_event_inc'
TBLPROPERTIES ('orc.compress' = 'snappy');