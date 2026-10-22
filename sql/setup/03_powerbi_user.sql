-- Power BI account: read-only access to the dbt-built tables. Safe to re-run.

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'powerbi@jurajpijakdatagmail.onmicrosoft.com')
    CREATE USER [powerbi@jurajpijakdatagmail.onmicrosoft.com] FROM EXTERNAL PROVIDER;
GO

GRANT SELECT ON SCHEMA::dbt_dev TO [powerbi@jurajpijakdatagmail.onmicrosoft.com];
GO
