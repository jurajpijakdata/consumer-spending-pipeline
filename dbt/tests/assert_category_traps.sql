-- Keyword rules: each tricky category must land in the right group.
-- Returns rows only if a rule order breaks.
select category, category_group
from {{ ref('int_purchases__validated') }}
where (category = 'NOTEBOOK_COMPUTER' and category_group <> 'Electronics')
   or (category = 'AMAZON_TABLET'     and category_group <> 'Electronics')
   or (category = 'TABLETOP_GAME'     and category_group <> 'Games & toys')
   or (category = 'PET_FOOD'          and category_group <> 'Pets')
   or (category = 'AIR_CONDITIONER'   and category_group <> 'Home & kitchen')
   or (category = 'STRING_LIGHT'      and category_group <> 'Home & kitchen')
   or (category = 'COOKIE'            and category_group <> 'Grocery')
   or (category = 'PAPER_TOWEL'       and category_group <> 'Household & cleaning')
   or (upper(category) like '%GIFT_CARD%' and category_group <> 'Gift cards')
