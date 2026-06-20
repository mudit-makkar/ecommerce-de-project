with source as (
    select * from {{ source('ecommerce', 'order_reviews') }}
),

renamed as (
    select
        review_id,
        order_id,
        review_score::integer               as review_score,
        review_comment_title,
        review_comment_message,

        -- classify sentiment from score
        case review_score::integer
            when 5 then 'very_positive'
            when 4 then 'positive'
            when 3 then 'neutral'
            when 2 then 'negative'
            when 1 then 'very_negative'
        end                                 as sentiment,

        try_to_timestamp(review_creation_date)    as review_created_at,
        try_to_timestamp(review_answer_timestamp) as review_answered_at,
        _loaded_at
    from source
)

select * from renamed
