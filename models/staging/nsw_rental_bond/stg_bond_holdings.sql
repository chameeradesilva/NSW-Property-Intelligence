{{ config(
    materialized='view',
    tags=['staging','nsw_bond']
) }}

-- Minimal staging for bond holdings (annual)
select
  try_cast(postcode as bigint) as postcode,
  try_cast(bonds_held as bigint) as bonds_held,
  year as year
from {{ source('nsw_bond', 'holdingsannual') }}
