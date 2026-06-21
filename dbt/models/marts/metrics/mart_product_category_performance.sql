with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
),

fct_orders as (
    select order_id, review_score from {{ ref('fct_orders') }}
),

joined as (
    select
        oi.category_name_english,
        oi.order_id,
        oi.item_price,
        oi.freight_value,
        o.review_score
    from fct_order_items oi
    left join fct_orders o on oi.order_id = o.order_id
    where oi.category_name_english is not null
)

select
    category_name_english,
    count(distinct order_id)            as total_orders,
    count(*)                              as total_items_sold,
    sum(item_price)                       as total_revenue,
    avg(item_price)                       as avg_item_price,
    sum(freight_value)                    as total_freight_cost,
    avg(review_score)                      as avg_review_score

from joined
group by 1
order by total_revenue desc