-- Dimension: one row per category, with its group and gift card flag.

select distinct
    upper(category_label) as category,   -- one spelling per category (APPAREL = Apparel)
    category_group,
    is_gift_card
from {{ ref('int_purchases__validated') }}
