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

## The Problem: Inconsistent AI Answers

Ask an AI assistant "What was total revenue by market segment?" against raw schema, and it generates reasonable SQL. Ask it again with slightly different phrasing ("Show me net revenue per customer segment") and it generates different SQL with a different answer. Same data, same intent, different numbers.

This is not the AI's fault. The schema has both `L_EXTENDEDPRICE` and `L_DISCOUNT`, and the AI cannot know which one your business calls "revenue."

## Solution 1: Bundled (Snowflake Semantic Views)

Use an AI coding agent to create a Semantic View that defines "revenue" once:

```
I need you to create a Snowflake Semantic View for the TPCH sample dataset.
Create it in ANALYTICS.PUBLIC named TPCH_SEMANTIC_VIEW using ORDERS, CUSTOMER,
and LINEITEM from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1. Define relationships between
the tables, add market_segment and order_date as dimensions, and define
total_revenue as SUM(L_EXTENDEDPRICE) and total_orders as COUNT(DISTINCT
O_ORDERKEY) as metrics. Save the DDL to sql/create_semantic_view.sql and run it.
```

The agent will create `sql/create_semantic_view.sql` with the DDL and execute it against Snowflake. Review the generated code, then query via Cortex Analyst. Same answer regardless of how you phrase the question, because the metric definition is governed.

## Solution 2: Standalone (dbt MetricFlow)

Use an AI coding agent to set up a dbt project with the same metric definition:

```
On a new or existing feature branch, set up a dbt project in dbt_project/ with MetricFlow semantic layer definitions.
Create staging models for the three TPCH tables (ORDERS, CUSTOMER, LINEITEM from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1) that rename columns to snake_case.
Create a MetricFlow semantic model YAML with a total_revenue metric defined as SUM of extended_price, and total_orders as COUNT DISTINCT of order_id. Include market_segment and order_date as dimensions. Please test the syntax and ensure you have it right before executing.
Include a profiles.yml for Snowflake connection using the semantic_layer_demo profile.
If MetricFlow for dbt is not already configured, install it.
Once everything is set up, commit the work to the repo.
```

The agent will create the full `dbt_project/` directory with staging models, semantic model definitions, metric YAML, and connection config. Review the generated files, then query with MetricFlow:

```bash
mf query --metrics total_revenue --group-by customer__market_segment
```

Same answer. Different architecture. The metric definitions live in version control alongside your dbt models.

### How MetricFlow Enables AI

MetricFlow defines metrics as structured YAML that compiles to optimized SQL. When an AI agent needs "total revenue by market segment," it does not guess which columns to use or how to calculate it. The metric is defined once, and every query goes through that governed definition.

**With dbt Core** (what this demo uses), `mf query` compiles metric requests locally and runs the resulting SQL against your warehouse. This proves the definitions work and gives you a local query interface.

**With dbt Cloud** ($100/user/month for Semantic Layer access), the same metric definitions are exposed via a hosted API:

- **Semantic Layer API** (JDBC and GraphQL endpoints) lets any tool query governed metrics programmatically. [Tableau](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations), Power BI, Google Sheets, Hex, and other BI tools connect directly.
- **dbt MCP Server** ([docs](https://docs.getdbt.com/docs/dbt-ai/about-mcp)) gives AI agents a standardized interface to discover metrics (`list_metrics`), understand available dimensions (`get_dimensions`), and query governed results (`query_metrics`). The AI never writes raw SQL against your tables. It queries through the semantic layer.
- The query command becomes `dbt sl query` instead of `mf query`, with the same syntax.

The YAML definitions are the source of truth. `mf query` proves they work locally. The dbt Cloud API and MCP server are how AI agents and BI tools consume them in production.

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
├── ai_analysis_a.sql                      # Backup: AI-generated gross revenue query
├── ai_analysis_b.sql                      # Backup: AI-generated net revenue query
├── sql/                                   # Created during demo by AI
│   └── 2_create_semantic_view.sql         # Snowflake Semantic View DDL (AI-generated)
├── dbt_project/                           # Created during demo by AI
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── models/
│       ├── staging/                        # Staging models (AI-generated)
│       └── semantic/                       # MetricFlow definitions (AI-generated)
└── images/
    ├── diagram.excalidraw                  # Architecture diagram (source)
    └── diagram.png                         # Architecture diagram (rendered)
```

Note: The `sql/` and `dbt_project/` directories are created during the video demo using AI prompts. They are not pre-built.

## Resources

- [Snowflake Cortex Analyst Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [dbt MetricFlow Docs](https://docs.getdbt.com/docs/build/about-metricflow)
- [Spider 2.0 Paper](https://arxiv.org/abs/2411.07763) - Enterprise text-to-SQL accuracy benchmarks
- [Gartner 2026 D&A Predictions](https://www.gartner.com/en/newsroom/press-releases/2026-03-11-gartner-announces-top-predictions-for-data-and-analytics-in-2026)
- [O'Reilly: Semantic Layers in the Wild](https://www.oreilly.com/radar/semantic-layers-in-the-wild-lessons-from-early-adopters)
