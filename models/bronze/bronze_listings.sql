{{ config(materialized='incremental') }}
SELECT listings.* FROM {{ source('staging', 'listings') }} AS listings

{% if is_incremental() %}
    WHERE
        listings.created_at
        > (
            SELECT COALESCE(MAX(this_model.created_at), '1970-01-01')
            FROM {{ this }} AS this_model
        )
{% endif %}
