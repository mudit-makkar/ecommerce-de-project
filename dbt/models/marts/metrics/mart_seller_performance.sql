with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
),

dim_sellers as (
    select * from {{ ref('dim_sellers') }}
),

fct_orders as (
    select order_id, was_delivered_late, review_score from {{ ref('fct_orders') }}
),

seller_items as (
    select
        oi.seller_key,
        o.order_id,
        oi.item_price,
        oi.freight_value,
        oi.category_name_english,
        o.was_delivered_late,
        o.review_score
    from fct_order_items oi
    left join fct_orders o on oi.order_id = o.order_id
),

agg as (
    select
        seller_key,
        count(distinct order_id)                  as total_orders,
        count(*)                                    as total_items_sold,
        sum(item_price)                             as total_revenue,
        avg(item_price)                             as avg_item_price,
        count(distinct category_name_english)       as distinct_categories_sold,
        avg(review_score)                            as avg_review_score,
        count(case when was_delivered_late then 1 end) as late_delivery_count

    from seller_items
    group by 1
)

select
    s.seller_key,
    s.seller_id,
    s.seller_city,
    s.seller_state,

    coalesce(a.total_orders, 0)            as total_orders,
    coalesce(a.total_items_sold, 0)        as total_items_sold,
    a.total_revenue,
    a.avg_item_price,
    a.distinct_categories_sold,
    a.avg_review_score,
    coalesce(a.late_delivery_count, 0)     as late_delivery_count,

    round(a.late_delivery_count / nullif(a.total_orders, 0) * 100, 2)
                                            as late_delivery_pct,

    -- simple seller tier
    case
        when a.total_revenue >= 10000 then 'top_seller'
        when a.total_revenue >= 1000  then 'mid_seller'
        when a.total_revenue > 0      then 'low_seller'
        else 'no_sales'
    end                                     as seller_tier

from dim_sellers s
left join agg a on s.seller_key = a.seller_key