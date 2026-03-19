# Semantic Layers: The Skill Data Professionals Need Next

Companion repository for the [KC Labs AI](https://www.youtube.com/@kclabsai) video on semantic layers. Demonstrates the **bundled vs standalone** approaches using Snowflake's TPCH sample data.

## What You'll Learn

- What a semantic layer is and why AI made it essential
- The difference between bundled (Snowflake Semantic Views) and standalone (dbt MetricFlow) approaches
- How to create and query a Snowflake Semantic View
- How to define metrics with dbt MetricFlow and query them with `mf query`

## Architecture

![Semantic Layer Architecture](./images/diagram.png?v=2)

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Snowflake](https://signup.snowflake.com/) | Any edition | Warehouse + Semantic Views + Cortex Analyst |
| [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli) | Latest | Running SQL from terminal |
| [dbt Core](https://docs.getdbt.com/docs/core/installation) | 1.10+ | Transformation framework |
| [dbt-snowflake](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup) | 1.10+ | Snowflake adapter for dbt |
| Python | 3.9+ | Runtime for dbt and MetricFlow |

Snowflake offers a free trial with $400 in credits (no credit card required).

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/kyle-chalmers/semantic-layer-demo.git
   cd semantic-layer-demo
   ```

2. **Configure Snowflake connection**
   ```bash
   cp .env.example .env
   # Edit .env with your Snowflake account details
   ```

3. **Verify Snowflake access** (TPCH data is built-in, no loading needed)
   ```bash
   snow sql -q "SELECT COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS"
   ```

4. **Install MetricFlow**
   ```bash
   pip install dbt-metricflow[snowflake]
   ```

5. **Run dbt models**
   ```bash
   cd dbt_project
   dbt run
   ```

## The Problem: Inconsistent Metrics

Two analysts answering "What was revenue by market segment?" can get different numbers:

| File | Approach | Result |
|------|----------|--------|
| `sql/1_raw_sql_AI_analysis_a.sql` | SUM(L_EXTENDEDPRICE), all orders | $229B total |
| `sql/1_raw_sql_AI_analysis_B.sql` | SUM(price * (1 - discount)), fulfilled only | $172B total |

Same question, different answers. This is the problem a semantic layer solves.

## Solution 1: Bundled (Snowflake Semantic Views)

Create a Semantic View that defines "revenue" once:

```sql
-- sql/2_create_semantic_view.sql
CREATE OR REPLACE SEMANTIC VIEW ANALYTICS.PUBLIC.TPCH_SEMANTIC_VIEW
  TABLES (...)
  RELATIONSHIPS (...)
  DIMENSIONS (cust.market_segment AS C_MKTSEGMENT, ...)
  METRICS (li.total_revenue AS SUM(L_EXTENDEDPRICE), ...)
```

Query it and get consistent results:

```sql
-- sql/3_query_semantic_view.sql
SELECT * FROM SEMANTIC_VIEW(
    ANALYTICS.PUBLIC.TPCH_SEMANTIC_VIEW
    DIMENSIONS cust.market_segment
    METRICS li.total_revenue, ord.total_orders
) ORDER BY total_revenue DESC;
```

## Solution 2: Standalone (dbt MetricFlow)

Define the same metric in YAML:

```yaml
# dbt_project/models/semantic/metrics.yml
metrics:
  - name: total_revenue
    type: simple
    type_params:
      measure: total_revenue
    description: "Sum of extended price across all line items"
```

Query with MetricFlow:

```bash
mf query --metrics total_revenue --group-by customer__market_segment
```

Same answer. Different architecture.

## Bundled vs Standalone: Which to Choose?

| Aspect | Bundled (Snowflake) | Standalone (dbt MetricFlow) |
|--------|--------------------|-----------------------------|
| Setup | Zero additional tools | dbt project + MetricFlow install |
| Where it lives | Inside your warehouse | In your transformation layer (version controlled) |
| Consumers | Primarily native tools; Tableau and Power BI can connect via TDS export / DirectQuery | Any tool via API (BI, AI agents, apps) |
| Best for | Teams all-in on one platform | Teams with multiple downstream consumers |

## Semantic Layer Tool Reference

For a comprehensive breakdown of all semantic layer tools (bundled and standalone) with pricing, AI integration, and getting-started links, see the video description.

### Standalone Tools
- [Cube](https://cube.dev) - API-first semantic layer / headless BI
- [dbt MetricFlow](https://www.getdbt.com/product/semantic-layer) - Transformation-layer semantic layer
- [AtScale](https://www.atscale.com) - Universal semantic layer
- [Honeydew](https://honeydew.ai) - Snowflake-native semantic layer
- [Lightdash](https://www.lightdash.com) - Open-source dbt-native BI

### Bundled Tools
- [Snowflake Semantic Views](https://docs.snowflake.com/en/user-guide/views-semantic/overview)
- [Google Looker / LookML](https://cloud.google.com/looker)
- [Microsoft Power BI](https://learn.microsoft.com/en-us/power-bi/)
- [Tableau Semantics](https://www.tableau.com/products/tableau-next)
- [Databricks AI/BI](https://docs.databricks.com/en/ai-bi/index.html)

### Industry Initiative
- [Open Semantic Interchange (OSI)](https://open-semantic-interchange.org) - Vendor-neutral spec, v1.0 finalized January 2026

## Project Structure

```
semantic-layer-demo/
├── README.md                              # This file
├── CLAUDE.md                              # AI assistant context
├── .env.example                           # Snowflake connection template
├── sql/
│   ├── 1_raw_sql_AI_analysis_a.sql            # "Revenue" query version A
│   ├── 1_raw_sql_AI_analysis_B.sql            # "Revenue" query version B (different answer)
│   ├── 2_create_semantic_view.sql         # Snowflake Semantic View DDL
│   └── 3_query_semantic_view.sql          # Query the Semantic View
├── dbt_project/
│   ├── dbt_project.yml                    # dbt configuration
│   ├── profiles.yml                       # Snowflake connection profile
│   └── models/
│       ├── staging/                        # Staging models (rename TPCH columns)
│       │   ├── schema.yml                  # Source definitions
│       │   ├── stg_orders.sql
│       │   ├── stg_customers.sql
│       │   └── stg_lineitem.sql
│       └── semantic/                       # MetricFlow definitions
│           ├── semantic_models.yml         # Entities, dimensions, measures
│           └── metrics.yml                 # Metric definitions
└── images/
    ├── diagram.excalidraw                  # Architecture diagram (source)
    └── diagram.png                         # Architecture diagram (rendered)
```

## Resources

- [Snowflake Cortex Analyst Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [dbt MetricFlow Docs](https://docs.getdbt.com/docs/build/about-metricflow)
- [Spider 2.0 Paper](https://arxiv.org/abs/2411.07763) - Enterprise text-to-SQL accuracy benchmarks
- [Gartner 2026 D&A Predictions](https://www.gartner.com/en/newsroom/press-releases/2026-03-11-gartner-announces-top-predictions-for-data-and-analytics-in-2026)
- [O'Reilly: Semantic Layers in the Wild](https://www.oreilly.com/radar/semantic-layers-in-the-wild-lessons-from-early-adopters)
