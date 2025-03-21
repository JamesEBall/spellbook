{{ config(
    alias = 'positions_liquidation'
    )
 }}

WITH 

last_margin as (
    SELECT 
        evt_block_time,
        position_id,
        version,
        margin,
        evt_index
    FROM 
    (
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY position_id, version ORDER BY evt_index DESC) as rank_,
            * 
        FROM 
        (
            SELECT 
                xx.evt_block_time,
                xx.position_id,
                xx.version, 
                xy.margin,
                xy.evt_index
            FROM 
            (
            SELECT 
                MAX(evt_block_time) as evt_block_time,
                position_id,
                version 
            FROM 
            {{ ref('tigris_polygon_positions_margin') }}
            GROUP BY 2, 3 
            ) xx 
            INNER JOIN 
            {{ ref('tigris_polygon_positions_margin') }} xy 
                ON xx.evt_block_time = xy.evt_block_time
                AND xx.position_id = xy.position_id
                AND xx.version = xy.version
        ) tmp 
    ) tmp_2
    WHERE rank_ = 1 
),

last_leverage as (
    SELECT 
        evt_block_time,
        position_id,
        version,
        leverage,
        evt_index 
    FROM 
    (
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY position_id, version ORDER BY evt_index DESC) as rank_,
            * 
        FROM 
        (
            SELECT 
                xx.evt_block_time,
                xx.position_id,
                xx.version, 
                xy.leverage,
                xy.evt_index
            FROM 
            (
            SELECT 
                MAX(evt_block_time) as evt_block_time,
                position_id,
                version 
            FROM 
            {{ ref('tigris_polygon_positions_leverage') }}
            GROUP BY 2, 3 
            ) xx 
            INNER JOIN 
            {{ ref('tigris_polygon_positions_leverage') }} xy 
                ON xx.evt_block_time = xy.evt_block_time
                AND xx.position_id = xy.position_id
                AND xx.version = xy.version
        ) tmp 
    ) tmp_2
    WHERE rank_ = 1 
)

SELECT 
    lp.*, 
    lm.margin, 
    ll.leverage 
FROM 
{{ ref('tigris_polygon_events_liquidate_position') }} lp 
INNER JOIN 
last_margin lm 
    ON lp.position_id = lm.position_id
    AND lp.version = lm.version
INNER JOIN 
last_leverage ll 
    ON lp.position_id = ll.position_id
    AND lp.version = ll.version
;