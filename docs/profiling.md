# Data profiling: amazon-purchases.csv

1,850,717 rows, 8 columns (profiled in `notebooks/01_profiling.ipynb`).

## Missing values
| Column | Empty | Share | Decision |
|---|---|---|---|
| Shipping Address State | 87,812 | 4.7 % | keep, label "Unknown" |
| Title | 89,740 | 4.8 % | keep, label "Unknown" |
| Category | 89,458 | 4.8 % | keep, label "Unknown"; report the share |
| ASIN/ISBN (Product Code) | 973 | 0.05 % | keep; cannot be linked to a product |

Rule: reject what is wrong, keep and label what is incomplete but real.

## Outliers checked
- Quantity up to 339: photo prints (4x6) — real purchases, kept.
- 180 items at $0.01: samples, SIM cards, used books, promotions — real, kept.
- Max $6,398.95: a 96 TB storage system; top prices are real products — kept.

## Dates
- Range 2018-01-01 to 2024-08-15. Data was collected Nov 2022 – Mar 2023,
  so 1 row dated 2024-08-15 is invalid (a protection plan; the date is
  probably not the purchase date) → rejected with a reason.
- 2023 is only partly covered (Jan–Mar, depending on when people joined)
  → yearly trends use complete years 2018–2022 only.
- Purchases +54 % from 2019 to 2020 (COVID): a real pattern, not generated.

## Duplicates
- 11,624 exact duplicate rows (0.6 %). There is no order number, so they cannot
  be told apart from real repeat purchases (examples: 2 gift cards, 2 teas,
  2 personalised frames). Decision: kept, documented.

## Gift cards
- GIFT_CARD = $900,643 (2.0 % of all spending). Some of it (Amazon balance
  reloads) may be counted twice — once when loaded, once when spent — but the
  source has no payment method, so this cannot be confirmed. Others (gift cards
  for other stores, gifts) are not double. Decision: reported separately,
  excluded from "spending on products"; the uncertainty is stated.
- Gift cards often have no shipping state (digital delivery), which explains
  part of the missing states.

