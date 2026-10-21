-- Purchases with labels, flags, category groups and validation.
-- Every row stays here; rejection_reasons explains why a row is invalid.
{{ config(materialized='table') }}

with purchases as (

    select *, upper(category) as cat from {{ ref('stg_raw__purchases') }}

),

enriched as (

    select
        *,
        coalesce(category, 'Unknown')                            as category_label,
        coalesce(title, 'Unknown')                               as title_label,
        coalesce(state, 'Unknown')                               as state_label,
        unit_price_usd * quantity                                as spend_usd,
        -- gift cards have 4 spellings: GIFT_CARD, ABIS_GIFT_CARD, ELECTRONIC_GIFT_CARD, "Ecard Gift Certificate"
        case when cat like '%GIFT_CARD%' or cat = 'ECARD GIFT CERTIFICATE'
             then 1 else 0 end                                   as is_gift_card,
        case when title is null and category is null
             then 1 else 0 end                                   as is_unlisted_product,
        case when year(order_date) between 2018 and 2022
             then 1 else 0 end                                   as is_complete_year,
        -- keyword rules: the FIRST matching line wins, so the order matters.
        -- Traps: TABLET vs TABLE, TABLETOP_GAME vs TABLE, PET_FOOD vs FOOD,
        -- NOTEBOOK_COMPUTER vs BOOK, DRINKING_CUP vs DRINK, PAPER_TOWEL vs TOWEL,
        -- AIR_CONDITIONER vs CONDITIONER, PLANT_SEED vs SEED,
        -- RING vs EARRING / STRING_LIGHT, COOKIE vs COOKER, PANTS vs FRY_PAN.
        case
            when cat like '%GIFT_CARD%' or cat = 'ECARD GIFT CERTIFICATE'       then 'Gift cards'
            when cat is null                                                    then 'Unknown'
            when cat like '%PET%' or cat like '%ANIMAL%' or cat like '%LITTER%' then 'Pets'
            when cat like '%TABLETOP_GAME%'                                     then 'Games & toys'
            when cat like '%COMPUTER%' or cat like '%TABLET%' or cat like '%MONITOR%'
              or cat like '%DRIVE%' or cat like '%KEYBOARD%' or cat like '%PRINTER%'
              or cat like '%ROUTER%' or cat like '%VIDEO_CARD%' or cat like '%CABLE%'
              or cat like '%ELECTRONIC%' or cat like '%DIGITAL_DEVICE%' or cat like '%CAMERA%'
              or cat like '%PHONE%' or cat like '%CHARGING%' or cat like '%SCREEN_PROTECTOR%'
              or cat like '%SPEAKER%' or cat like '%TELEVISION%' or cat like '%VDO_DEVICE%'
              or cat like '%MOUSE%' or cat like '%MEMORY%' or cat like '%CAMCORDER%'
              or cat like '%MOTHERBOARD%' or cat like '%STREAMING%' or cat like '%POWER_STRIP%'
              or cat like '%DISPLAY%' or cat like '%POWER_BANK%' or cat like '%SYSTEM_POWER%'
              or cat like '%PROJECTOR%' or cat like '%INPUT_PEN%' or cat like '%VIRTUAL_REALITY%'
              or cat like '%REMOTE_CONTROL%' or cat like '%WIRELESS%' or cat like '%NETWORK%'
              or cat like '%FILAMENT%'                                          then 'Electronics'
            when cat like '%AUTO_%'                                             then 'Auto'
            when cat like '%BABY%'                                              then 'Baby'
            when cat like '%VIDEO%GAME%' or cat like '%GAME%' or cat like '%TOY%'
              or cat like '%PUZZLE%' or cat like '%COSTUME%'                    then 'Games & toys'
            when cat like '%BOOK%' or cat like '%PAPERBACK%' or cat like '%MOVIE%'
              or cat like '%MUSIC%' or cat like '%TV_SERIES%'
              or cat like '%INSTRUMENT%'                                        then 'Books & media'
            when cat like '%SUPPLEMENT%' or cat like '%VITAMIN%' or cat like '%HEALTH%'
              or cat like '%MEDICATION%' or cat like '%BEAUTY%' or cat like '%SKIN%'
              or cat like '%MASSAGER%' or cat like '%INCONTINENCE%' or cat like '%HAIR%'
              or cat like '%SHAMPOO%' or cat = 'CONDITIONER' or cat like '%TOOTHBRUSH%'
              or cat like '%ORTHOPEDIC%' or cat like '%BODY_POSITIONER%'
              or cat like '%SAFETY_MASK%' or cat like '%DEODORANT%' or cat like '%WIG%'
              or cat like '%SHAVER%' or cat like '%FRAGRANCE%' or cat like '%SUNSCREEN%'
              or cat like '%THERMOMETER%' or cat like '%RESPIRATOR%' or cat like '%NAIL%'
              or cat like '%SEXUAL%'                                            then 'Health & beauty'
            when cat like '%SHOES%' or cat like '%SHIRT%' or cat like '%PANTS%'
              or cat like '%DRESS%' or cat like '%BOOT%' or cat like '%SOCKS%'
              or cat like '%BRA' or cat like '%COAT%' or cat like '%SHORTS%'
              or cat like '%SWIMWEAR%' or cat like '%SANDAL%' or cat like '%HAT'
              or cat like '%BACKPACK%' or cat like '%SWEATER%' or cat like '%HANDBAG%'
              or cat like '%SLIPPER%' or cat like '%PAJAMAS%' or cat like '%NECKLACE%'
              or cat like '%SUNGLASSES%' or cat like '%APPAREL%' or cat like '%WATCH%'
              or cat like '%EARRING%' or cat = 'RING' or cat like '%SUITCASE%'
              or cat like '%WALLET%' or cat like '%SKIRT%' or cat like '%TUNIC%'
              or cat like '%CARRIER_BAG%'                                       then 'Clothing & accessories'
            when cat like '%SPORTING%' or cat like '%OUTDOOR%' or cat like '%BICYCLE%'
              or cat like '%TREADMILL%' or cat like '%BALL%'                    then 'Sports & outdoors'
            when cat like '%WRITING%' or cat like '%INK%' or cat like '%OFFICE%'
              or cat like '%MARKING_PEN%' or cat like '%ART_CRAFT%' or cat like '%STICKER%'
              or cat like '%ART_SUPPLIES%' or cat like '%LABEL%' or cat like '%PLANNER%'
              or cat like '%ENVELOPE%'                                          then 'Office & crafts'
            when cat like '%CLEANING%' or cat like '%TOILET%' or cat like '%WASTE_BAG%'
              or cat like '%FILTER%' or cat like '%BATTERY%' or cat like '%LAUNDRY%'
              or cat like '%PAPER_TOWEL%' or cat like '%ADHESIVE%' or cat like '%TOOLS%'
              or cat like '%HARDWARE%' or cat like '%PAINT%' or cat like '%SCALE%'
              or cat like '%LOCK%' or cat like '%PEST%' or cat like '%GLOVE%'
              or cat like '%DEODORIZER%' or cat like '%GENERATOR%'
              or cat like '%PURIFICATION%'                                      then 'Household & cleaning'
            when cat like '%CHAIR%' or cat like '%MATTRESS%' or cat like '%BED%'
              or cat like '%BLANKET%' or cat like '%LAMP%' or cat like '%LIGHT%'
              or cat like '%RUG%' or cat like '%SHELF%' or cat like '%DESK%'
              or cat like '%TABLE%' or cat like '%CURTAIN%' or cat like '%HOME%'
              or cat like '%KITCHEN%' or cat like '%CUP%' or cat like '%VACUUM%'
              or cat like '%FAN%' or cat like '%AIR_%' or cat like '%FURNITURE%'
              or cat like '%PILLOW%' or cat like '%TOWEL%' or cat like '%CADDY%'
              or cat like '%FIGURINE%' or cat like '%WALL_ART%' or cat like '%FRAME%'
              or cat like '%CABINET%' or cat like '%SOFA%' or cat like '%STORAGE%'
              or cat like '%PLANT%' or cat like '%BOTTLE%' or cat like '%COOKER%'
              or cat like '%CANDLE%' or cat like '%TRASH%' or cat like '%FAUCET%'
              or cat like '%PLUMBING%' or cat like '%HANGING%' or cat like '%THERMOS%'
              or cat like '%HUMIDIFIER%' or cat like '%FRY_PAN%'               then 'Home & kitchen'
            when cat like '%COFFEE%' or cat like '%TEA%' or cat like '%FOOD%'
              or cat like '%SNACK%' or cat like '%GROCERY%' or cat like '%DRINK%'
              or cat like '%CANDY%' or cat like '%NUT%' or cat = 'WATER'
              or cat like '%COOKIE%' or cat like '%MEAT%' or cat like '%BEVERAGE%'
              or cat like '%SAUCE%' or cat like '%CEREAL%' or cat like '%FRUIT%'
              or cat like '%SOUP%' or cat like '%JERKY%' or cat like '%POULTRY%' then 'Grocery'
            else 'Other'
        end                                                      as category_group
    from purchases

),

validated as (

    select
        *,
        nullif(concat_ws('; ',
            case when order_date is null then 'invalid order date: ' + order_date_raw end,
            case when order_date > '2023-03-31' then 'order date after data collection ended' end,
            case when unit_price_usd is null then 'invalid price' end,
            case when quantity is null then 'invalid quantity' end
        ), '') as rejection_reasons
    from enriched

)

select * from validated
