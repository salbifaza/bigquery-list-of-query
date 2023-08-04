SELECT 
  member_code,
  counter,
  (counter * 100.0 / SUM(counter) OVER ()) AS counter_percentage
FROM (
  SELECT 
    CASE WHEN member_code IS NULL THEN 'NULL'
      ELSE 'NOT NULL'
    END AS member_code,
    COUNT(*) AS counter
  FROM `order.cart` 
  WHERE 1=1
  GROUP BY 1
) subquery
ORDER BY member_code ASC