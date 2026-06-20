with products as (
    select * from {{ ref('stg_products') }}
),

category_translation as (
    select * from {{ ref('stg_product_category_translations') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
    p.product_id,
    p.product_category_name,
    ct.category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_count,
    p.weight_grams,
    p.length_cm,
    p.height_cm,
    p.width_cm,
    p.volumetric_weight_kg
from products p
left join category_translation ct
    on p.product_category_name = ct.category_name_portuguese