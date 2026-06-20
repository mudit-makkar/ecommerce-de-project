with source as (
    select * from {{ source('ecommerce', 'orders') }}
),

renamed as (
    select
        -- primary key
        order_id,

        -- foreign keys
        customer_id,

        -- attributes
        order_status,

        -- timestamps: cast from VARCHAR to proper TIMESTAMP
        try_to_timestamp(order_purchase_timestamp)         as order_purchased_at,
        try_to_timestamp(order_approved_at)                as order_approved_at,
        try_to_timestamp(order_delivered_carrier_date)     as order_shipped_at,
        try_to_timestamp(order_delivered_customer_date)    as order_delivered_at,
        try_to_timestamp(order_estimated_delivery_date)    as order_estimated_delivery_at,

      -- derived fields
        case
            when order_delivered_customer_date is not null
             and order_estimated_delivery_date is not null
            then datediff(
                'day',
                try_to_timestamp(order_estimated_delivery_date),
                try_to_timestamp(order_delivered_customer_date)
            )
        end as delivery_delay_days,    -- negative = early, positive = late

        -- metadata
        _loaded_at

    from source
)

select * from renamed