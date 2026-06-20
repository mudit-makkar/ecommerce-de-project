with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

order_payments as (
    select * from {{ ref('stg_order_payments') }}
),

order_reviews as (
    select * from {{ ref('stg_order_reviews') }}
),

-- aggregate items up to order level (an order can have many items)
items_agg as (
    select
        order_id,
        count(*)                         as item_count,
        count(distinct product_id)       as distinct_product_count,
        count(distinct seller_id)        as distinct_seller_count,
        sum(item_price)                  as total_items_price,
        sum(freight_value)               as total_freight_value,
        sum(total_item_value)            as total_order_value
    from order_items
    group by 1
),

-- aggregate payments up to order level (an order can have multiple payments)
payments_agg as (
    select
        order_id,
        count(*)                              as payment_count,
        sum(payment_amount)                   as total_paid,
        max(installment_count)                as max_installments,
        -- get the primary payment method (highest amount)
        array_agg(payment_type)
            within group (order by payment_amount desc) as payment_types
    from order_payments
    group by 1
),

-- get the review for this order (orders have at most one review typically)
reviews_agg as (
    select
        order_id,
        review_score,
        sentiment,
        review_created_at
    from order_reviews
    qualify row_number() over (
        partition by order_id order by review_created_at desc
    ) = 1
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchased_at,
        o.order_approved_at,
        o.order_shipped_at,
        o.order_delivered_at,
        o.order_estimated_delivery_at,
        o.delivery_delay_days,

        -- was this order delivered late?
        case
            when o.delivery_delay_days > 0 then true
            when o.delivery_delay_days <= 0 then false
        end as was_delivered_late,

        -- items
        coalesce(i.item_count, 0)              as item_count,
        coalesce(i.distinct_product_count, 0)  as distinct_product_count,
        coalesce(i.distinct_seller_count, 0)   as distinct_seller_count,
        i.total_items_price,
        i.total_freight_value,
        i.total_order_value,

        -- payments
        p.payment_count,
        p.total_paid,
        p.max_installments,
        p.payment_types,

        -- reviews
        r.review_score,
        r.sentiment,
        r.review_created_at

    from orders o
    left join items_agg    i on o.order_id = i.order_id
    left join payments_agg p on o.order_id = p.order_id
    left join reviews_agg  r on o.order_id = r.order_id
)

select * from final