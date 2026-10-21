-- Dimension: one row per customer (anonymous survey ID), with activity summary.

select
    customer_id,
    min(order_date) as first_purchase_date,
    max(order_date) as last_purchase_date,
    count(*)        as purchases
from {{ ref('fact_purchases') }}
group by customer_id
