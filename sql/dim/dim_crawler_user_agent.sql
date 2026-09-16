USE ad;

DROP TABLE IF EXISTS dim_crawler_user_agent;

CREATE EXTERNAL TABLE dim_crawler_user_agent
(
    pattern       STRING COMMENT '正则表达式',
    addition_date STRING COMMENT '收录日期',
    url           STRING COMMENT '爬虫官方url',
    instances     ARRAY<STRING> COMMENT 'UA实例'
)
STORED AS ORC
LOCATION '/warehouse/ad/dim/dim_crawler_user_agent'
TBLPROPERTIES ('orc.compress' = 'snappy');


CREATE TEMPORARY TABLE tmp_crawler_user_agent
(
    pattern       STRING COMMENT '正则表达式',
    addition_date STRING COMMENT '收录日期',
    url           STRING COMMENT '爬虫官方url',
    instances     ARRAY<STRING> COMMENT 'UA实例'
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
STORED AS TEXTFILE
LOCATION '/warehouse/ad/tmp/tmp_crawler_user_agent';


INSERT OVERWRITE TABLE dim_crawler_user_agent
SELECT *
FROM tmp_crawler_user_agent;