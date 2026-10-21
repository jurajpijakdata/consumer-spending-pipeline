-- Staging model for the purchases file.
-- One row per purchased item. English names and real types; missing values
-- stay NULL here (they are labelled "Unknown" in the intermediate layer).

with source as (

    select * from {{ source('raw', 'purchases') }}

),

renamed as (

    select
        try_convert(date, [Order Date], 23)                                   as order_date,
        [Order Date]                                                          as order_date_raw,
        try_convert(decimal(12, 2), [Purchase Price Per Unit])                as unit_price_usd,
        -- quantity arrives as "1.0", so convert to decimal first, then to int
        cast(try_convert(decimal(10, 2), [Quantity]) as int)                  as quantity,
        nullif(trim([Shipping Address State]), '')                            as state,
        nullif(trim([Title]), '')                                             as title,
        nullif(trim([ASIN/ISBN (Product Code)]), '')                          as product_code,
        nullif(trim([Category]), '')                                          as category,
        trim([Survey ResponseID])                                             as customer_id,
        _source_file,
        _loaded_at
    from source

)

select * from renamed
