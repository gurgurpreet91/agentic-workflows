{{ config(materialized='view') }}

-- Campaign attribution: one attributed row per conversion, using a 7-day
-- attribution window and including view-through touchpoints.
-- Added touchpoint_type / touchpoint_ts for richer downstream reporting.
-- DISTINCT ensures conversion grain when multiple touchpoints exist.
select distinct
    c.conversion_id,
    c.user_id,
    c.campaign_id,
    c.campaign_name,
    c.conversion_date,
    t.touchpoint_type,
    t.touchpoint_ts
from {{ ref('stg_conversions') }} c
left join {{ ref('stg_touchpoints') }} t
    on  t.user_id      = c.user_id
    and t.campaign_id  = c.campaign_id
    and t.touchpoint_ts <= c.conversion_ts
    and t.touchpoint_ts >= c.conversion_ts - interval 7 day
where t.touchpoint_type in ('click', 'view')