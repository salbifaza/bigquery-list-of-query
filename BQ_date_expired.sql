SELECT 
    CASE
        -- senin jumat <= 16.00 
        WHEN EXTRACT(DAYOFWEEK FROM order_timestamp) != 1 AND EXTRACT(DAYOFWEEK FROM order_timestamp) < 7 AND EXTRACT(TIME FROM TIMESTAMP(order_timestamp)) <= TIME(16,00,00)
            THEN TIMESTAMP_ADD(order_timestamp, INTERVAL 1 DAY)
        -- senin kamis > 16.00 
        WHEN EXTRACT(DAYOFWEEK FROM order_timestamp) != 1 AND EXTRACT(DAYOFWEEK FROM order_timestamp) < 6 AND EXTRACT(TIME FROM TIMESTAMP(order_timestamp)) > TIME(16,00,00)
            THEN TIMESTAMP_ADD(order_timestamp, INTERVAL 2 DAY)
        -- jumat > 16.00
        WHEN EXTRACT(DAYOFWEEK FROM order_timestamp) = 6 AND EXTRACT(TIME FROM TIMESTAMP(order_timestamp)) > TIME(16,00,00)
            THEN TIMESTAMP_ADD(order_timestamp, INTERVAL 3 DAY)
        -- sabtu minggu <= 16.00
        WHEN (EXTRACT(DAYOFWEEK FROM order_timestamp) = 1 OR EXTRACT(DAYOFWEEK FROM order_timestamp) = 7) AND EXTRACT(TIME FROM TIMESTAMP(order_timestamp)) <= TIME(16,00,00)
            THEN TIMESTAMP_ADD(order_timestamp, INTERVAL 2 DAY)
        -- sabtu minggu > 16.00
        WHEN (EXTRACT(DAYOFWEEK FROM order_timestamp) = 1 OR EXTRACT(DAYOFWEEK FROM order_timestamp) = 7) AND EXTRACT(TIME FROM TIMESTAMP(order_timestamp)) > TIME(16,00,00)
            THEN TIMESTAMP_ADD(order_timestamp, INTERVAL 3 DAY)
      END AS expired_time
FROM order