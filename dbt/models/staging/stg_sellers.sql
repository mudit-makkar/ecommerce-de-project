with source as (
    select * from {{ source('ecommerce', 'sellers') }}
),

renamed as (
    select
        seller_id,
        seller_zip_code_prefix  as zip_code,
        initcap(seller_city)    as seller_city,
        upper(seller_state)     as seller_state,
        _loaded_at
    from source
)

select * from renamed