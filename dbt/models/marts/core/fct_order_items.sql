with items_enriched as (
    select * from {{ ref('int_order_items_enriched') }}
),

dim_products as (
    select product_key, product_id from {{ ref('dim_products') }}
),

dim_sellers as (
    select seller_key, seller_id from {{ ref('dim_sellers') }}
)

select
    i.order_item_sk,
    i.order_id,
    dp.product_key,
    ds.seller_key,

    cast(i.order_purchased_at as date)   as order_purchase_date_key,

    i.order_item_sequence,
    i.category_name_english,
    i.item_price,
    i.freight_value,
    i.total_item_value,
    i.freight_pct_of_price,
    i.shipping_limit_at

from items_enriched i
left join dim_products dp on i.product_id = dp.product_id
left join dim_sellers ds  on i.seller_id  = ds.seller_id