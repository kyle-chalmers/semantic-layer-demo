-- AI Analysis A: Total Revenue by Market Segment
-- Approach: SUM of extended price across ALL orders (no filters)
-- Source: SNOWFLAKE_SAMPLE_DATA.TPCH_SF1
-- Revenue definition: L_EXTENDEDPRICE (gross line item price before discounts)

SELECT
    c.c_mktsegment  AS market_segment,
    SUM(l.l_extendedprice) AS total_revenue
FROM snowflake_sample_data.tpch_sf1.lineitem   l
JOIN snowflake_sample_data.tpch_sf1.orders     o ON l.l_orderkey = o.o_orderkey
JOIN snowflake_sample_data.tpch_sf1.customer   c ON o.o_custkey  = c.c_custkey
GROUP BY c.c_mktsegment
ORDER BY total_revenue DESC;
