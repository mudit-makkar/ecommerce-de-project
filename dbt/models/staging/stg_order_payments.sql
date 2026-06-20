with source as (
    select * from {{ source('ecommerce', 'order_payments') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'payment_sequential']) }}
                                        as payment_sk,
        order_id,
        payment_sequential::integer     as payment_sequence,
        payment_type,
        payment_installments::integer   as installment_count,
        payment_value::numeric(10,2)    as payment_amount,
        _loaded_at
    from source
)

select * from renamed

/*
payment_sequential --> 1,2,3,... 
if a payment is being done through multiple models for a single order such as credit card and vouchers.
each payment_sequential represents one mode for that order.
*/