with customers as (
    select * from {{ ref('stg_customers') }}
),

orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
),

customer_order_stats as (
    select
        customer_id,
        count(distinct order_id)                  as total_orders,
        sum(total_order_value)                     as lifetime_value,
        avg(total_order_value)                      as avg_order_value,
        min(order_purchased_at)                     as first_order_at,
        max(order_purchased_at)                     as most_recent_order_at,
        avg(review_score)                            as avg_review_score,
        sum(case when was_delivered_late then 1 else 0 end) as late_delivery_count
    from orders_enriched
    group by 1
),

final as (
    select
        c.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.zip_code,

        coalesce(cos.total_orders, 0)         as total_orders,
        cos.lifetime_value,
        cos.avg_order_value,
        cos.first_order_at,
        cos.most_recent_order_at,
        cos.avg_review_score,
        coalesce(cos.late_delivery_count, 0)  as late_delivery_count,

        -- days since last order — useful for churn analysis
        datediff('day', cos.most_recent_order_at, current_timestamp())
                                                as days_since_last_order,

        -- simple customer segment
        case
            when cos.total_orders >= 3 then 'repeat_customer'
            when cos.total_orders = 2 then 'returning_customer'
            when cos.total_orders = 1 then 'one_time_customer'
            else 'no_orders'
        end                                     as customer_segment

    from customers c
    left join customer_order_stats cos on c.customer_id = cos.customer_id
)

select * from final