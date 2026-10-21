-- Data quality numbers for the dashboard, calculated from the data (one row).

select
    count(*)                                                         as all_rows,
    sum(case when rejection_reasons is not null then 1 else 0 end)   as rejected_rows,
    sum(case when category is null then 1 else 0 end)                as unknown_category_rows,
    sum(is_unlisted_product)                                         as unlisted_product_rows,
    sum(case when is_gift_card = 1 then spend_usd else 0 end)
        / sum(spend_usd)                                             as gift_card_share,
    sum(case when category_group = 'Other' then spend_usd else 0 end)
        / sum(spend_usd)                                             as other_group_share
from {{ ref('int_purchases__validated') }}
