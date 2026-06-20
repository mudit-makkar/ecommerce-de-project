with source as (
    select * from {{ source('ecommerce', 'order_items') }}
),

renamed as (
    select
        -- composite key (an order can have multiple items)
        -- order_item_id is value like 1,2,3.. which denotes the number of item..
        {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }}
                                            as order_item_sk,
        order_id,
        order_item_id::integer              as order_item_sequence,
        product_id,
        seller_id,

        -- amounts: cast to numeric
        price::numeric(10,2)                as item_price,
        freight_value::numeric(10,2)        as freight_value,
        (price::numeric + freight_value::numeric)
                                            as total_item_value,

        -- timestamps
        try_to_timestamp(shipping_limit_date) as shipping_limit_at,

        _loaded_at
    from source
)

select * from renamed