{{config(alias='safe_ethereum')}}

SELECT
    'ethereum' as blockchain,
    address,
    'Safe'  || ' version ' || creation_version AS name,
    'safe' AS category,
    'soispoke' AS contributor,
    'query' AS source,
    timestamp('2022-09-01') as created_at,
    now() as updated_at,
    'safe_ethereum' AS model_name,
    'identifier' AS label_type
FROM {{ ref('safe_ethereum_safes') }}