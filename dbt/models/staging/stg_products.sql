with source as (
    select * from {{ source('ecommerce', 'products') }}
),

renamed as (
    select
        product_id,
        product_category_name,

        -- fix the typos in source column names
        product_name_lenght::integer        as product_name_length,
        product_description_lenght::integer as product_description_length,
        product_photos_qty::integer         as product_photos_count,

        -- physical dimensions
        product_weight_g::numeric           as weight_grams,
        product_length_cm::numeric          as length_cm,
        product_height_cm::numeric          as height_cm,
        product_width_cm::numeric           as width_cm,

        -- derived: volumetric weight (used in shipping)
        round(
            (product_length_cm::numeric
             * product_height_cm::numeric
             * product_width_cm::numeric) / 5000
        , 2)                                as volumetric_weight_kg,

        _loaded_at
    from source
)

select * from renamed
