{{ config(materialized='incremental') }}

SELECT hosts.* FROM {{ source('staging', 'hosts') }} AS hosts

{% if is_incremental() %}
    WHERE
        hosts.created_at
        > (
            SELECT COALESCE(MAX(this_model.created_at), '1970-01-01')
            FROM {{ this }} AS this_model
        )
{% endif %}
