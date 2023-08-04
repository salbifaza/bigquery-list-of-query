WITH sales_data AS (
SELECT 
    order_date,
    DATETIME_TRUNC(order_date, MONTH) AS cohort_month,
    buyer_phone AS customer_id,
    marketplace,
    official_store,
from orders
),

population AS (
SELECT customer_id, 
    MIN(cohort_month) AS cohort_month,
FROM sales_data
GROUP BY customer_id
),

group_data AS (
SELECT
    cohort_month,
    count(DISTINCT(customer_id)) as first_customers
from population
group by cohort_month
),

activity AS (
SELECT  customer_id,
        count(*) as freq
FROM sales_data
group by customer_id
),

combine_data as
(select
    pop.customer_id,
    FORMAT_DATETIME("%Y-%m", pop.cohort_month) as cohort_month,
    act.freq
from population pop
left join activity act ON act.customer_id = pop.customer_id
),

freq_dist as 
(select cohort_month, 
    CASE WHEN freq > 5 THEN "5+"
        ELSE CAST(freq AS STRING)
    END AS freq, 
    count(customer_id) as num_of_cust
from combine_data
group by cohort_month,freq)

select *
from freq_dist
WHERE freq IS NOT NULL
order by cohort_month,freq desc