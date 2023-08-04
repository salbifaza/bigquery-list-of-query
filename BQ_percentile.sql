WITH get_data AS (
SELECT 
      inserted_at
    , order_at
    , TIMESTAMP_DIFF(order_at, inserted_at, SECOND) AS insert_to_order
FROM order
)

, percentile AS (
SELECT DISTINCT
      PERCENTILE_DISC(insert_to_order, 0.50) OVER() AS per50
    , PERCENTILE_DISC(insert_to_order, 0.75) OVER() AS per75
    , PERCENTILE_DISC(insert_to_order, 0.90) OVER() AS per90
    , PERCENTILE_DISC(insert_to_order, 0.95) OVER() AS per95
    , PERCENTILE_DISC(insert_to_order, 0.98) OVER() AS per98
FROM get_data
)

, transform AS (
SELECT 
    -- metode 1
      TIME(TIMESTAMP_SECONDS(per50)) AS per50
    , TIME(TIMESTAMP_SECONDS(per75)) AS per75
    , TIME(TIMESTAMP_SECONDS(per90)) AS per90
    , TIME(TIMESTAMP_SECONDS(per95)) AS per95
    , TIME(TIMESTAMP_SECONDS(per98)) AS per98

    -- metode 2
    , REGEXP_REPLACE(
                    CAST(TIME(TIMESTAMP_SECONDS(per50)) AS STRING),
                    r'^\d\d',
                    CAST(EXTRACT(HOUR FROM TIME(TIMESTAMP_SECONDS(per50))) + 24*UNIX_DATE(DATE(TIMESTAMP_SECONDS(per50))) AS STRING)
                    )
      AS `Percentile_50`
    , REGEXP_REPLACE(
                    CAST(TIME(TIMESTAMP_SECONDS(per75)) AS STRING),
                    r'^\d\d',
                    CAST(EXTRACT(HOUR FROM TIME(TIMESTAMP_SECONDS(per75))) + 24*UNIX_DATE(DATE(TIMESTAMP_SECONDS(per75))) AS STRING)
                    )
      AS `Percentile_75`
    , REGEXP_REPLACE(
                    CAST(TIME(TIMESTAMP_SECONDS(per90)) AS STRING),
                    r'^\d\d',
                    CAST(EXTRACT(HOUR FROM TIME(TIMESTAMP_SECONDS(per90))) + 24*UNIX_DATE(DATE(TIMESTAMP_SECONDS(per90))) AS STRING)
                    )
      AS `Percentile_90`
    , REGEXP_REPLACE(
                    CAST(TIME(TIMESTAMP_SECONDS(per95)) AS STRING),
                    r'^\d\d',
                    CAST(EXTRACT(HOUR FROM TIME(TIMESTAMP_SECONDS(per95))) + 24*UNIX_DATE(DATE(TIMESTAMP_SECONDS(per95))) AS STRING)
                    )
      AS `Percentile_95`
    , REGEXP_REPLACE(
                    CAST(TIME(TIMESTAMP_SECONDS(per98)) AS STRING),
                    r'^\d\d',
                    CAST(EXTRACT(HOUR FROM TIME(TIMESTAMP_SECONDS(per98))) + 24*UNIX_DATE(DATE(TIMESTAMP_SECONDS(per98))) AS STRING)
                    )
      AS `Percentile_98`
FROM percentile
)

SELECT *
FROM transform