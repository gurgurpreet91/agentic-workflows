{{ config(materialized='view') }}

-- Campaign scorecard: conversions per campaign, joined to the campaign
-- dimension. dim_campaign is SCD-style (keeps historical rows), so we filter to
-- the current row to avoid fanning out conversions across stale versions.
select
    d.campaign_name,
    count(*) as conversions
from {{ ref('stg_conversions') }} c
join {{ source('marketing', 'dim_campaign') }} d
    on  d.campaign_id = c.campaign_id
    and d.is_current
group by d.campaign_name