with source as (
    select * from {{ source('ecommerce', 'customers') }}
),

renamed as (
    select
        customer_id,
        customer_unique_id,                          -- true customer identity
        customer_zip_code_prefix    as zip_code,
        initcap(customer_city)      as customer_city,   -- "sao paulo" → "Sao Paulo"
        upper(customer_state)       as customer_state,  -- ensure uppercase
        _loaded_at
    from source
)

select * from renamed
