# Decision log

## 001 — Real public data, purchases file only
**Date:** 2026-10-16
**Decision:** Use the purchases file of *Open e-commerce 1.0* (Berke et al.,
Harvard Dataverse, CC0 1.0). The survey file is not used.
**Why:** Real data with real problems; CC0 allows any use. The survey contains
demographic and health data the analysis does not need (data minimisation).
The download is verified by MD5 (`scripts/download_data.py`).

## 002 — Keep incomplete rows, reject wrong rows
**Date:** 2026-10-16
**Decision:** Rows with missing category, title or state (~5 %) are kept and
labelled "Unknown"; their share is reported. Rows that are impossible (an
order date after the data collection ended) are rejected with a reason.
**Why:** A missing category does not make a purchase untrue; dropping these
rows would understate spending by ~5 %.

## 003 — Exact duplicates are kept
**Date:** 2026-10-16
**Decision:** 11,624 identical rows (0.6 %) are kept.
**Why:** The source has no order number, so they cannot be told apart from
real repeat purchases; examples look genuine. Documented as a limitation.

## 004 — Gift cards reported separately
**Date:** 2026-10-16
**Decision:** GIFT_CARD purchases ($900,643, 2.0 %) are excluded from
"spending on products" and shown separately.
**Why:** Balance reloads may be counted twice (when loaded and when spent);
the source has no payment method to confirm it.

## 005 — Yearly trends use complete years only
**Date:** 2026-10-16
**Decision:** Year-over-year charts use 2018–2022. 2023 is shown as partial.
**Why:** Data collection ended Nov 2022 – Mar 2023, so 2023 is incomplete and
would look like a false collapse in spending.

## 006 — One Copy step, full reload
**Date:** 2026-10-20
**Decision:** Data Factory loads the single file with one Copy activity into
`staging.purchases` (all text), after `DELETE FROM staging.purchases`.
Retries 2 × 60 s; 4 data integration units.
**Why:** One source needs no loops; a full reload is idempotent and takes a
few minutes. CSV escape character set to `"` because titles contain `""`.
Reconciled: 1,850,717 rows in the file and in staging.

## 007 — Category groups with keyword rules, stopped at ~78 % coverage
**Date:** 2026-10-21
**Decision:** 1,871 categories are grouped into 16 groups by keyword rules in
`int_purchases__validated`. After 4 rounds, "Other" is 16.7 % of spending and
"Unknown" 5.3 %, so real groups cover ~78 %. Stopped there.
**Why:** Each round helped about half as much as the one before (60.4 → 35.9 →
23.3 → 16.7 % Other); the rest is a long tail of small categories. Rule order
matters (e.g. TABLETOP_GAME contains TABLET); `assert_category_traps` guards it.
