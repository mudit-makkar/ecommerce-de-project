with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

category_translation as (
    select * from {{ ref('stg_product_category_translations') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

final as (
    select
        oi.order_item_sk,
        oi.order_id,
        oi.order_item_sequence,
        oi.product_id,
        oi.seller_id,

        -- order context
        o.order_status,
        o.order_purchased_at,

        -- product details
        p.product_category_name,
        ct.category_name_english,
        p.weight_grams,
        p.volumetric_weight_kg,

        -- seller details
        s.seller_city,
        s.seller_state,

        -- financials
        oi.item_price,
        oi.freight_value,
        oi.total_item_value,

        -- freight as % of item price — useful for shipping cost analysis
        round(oi.freight_value / nullif(oi.item_price, 0) * 100, 2)
                                            as freight_pct_of_price,

        oi.shipping_limit_at

    from order_items oi
    left join products p             on oi.product_id = p.product_id
    left join sellers s              on oi.seller_id = s.seller_id
    left join category_translation ct on p.product_category_name = ct.category_name_portuguese
    left join orders o               on oi.order_id = o.order_id
)

select * from final