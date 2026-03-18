-- Query the Semantic View using the SEMANTIC_VIEW() function
-- Same question as the raw SQL, but the metric definition is governed

SELECT * FROM SEMANTIC_VIEW(
    ANALYTICS.PUBLIC.TPCH_SEMANTIC_VIEW
    DIMENSIONS cust.market_segment
    METRICS li.total_revenue, ord.total_orders
)
ORDER BY total_revenue DESC;


-- Alternative: query using direct SQL with AGG()
SELECT
    market_segment,
    AGG(total_revenue) AS revenue,
    AGG(total_orders) AS orders
FROM ANALYTICS.PUBLIC.TPCH_SEMANTIC_VIEW
GROUP BY market_segment
ORDER BY revenue DESC;


-- Cleanup (run after recording)
-- DROP SEMANTIC VIEW ANALYTICS.PUBLIC.TPCH_SEMANTIC_VIEW;
