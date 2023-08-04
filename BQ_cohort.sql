
with data as (
    select 
    max(customer_id) customer_id,
    max(order_at) order_at,
    so_number
from orders
where
group by 3
),

t_first_purchase AS (
SELECT 
    date,
    DATE_TRUNC(date,MONTH) AS month_date, --index_month
    DATE_DIFF(date, first_purchase_date, MONTH) AS month_order,
    DATE_TRUNC(first_purchase_date, MONTH) AS first_purchase,
    customer_id
FROM (
    SELECT 
    DATE(TIMESTAMP(order_at)) AS date,
    customer_id,
    FIRST_VALUE(DATE(TIMESTAMP(order_at))) OVER (PARTITION BY customer_id ORDER BY DATE(TIMESTAMP(order_at))) AS first_purchase_date
    FROM data
    )
),

t_agg AS (
SELECT 
  first_purchase,
  month_order,
  COUNT(DISTINCT customer_id) AS Customers
FROM 
  t_first_purchase
GROUP BY first_purchase, month_order
),


 t_cohort AS (
SELECT *,
  (Round(SAFE_DIVIDE(Customers, CohortCustomers),4))*100 AS CohortCustomersPerc
FROM (
    SELECT *,
      FIRST_VALUE(Customers) OVER (PARTITION BY first_purchase ORDER BY month_order) AS CohortCustomers
    FROM t_agg
  )
 )

SELECT * FROM t_cohort
order by first_purchase DESC