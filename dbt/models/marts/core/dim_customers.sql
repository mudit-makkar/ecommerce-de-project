with customers_enriched as (
    select * from {{ ref('int_customers_enriched') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }}  as customer_key,
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    zip_code,
    total_orders,
    lifetime_value,
    avg_order_value,
    first_order_at,
    most_recent_order_at,
    avg_review_score,
    late_delivery_count,
    days_since_last_order,
    customer_segment
from customers_enriched