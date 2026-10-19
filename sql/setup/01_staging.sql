-- Staging for the purchases file. All business columns are text: values are
-- stored exactly as delivered, cleaning happens later in dbt. Safe to re-run.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO

IF OBJECT_ID('staging.purchases') IS NULL
CREATE TABLE staging.purchases (
    [Order Date]               NVARCHAR(50),
    [Purchase Price Per Unit]  NVARCHAR(50),
    [Quantity]                 NVARCHAR(50),
    [Shipping Address State]   NVARCHAR(50),
    [Title]                    NVARCHAR(MAX),
    [ASIN/ISBN (Product Code)] NVARCHAR(100),
    [Category]                 NVARCHAR(200),
    [Survey ResponseID]        NVARCHAR(100),
    _source_file               NVARCHAR(400) NOT NULL,
    _loaded_at                 DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
