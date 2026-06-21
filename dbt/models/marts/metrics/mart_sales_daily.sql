with fct_orders as (
    select * from {{ ref('fct_orders') }}
),

daily as (
    select
        order_purchase_date_key                          as order_date,
        count(distinct order_id)                          as total_orders,
        sum(total_order_value)                            as total_revenue,
        sum(total_freight_value)                          as total_freight_revenue,
        avg(total_order_value)                            as avg_order_value,
        sum(item_count)                                   as total_items_sold,

        -- delivery performance
        count(case when was_delivered_late then 1 end)    as late_deliveries,
        count(case when order_delivered_at is not null then 1 end)
                                                            as completed_deliveries,

        -- customer satisfaction
        avg(review_score)                                  as avg_review_score,
        count(case when sentiment in ('very_negative','negative') then 1 end)
                                                            as negative_reviews

    from fct_orders
    where order_purchase_date_key is not null
    group by 1
)

select
    order_date,
    total_orders,
    total_revenue,
    total_freight_revenue,
    avg_order_value,
    total_items_sold,
    late_deliveries,
    completed_deliveries,

    -- late delivery rate as a %
    round(late_deliveries / nullif(completed_deliveries, 0) * 100, 2)
                                            as late_delivery_pct,

    avg_review_score,
    negative_reviews

from daily
order by order_date