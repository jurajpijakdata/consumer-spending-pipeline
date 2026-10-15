# Consumer Spending Pipeline

> **Portfolio project with real public data.** Purchase histories of 5,027
> U.S. Amazon.com consumers, 2018–2022 (over 1.8 million purchases),
> crowdsourced with informed consent by MIT researchers.

## Business question
How did online spending change between 2018 and 2022, before, during and
after COVID-19 — which categories grew, which shrank, and when?

## Planned architecture
CSV → Azure Blob Storage → Azure Data Factory → Azure SQL Database → dbt → Power BI

## Data source
Berke, A., Calacci, D., Mahari, R., Yabe, T., Larson, K., & Pentland, S. (2023).
*Open e-commerce 1.0: Five years of crowdsourced U.S. Amazon purchase histories
with user demographics.* Harvard Dataverse. https://doi.org/10.7910/DVN/YGLYDY

- License: **CC0 1.0** (public domain)
- Collection approved by the MIT Institutional Review Board
- Only the purchases file is used. The survey file (demographics, health) is
  intentionally **not** used: the analysis does not need it (data minimisation).
- Not affiliated with or endorsed by Amazon.

## Status
🚧 In progress
