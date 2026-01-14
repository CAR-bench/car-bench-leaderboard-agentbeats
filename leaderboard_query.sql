-- This is a DuckDB SQL query over `read_json_auto('results/*.json') AS results`
-- CAR-bench AgentBeats Leaderboard

SELECT
    id, -- The AgentBeats agent ID (UUID) is always required to be the first column
    -- Overall score (sort key)
    COALESCE(CAST(ROUND(avg_pass_power_3 * 100, 0) AS VARCHAR), '-') AS "Overall Pass^3",
    -- BASE
    CAST(ROUND(base_pass_power_1 * 100, 0) AS VARCHAR) AS "Base Pass^1",
    COALESCE(CAST(ROUND(base_pass_power_3 * 100, 0) AS VARCHAR), '-') AS "Base Pass^3",
    COALESCE(CAST(ROUND(base_pass_at_3 * 100, 0) AS VARCHAR), '-') AS "Base Pass@3",
    -- HALLUCINATION
    CAST(ROUND(hall_pass_power_1 * 100, 0) AS VARCHAR) AS "Hallucination Pass^1",
    COALESCE(CAST(ROUND(hall_pass_power_3 * 100, 0) AS VARCHAR), '-') AS "Hallucination Pass^3",
    COALESCE(CAST(ROUND(hall_pass_at_3 * 100, 0) AS VARCHAR), '-') AS "Hallucination Pass@3",
    -- DISAMBIGUATION
    CAST(ROUND(dis_pass_power_1 * 100, 0) AS VARCHAR) AS "Disambiguation Pass^1",
    COALESCE(CAST(ROUND(dis_pass_power_3 * 100, 0) AS VARCHAR), '-') AS "Disambiguation Pass^3",
    COALESCE(CAST(ROUND(dis_pass_at_3 * 100, 0) AS VARCHAR), '-') AS "Disambiguation Pass@3",
    -- TIME
    CAST(ROUND(time_used, 1) AS VARCHAR) AS "Time (s)"
FROM ( -- The AgentBeats app automatically reads the JSON results into this table
    SELECT
        CAST(results.participants.agent AS VARCHAR) AS id,
        -- Overall average Pass^3 (primary sort key)
        AVG(res.pass_power_k_scores."Pass^3") AS avg_pass_power_3,
        -- Time
        AVG(res.time_used) AS time_used,
        -- Base split metrics
        AVG(res.pass_power_k_scores_by_split.base."Pass^1") AS base_pass_power_1,
        AVG(res.pass_power_k_scores_by_split.base."Pass^3") AS base_pass_power_3,
        AVG(res.pass_at_k_scores_by_split.base."Pass@3") AS base_pass_at_3,
        -- Hallucination split metrics
        AVG(res.pass_power_k_scores_by_split.hallucination."Pass^1") AS hall_pass_power_1,
        AVG(res.pass_power_k_scores_by_split.hallucination."Pass^3") AS hall_pass_power_3,
        AVG(res.pass_at_k_scores_by_split.hallucination."Pass@3") AS hall_pass_at_3,
        -- Disambiguation split metrics
        AVG(res.pass_power_k_scores_by_split.disambiguation."Pass^1") AS dis_pass_power_1,
        AVG(res.pass_power_k_scores_by_split.disambiguation."Pass^3") AS dis_pass_power_3,
        AVG(res.pass_at_k_scores_by_split.disambiguation."Pass@3") AS dis_pass_at_3
    FROM results
    CROSS JOIN UNNEST(results.results) AS r(res)
    WHERE results.participants.agent IS NOT NULL
    GROUP BY CAST(results.participants.agent AS VARCHAR)
) AS agent_metrics
ORDER BY avg_pass_power_3 DESC;
