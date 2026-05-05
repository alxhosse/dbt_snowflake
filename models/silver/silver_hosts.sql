{{ config(materialized='incremental', unique_key='HOST_ID') }}

SELECT
    HOSTS.HOST_ID,
    HOSTS.HOST_SINCE,
    HOSTS.IS_SUPERHOST,
    HOSTS.RESPONSE_RATE,
    HOSTS.CREATED_AT,
    REPLACE(HOST_NAME, ' ', '_') AS HOST_NAME,
    CASE
        WHEN HOSTS.RESPONSE_RATE > 95 THEN 'VERY GOOD'
        WHEN HOSTS.RESPONSE_RATE > 80 THEN 'GOOD'
        WHEN HOSTS.RESPONSE_RATE > 60 THEN 'FAIR'
        ELSE 'POOR'
    END AS RESPONSE_RATE_QUALITY
FROM {{ ref('bronze_hosts') }} AS HOSTS
{% if is_incremental() %}
    WHERE HOSTS.CREATED_AT > (
        SELECT COALESCE(MAX(THIS_MODEL.CREATED_AT), '1900-01-01')
        FROM {{ this }} AS THIS_MODEL
    )
{% endif %}
