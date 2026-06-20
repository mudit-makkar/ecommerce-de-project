with orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
),

dim_customers as (
    select customer_key, customer_id from {{ ref('dim_customers') }}
)

select
    o.order_id,
    dc.customer_key,
    o.order_status,

    -- date keys for joining to dim_date
    cast(o.order_purchased_at as date)         as order_purchase_date_key,
    cast(o.order_delivered_at as date)         as order_delivery_date_key,

    -- timestamps (kept for precise time analysis)
    o.order_purchased_at,
    o.order_approved_at,
    o.order_shipped_at,
    o.order_delivered_at,
    o.order_estimated_delivery_at,

    -- delivery performance
    o.delivery_delay_days,
    o.was_delivered_late,

    -- order composition
    o.item_count,
    o.distinct_product_count,
    o.distinct_seller_count,

    -- financials
    o.total_items_price,
    o.total_freight_value,
    o.total_order_value,
    o.payment_count,
    o.total_paid,
    o.max_installments,

    -- review
    o.review_score,
    o.sentiment

from orders_enriched o
left join dim_customers dc on o.customer_id = dc.customer_id