
-- Source table (replace second arg if your source/table name is different)
with source as ( 
    select * 
        from {{ source('bulk_sales', 'bulk-salesnsw_bulk_sales') }}),
    
parse as (
select
        -- keep all the B_* columns as-is (from your raw DAT-derived table)
        b_0, b_1, b_2, b_3, b_4, b_5, b_6, b_7, b_8, b_9,
        b_10, b_11, b_12, b_13, b_14, b_15, b_16, b_17, b_18, b_19,
        b_20, b_21, b_22, b_23, b_24,

        -- original columns
        district,
        property_id,
        sale_counter,

        -- download_datetime / contract_date / settlement_date:
        -- ASSUMPTION: these are epoch milliseconds. If they are already ISO strings/timestamps,
        -- remove the from_unixtime(...) conversions and use the column directly.
        case
          when download_datetime is null then null
          when try_cast(download_datetime AS bigint) is not null
            then from_unixtime(cast(try_cast(download_datetime AS bigint) / 1000 AS bigint))
          else null
        end as download_datetime_ts,

        property_name,
        unit_number,
        house_number,
        street_name,
        locality,
        postcode,
        area,
        area_type,

        case
          when contract_date is null then null
          when try_cast(contract_date AS bigint) is not null
            then from_unixtime(cast(try_cast(contract_date AS bigint) / 1000 AS bigint))
          else null
        end as contract_date_ts,

        case
          when settlement_date is null then null
          when try_cast(settlement_date AS bigint) is not null
            then from_unixtime(cast(try_cast(settlement_date AS bigint) / 1000 AS bigint))
          else null
        end as settlement_date_ts,

        -- safe cast purchase price (avoid failing if non-numeric)
        try_cast(purchase_price AS bigint) as purchase_price,

        zoning,
        legal_description,

        -- if the Glue table added partition column 'year' keep it
        year
    from source

)

select
    -- raw B_* fields (kept so you don't lose anything)
    b_0, b_1, b_2, b_3, b_4, b_5, b_6, b_7, b_8, b_9,
    b_10, b_11, b_12, b_13, b_14, b_15, b_16, b_17, b_18, b_19,
    b_20, b_21, b_22, b_23, b_24,

    -- friendly names (minimal renames)
    district,
    property_id,

    -- sale_counter -> integer when possible
    try_cast(sale_counter AS integer) as sale_counter,

    -- normalized timestamps
    download_datetime_ts  as download_datetime,
    property_name,
    unit_number,
    house_number,
    street_name,
    locality,
    postcode,

    -- area: keep original, add a canonical m2 column
    area,
    area_type,
    case
      when area is null then null
      when lower(coalesce(area_type, '')) = 'h' then area * 10000.0   -- hectares -> m^2
      else area
    end as area_m2,

    contract_date_ts  as contract_date,
    settlement_date_ts as settlement_date,

    purchase_price,
    zoning,
    legal_description,

    -- handy derived field: full readable address (simple concatenation)
    concat_ws(' ',
      nullif(unit_number, ''), nullif(house_number, ''), nullif(street_name, ''), nullif(locality, ''), nullif(postcode, '')
    ) as full_address,

    -- keep partition column if present
    year

from parse
;
