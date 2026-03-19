-- =============================================================================
-- AI-Generated Analysis: Net Revenue per Customer Market Segment
-- Source: SNOWFLAKE_SAMPLE_DATA.TPCH_SF1
-- Approach: L_EXTENDEDPRICE * (1 - L_DISCOUNT) as "net revenue"
-- Filter: Fulfilled orders only (O_ORDERSTATUS = 'F')
-- Generated: 2026-03-18
-- =============================================================================

-- Net revenue = extended price after line-item discount, before tax.
-- This is "Analyst B's" interpretation: discount-adjusted revenue.
-- Contrast with gross revenue (L_EXTENDEDPRICE alone) or fully-loaded
-- revenue (applying both discount and tax).

-- Joins:
--   ORDERS 1:n LINEITEM  (one order has many line items)
--   ORDERS n:1 CUSTOMER  (many orders per customer)
-- Grain: one row per market segment (5 segments in TPCH)

SELECT
    c.C_MKTSEGMENT                                           AS market_segment,
    ROUND(SUM(li.L_EXTENDEDPRICE * (1 - li.L_DISCOUNT)), 2) AS net_revenue,
    COUNT(DISTINCT o.O_ORDERKEY)                             AS total_orders
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM li
    ON o.O_ORDERKEY = li.L_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
    ON o.O_CUSTKEY = c.C_CUSTKEY
WHERE o.O_ORDERSTATUS = 'F'
GROUP BY c.C_MKTSEGMENT
ORDER BY net_revenue DESC;
