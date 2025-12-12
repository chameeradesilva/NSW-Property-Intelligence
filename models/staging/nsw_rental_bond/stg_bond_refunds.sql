{{ config(
    materialized='view',
    tags=['staging','nsw_bond']
) }}

-- Minimal staging for bond refunds (quarterly)
select
  -- payment_date: try epoch-ms (13 digits), epoch-seconds (10 digits) or YYYYMMDD (8 digits)
  case
    when payment_date is null then null
    when length(cast(payment_date as varchar)) = 13 then from_unixtime(cast(cast(payment_date as bigint)/1000 as bigint))
    when length(cast(payment_date as varchar)) = 10 then from_unixtime(cast(payment_date as bigint))
    when regexp_like(cast(payment_date as varchar), '^[0-9]{8}$') then date_parse(cast(payment_date as varchar), '%Y%m%d')
    else null
  end as payment_date,

  try_cast(postcode as bigint) as postcode,
  dwelling_type,
  try_cast(NULLIF(trim(bedrooms), '') as integer) as bedrooms,
  try_cast(payment_to_agent as bigint) as payment_to_agent,
  try_cast(payment_to_tenant as bigint) as payment_to_tenant,
  try_cast(days_bond_held as bigint) as days_bond_held,
  year as year

from {{ source('nsw_bond', 'refundsquarterly') }}
