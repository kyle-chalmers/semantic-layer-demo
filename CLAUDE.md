# Semantic Layer Demo - AI Context

> IMPORTANT: Everything in this repo is public-facing, so do not place any sensitive info here and make sure to distinguish between what should be internal-facing info (e.g. secrets, PII, recording guides/scripts), and public-facing info (instructions, how-to guides, actual code utilized). If there is information that Claude Code needs across sessions but should not be published, put it in the `.internal/` folder which is ignored by git per the `.gitignore`.

## Project Overview

Companion repo for the KC Labs AI video "Semantic Layers: The Skill Data Professionals Need Next." Demonstrates two approaches to semantic layers using Snowflake's TPCH sample data:

1. **Bundled (Snowflake Semantic Views + Cortex Analyst)**: Warehouse-native semantic layer
2. **Standalone (dbt MetricFlow)**: Transformation-layer semantic layer with `mf query`

Target audience: data analysts and BI engineers learning about semantic layers.

## Available Tools

- **Snowflake CLI**: `snow sql -q "QUERY" --format csv`
- **dbt Core**: `dbt run`, `dbt test`, `dbt compile`
- **MetricFlow**: `mf query --metrics METRIC --group-by DIMENSION` (after `pip install dbt-metricflow[snowflake]`)

## Data Source

Snowflake's built-in TPCH sample data (`SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`):
- `ORDERS`: 1.5M rows, order header data
- `CUSTOMER`: 150K rows, customer demographics including market segment
- `LINEITEM`: 6M rows, order line items with pricing

No data loading needed. Every Snowflake account has this dataset.

## Snowflake Semantic View DDL Reference

Clause order matters: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS → COMMENT.

```sql
CREATE [OR REPLACE] SEMANTIC VIEW <name>
  TABLES (
    <alias> AS <fully_qualified_table>
      PRIMARY KEY (<columns>)
      [WITH SYNONYMS = ('<synonym>', ...)]
      [COMMENT = '<description>']
  )
  [RELATIONSHIPS (
    <name> AS <alias> (<fk_columns>) REFERENCES <ref_alias>
  )]
  [FACTS (
    [PRIVATE|PUBLIC] <table>.<fact> AS <expression>
      [WITH SYNONYMS = (...)] [COMMENT = '...']
  )]
  DIMENSIONS (
    <table>.<dimension> AS <expression>
      [WITH SYNONYMS = (...)] [COMMENT = '...']
  )
  METRICS (
    <table>.<metric> AS <aggregate_expression>
      [WITH SYNONYMS = (...)] [COMMENT = '...']
  )
  [COMMENT = '<view-level comment>']
  [AI_SQL_GENERATION '<instructions>']
  [AI_QUESTION_CATEGORIZATION '<instructions>']
;
```

**Cortex Analyst optimization:**
- Rich COMMENTs on view, tables, dimensions, and metrics — Cortex Analyst reads these to map natural language to columns
- `WITH SYNONYMS` on dimensions/metrics maps alternate phrasings (e.g., "revenue", "sales", "total sales") to the correct object
- View-level COMMENT should state what the view covers and define ambiguous terms (e.g., "revenue = gross extended price before discounts")
- Table COMMENTs should describe cardinality and column semantics

**Execution:** `snow sql -f sql/create_semantic_view.sql`
**Verification:** `SHOW SEMANTIC VIEWS IN SCHEMA <db>.<schema>` and `DESCRIBE SEMANTIC VIEW <name>`

## Code Conventions

- SQL: uppercase keywords, lowercase aliases, Snowflake Standard SQL
- dbt: snake_case model names, staging models prefix with `stg_`
- MetricFlow: YAML definitions in `models/semantic/`

## Demo Flow

1. Show raw SQL problem: two analysts, same question, different answers
2. Create Semantic View in Snowflake (bundled approach)
3. Query via SEMANTIC_VIEW() function, show consistent results
4. Switch to dbt project, show MetricFlow YAML definitions (standalone approach)
5. Install MetricFlow, query with `mf query`, show same results
