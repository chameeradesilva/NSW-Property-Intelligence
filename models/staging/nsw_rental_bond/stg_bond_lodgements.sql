{{ config(
    materialized='view',
    tags=['staging','nsw_bond']
) }}

-- Minimal staging for bond lodgements (monthly)
select
  case
    when lodgement_date is null then null
    when length(cast(lodgement_date as varchar)) = 13 then from_unixtime(cast(cast(lodgement_date as bigint)/1000 as bigint))
    when length(cast(lodgement_date as varchar)) = 10 then from_unixtime(cast(lodgement_date as bigint))
    when regexp_like(cast(lodgement_date as varchar), '^[0-9]{8}$') then date_parse(cast(lodgement_date as varchar), '%Y%m%d')
    else null
  end as lodgement_date,

  try_cast(postcode as bigint) as postcode,
  dwelling_type,
  try_cast(NULLIF(trim(bedrooms), '') as integer) as bedrooms,

  -- weekly_rent sometimes stored as string; make safe numeric where possible
  case
    when weekly_rent is null then null
    when regexp_like(weekly_rent, '^[0-9]+(\\.[0-9]+)?$') then cast(weekly_rent as double)
    else null
  end as weekly_rent,

  year as year

from {{ source('nsw_bond', 'lodgementsmonthly') }}
