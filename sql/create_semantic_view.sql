-- Snowflake Semantic View: TPCH_SEMANTIC_VIEW
-- Provides governed metric definitions for TPCH revenue analysis
-- Optimized for Cortex Analyst natural language querying

USE WAREHOUSE COMPUTE_EXTRA_SMALL;
USE DATABASE ANALYTICS;
USE SCHEMA PUBLIC;

CREATE OR REPLACE SEMANTIC VIEW TPCH_SEMANTIC_VIEW
  TABLES (
    customers AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
      PRIMARY KEY (C_CUSTKEY)
      WITH SYNONYMS = ('customer', 'buyers')
      COMMENT = 'Customer master data including market segment classification. Each customer belongs to one of five market segments: AUTOMOBILE, BUILDING, FURNITURE, HOUSEHOLD, or MACHINERY.',
    orders AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
      PRIMARY KEY (O_ORDERKEY)
      WITH SYNONYMS = ('order', 'purchases')
      COMMENT = 'Order headers with order date, status, and priority. One customer can have many orders.',
    line_items AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
      PRIMARY KEY (L_ORDERKEY, L_LINENUMBER)
      WITH SYNONYMS = ('line item', 'order lines')
      COMMENT = 'Order line items with pricing (extended price, discount, tax). Each order has one or more line items. L_EXTENDEDPRICE is the gross price before any adjustments.'
  )
  RELATIONSHIPS (
    orders_to_customers AS orders (O_CUSTKEY) REFERENCES customers,
    line_items_to_orders AS line_items (L_ORDERKEY) REFERENCES orders
  )
  DIMENSIONS (
    customers.market_segment AS C_MKTSEGMENT
      WITH SYNONYMS = ('segment', 'customer segment', 'business segment', 'mktsegment')
      COMMENT = 'Customer market segment: AUTOMOBILE, BUILDING, FURNITURE, HOUSEHOLD, or MACHINERY',
    orders.order_date AS O_ORDERDATE
      WITH SYNONYMS = ('date', 'order date', 'purchase date')
      COMMENT = 'Date the order was placed'
  )
  METRICS (
    line_items.total_revenue AS SUM(L_EXTENDEDPRICE)
      WITH SYNONYMS = ('revenue', 'total sales', 'sales', 'gross revenue')
      COMMENT = 'Total gross revenue: sum of line item extended prices before discounts and tax',
    orders.total_orders AS COUNT(DISTINCT O_ORDERKEY)
      WITH SYNONYMS = ('order count', 'number of orders', 'orders')
      COMMENT = 'Total number of distinct orders'
  )
  COMMENT = 'Governed semantic layer for TPCH revenue analysis. Use this view to answer questions about revenue, orders, and market segments. Revenue is defined as the sum of extended price (gross, before discounts and tax).'
;
