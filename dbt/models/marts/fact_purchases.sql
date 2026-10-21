-- Fact: one row per valid purchased item.
-- The source has no purchase ID, so purchase_id is a surrogate key (a running number).
-- Rows with a rejection reason (e.g. the 2024 order date) are left out.

with purchases as (

    select * from {{ ref('int_purchases__validated') }}
    where rejection_reasons is null

)

select
    row_number() over (
        order by order_date, customer_id, product_code, title_label, unit_price_usd
    )                    as purchase_id,
    order_date,
    customer_id,
    category_label       as category,
    category_group,
    state_label          as state,
    product_code,
    title_label          as title,
    quantity,
    unit_price_usd,
    spend_usd,
    is_gift_card,
    is_unlisted_product
from purchases
