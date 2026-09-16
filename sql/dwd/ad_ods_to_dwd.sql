USE ad;

SET hive.vectorized.execution.enabled=false;
SET hive.auto.convert.join=false;


-- =====================================================
-- 1. 粗解析原始日志
-- =====================================================

CREATE TEMPORARY TABLE coarse_parsed_log AS
SELECT
    parse_url(
        'http://www.example.com' || request_uri,
        'QUERY',
        't'
    ) AS event_time,

    split(
        parse_url(
            'http://www.example.com' || request_uri,
            'PATH'
        ),
        '/'
    )[3] AS event_type,

    parse_url(
        'http://www.example.com' || request_uri,
        'QUERY',
        'id'
    ) AS ad_id,

    split(
        parse_url(
            'http://www.example.com' || request_uri,
            'PATH'
        ),
        '/'
    )[2] AS platform,

    parse_url(
        'http://www.example.com' || request_uri,
        'QUERY',
        'ip'
    ) AS client_ip,

    IF(
        parse_url(
            'http://www.example.com' || request_uri,
            'QUERY',
            'ua'
        ) IS NOT NULL,

        reflect(
            'java.net.URLDecoder',
            'decode',
            parse_url(
                'http://www.example.com' || request_uri,
                'QUERY',
                'ua'
            ),
            'UTF-8'
        ),

        NULL
    ) AS client_ua,

    parse_url(
        'http://www.example.com' || request_uri,
        'QUERY',
        'os_type'
    ) AS client_os_type,

    parse_url(
        'http://www.example.com' || request_uri,
        'QUERY',
        'device_id'
    ) AS client_device_id

FROM ods_ad_log_inc
WHERE dt='${do_date}';


-- =====================================================
-- 2. IP + UA 精细解析
-- =====================================================

CREATE TEMPORARY TABLE fine_parsed_log AS
SELECT
    event_time,
    event_type,
    ad_id,
    platform,
    client_ip,
    client_ua,
    client_os_type,
    client_device_id,

    IF(
        client_ip IS NOT NULL
        AND client_ip != '',

        parse_ip(
            'hdfs://namenode:8020/ip2region/ip2region.xdb',
            client_ip
        ),

        NULL
    ) AS region_struct,

    IF(
        client_ua IS NOT NULL
        AND client_ua != '',

        parse_ua(client_ua),

        NULL
    ) AS ua_struct

FROM coarse_parsed_log;


-- =====================================================
-- 3. 高频访问 IP
-- 规则：同 IP + 同广告，5 分钟内超过 100 次
-- =====================================================

CREATE TEMPORARY TABLE high_speed_ip AS
SELECT DISTINCT
    client_ip
FROM
(
    SELECT
        event_time,
        client_ip,
        ad_id,

        COUNT(1) OVER
        (
            PARTITION BY client_ip, ad_id

            ORDER BY CAST(event_time AS BIGINT)

            RANGE BETWEEN
                300000 PRECEDING
                AND CURRENT ROW
        ) AS event_count_last_5min

    FROM coarse_parsed_log
)t1
WHERE event_count_last_5min > 100;


-- =====================================================
-- 4. 固定周期访问 IP
-- 规则：相同访问间隔连续出现 >= 5 次
-- =====================================================

CREATE TEMPORARY TABLE cycle_ip AS
SELECT DISTINCT
    client_ip
FROM
(
    SELECT
        client_ip,
        ad_id,
        s

    FROM
    (
        SELECT
            event_time,
            client_ip,
            ad_id,

            SUM(num) OVER
            (
                PARTITION BY client_ip, ad_id
                ORDER BY event_time
            ) AS s

        FROM
        (
            SELECT
                event_time,
                client_ip,
                ad_id,
                time_diff,

                IF(
                    LAG(time_diff, 1, 0) OVER
                    (
                        PARTITION BY client_ip, ad_id
                        ORDER BY event_time
                    ) != time_diff,
                    1,
                    0
                ) AS num

            FROM
            (
                SELECT
                    event_time,
                    client_ip,
                    ad_id,

                    LEAD(event_time, 1, 0) OVER
                    (
                        PARTITION BY client_ip, ad_id
                        ORDER BY event_time
                    ) - event_time AS time_diff

                FROM coarse_parsed_log
            )t1

        )t2

    )t3

    GROUP BY
        client_ip,
        ad_id,
        s

    HAVING COUNT(*) >= 5

)t4;


-- =====================================================
-- 5. 高频访问 Device
-- =====================================================

CREATE TEMPORARY TABLE high_speed_device AS
SELECT DISTINCT
    client_device_id
FROM
(
    SELECT
        event_time,
        client_device_id,
        ad_id,

        COUNT(1) OVER
        (
            PARTITION BY client_device_id, ad_id

            ORDER BY CAST(event_time AS BIGINT)

            RANGE BETWEEN
                300000 PRECEDING
                AND CURRENT ROW
        ) AS event_count_last_5min

    FROM coarse_parsed_log

    WHERE client_device_id != ''

)t1

WHERE event_count_last_5min > 100;


-- =====================================================
-- 6. 固定周期访问 Device
-- =====================================================

CREATE TEMPORARY TABLE cycle_device AS
SELECT DISTINCT
    client_device_id
FROM
(
    SELECT
        client_device_id,
        ad_id,
        s

    FROM
    (
        SELECT
            event_time,
            client_device_id,
            ad_id,

            SUM(num) OVER
            (
                PARTITION BY client_device_id, ad_id
                ORDER BY event_time
            ) AS s

        FROM
        (
            SELECT
                event_time,
                client_device_id,
                ad_id,
                time_diff,

                IF(
                    LAG(time_diff, 1, 0) OVER
                    (
                        PARTITION BY client_device_id, ad_id
                        ORDER BY event_time
                    ) != time_diff,
                    1,
                    0
                ) AS num

            FROM
            (
                SELECT
                    event_time,
                    client_device_id,
                    ad_id,

                    LEAD(event_time, 1, 0) OVER
                    (
                        PARTITION BY client_device_id, ad_id
                        ORDER BY event_time
                    ) - event_time AS time_diff

                FROM coarse_parsed_log

                WHERE client_device_id != ''

            )t1

        )t2

    )t3

    GROUP BY
        client_device_id,
        ad_id,
        s

    HAVING COUNT(*) >= 5

)t4;


-- =====================================================
-- 7. 维度关联 + 异常流量标记 + 写入 DWD
-- =====================================================
SELECT 'high_speed_ip' AS rule, COUNT(*) AS cnt
FROM high_speed_ip

UNION ALL

SELECT 'cycle_ip', COUNT(*)
FROM cycle_ip

UNION ALL

SELECT 'high_speed_device', COUNT(*)
FROM high_speed_device

UNION ALL

SELECT 'cycle_device', COUNT(*)
FROM cycle_device;

SELECT 'high_speed_ip' AS rule, COUNT(*) AS event_cnt
FROM fine_parsed_log e
JOIN high_speed_ip r
ON e.client_ip = r.client_ip

UNION ALL

SELECT 'cycle_ip', COUNT(*)
FROM fine_parsed_log e
JOIN cycle_ip r
ON e.client_ip = r.client_ip

UNION ALL

SELECT 'high_speed_device', COUNT(*)
FROM fine_parsed_log e
JOIN high_speed_device r
ON e.client_device_id = r.client_device_id

UNION ALL

SELECT 'cycle_device', COUNT(*)
FROM fine_parsed_log e
JOIN cycle_device r
ON e.client_device_id = r.client_device_id;




INSERT OVERWRITE TABLE dwd_ad_event_inc
PARTITION (dt='${do_date}')

SELECT
    CAST(event_time AS BIGINT),

    event_type,

    event.ad_id,
    ad_name,

    product_id,
    product_name,
    product_price,

    material_id,
    material_url,
    group_id,

    plt.id,
    platform_name_en,
    platform_name_zh,

    region_struct.country,
    region_struct.area,
    region_struct.province,
    region_struct.city,

    event.client_ip,
    event.client_device_id,

    IF(
        event.client_os_type != '',
        event.client_os_type,
        ua_struct.os
    ),

    NVL(ua_struct.osVersion, ''),

    NVL(ua_struct.browser, ''),
    NVL(ua_struct.browserVersion, ''),

    event.client_ua,

    IF(
        COALESCE(
            crawler.pattern,
            hsi.client_ip,
            ci.client_ip,
            hsd.client_device_id,
            cd.client_device_id
        ) IS NOT NULL,
        TRUE,
        FALSE
    ) AS is_invalid_traffic

FROM fine_parsed_log event


LEFT JOIN dim_crawler_user_agent crawler
ON event.client_ua REGEXP crawler.pattern


LEFT JOIN high_speed_ip hsi
ON event.client_ip = hsi.client_ip


LEFT JOIN cycle_ip ci
ON event.client_ip = ci.client_ip


LEFT JOIN high_speed_device hsd
ON event.client_device_id = hsd.client_device_id


LEFT JOIN cycle_device cd
ON event.client_device_id = cd.client_device_id


LEFT JOIN
(
    SELECT
        ad_id,
        ad_name,
        product_id,
        product_name,
        product_price,
        material_id,
        material_url,
        group_id

    FROM dim_ads_info_full

    WHERE dt='${do_date}'
) ad

ON event.ad_id = ad.ad_id


LEFT JOIN
(
    SELECT
        id,
        platform_name_en,
        platform_name_zh

    FROM dim_platform_info_full

    WHERE dt='${do_date}'
) plt

ON event.platform = plt.platform_name_en;