with sellers as (
    select * from {{ ref('stg_sellers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
    seller_id,
    seller_city,
    seller_state,
    zip_code
from sellers