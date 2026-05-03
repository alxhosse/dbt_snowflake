{{ config(materialized='incremental') }}

SELECT bookings.* FROM {{ source('staging', 'bookings') }} AS bookings

{% if is_incremental() %}
    WHERE
        bookings.created_at
        > (
            SELECT COALESCE(MAX(this_model.created_at), '1970-01-01')
            FROM {{ this }} AS this_model
        )
{% endif %}
