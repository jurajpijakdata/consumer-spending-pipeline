-- Data Factory's managed identity: read/insert/delete in staging only. Safe to re-run.

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'adf-consumerspend-jp')
    CREATE USER [adf-consumerspend-jp] FROM EXTERNAL PROVIDER;
GO

-- DELETE is needed to reload the file without duplicates.
GRANT SELECT, INSERT, DELETE ON SCHEMA::staging TO [adf-consumerspend-jp];
GO
