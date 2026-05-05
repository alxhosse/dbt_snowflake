{{ config(materialized='incremental', unique_key='BOOKING_ID') }}

SELECT
    BOOKINGS.BOOKING_ID,
    BOOKINGS.LISTING_ID,
    BOOKINGS.BOOKING_DATE,
    {{ multiply('NIGHTS_BOOKED', 'BOOKING_AMOUNT', 2) }} AS TOTAL_AMOUNT,
    BOOKINGS.CLEANING_FEE,
    BOOKINGS.SERVICE_FEE,
    BOOKINGS.BOOKING_STATUS,
    BOOKINGS.CREATED_AT
FROM {{ ref('bronze_bookings') }} AS BOOKINGS
{% if is_incremental() %}
    WHERE BOOKINGS.CREATED_AT > (
        SELECT COALESCE(MAX(THIS_MODEL.CREATED_AT), '1900-01-01')
        FROM {{ this }} AS THIS_MODEL
    )
{% endif %}
