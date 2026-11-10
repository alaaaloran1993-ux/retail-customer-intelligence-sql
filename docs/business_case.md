-- This document serves as the agreed scope of work with the fictional retailer client
-- The agreed business problem, analytical scope, objectives, deliverables prepared after Phase 1 & 2; the preliminary discovery and data feasibility stage

# Retail Customer Intelligence

## Business Case & Agreed Analytical Scope

**Project:** `retail-customer-intelligence-sql`  
**Client:** Fictional multi-store grocery retailer (consulting case study)  
**Data source:** dunnhumby — _The Complete Journey_ (historical, anonymized household-level retail data)  
**Primary technology:** PostgreSQL, VS Code, SQLTools  
**Document status:** Scope baseline for Phases 3–5 (case-study approval simulated)  
**Baseline version:** 1.0 — 10 November 2026

> **Case-study disclaimer:** The client brief and its management concerns are simulated for portfolio purposes. Dataset observations are real analyses of the publicly released data. No actual retailer commissioned or approved this project.

## 1. Business context

The retailer has detailed historical records of household purchases, products, campaign targeting, and coupon redemptions. Management wants to make better decisions about engaging existing shoppers, retaining valuable households, and identifying opportunities to increase customer value. Transaction records alone report what was sold; they do not readily explain how household purchasing patterns differ or which groups warrant attention.

## 2. Business problem

The retailer lacks a consolidated view of household shopping frequency, spending patterns, and signs of declining engagement. Without that view, it may struggle to prioritize retention initiatives or tailor customer engagement strategies.

**Central business question**

> Which household purchasing behaviors are associated with higher historical customer value, and how can the retailer use these insights to identify retention and revenue-growth opportunities?

This is an **observational** analysis. Associations will not be presented as evidence of causation, and historical monetary value will not be described as a forecast of customer lifetime value.

## 3. Project objective and decision outcomes

**Overall objective:** Analyze household purchasing behavior, identify high-value and potentially disengaging segments, and develop evidence-based recommendations to improve engagement, repeat purchasing, and long-term business value.

The project should enable management to:

- Understand typical and changing shopping behavior across households.
- Identify which types of behavior correlate with higher observed spending.
- Prioritize customer segments for further engagement or retention testing.
- Assess whether promotional engagement merits additional, targeted investigation.

## 4. Agreed analytical objectives and questions

### Objective 1 — Understand customer purchasing behavior

**Decision supported:** Which behavioral patterns signal sustained engagement or declining activity?

1. How frequently do households shop, and how much time typically passes between shopping trips?
2. How do purchasing frequency and spending patterns change over the observation period?
3. Which households show signs of declining purchase frequency or prolonged inactivity?

### Objective 2 — Identify customer value drivers

**Decision supported:** Which household behaviors and groups merit priority attention for business value?

4. How is sales revenue distributed across households, and how much comes from the highest-spending 10%?
5. Is higher household spending associated more strongly with shopping frequency, basket value, or both?
6. How do product category preferences and category diversity differ between high-value and lower-value households?

### Objective 3 — Identify retention and growth opportunities

**Decision supported:** Which households might benefit from differentiated engagement or retention initiatives?

7. How can households be segmented using Recency, Frequency, and Monetary (RFM) analysis?
8. Which segments contribute the most revenue, and which show warning signs of disengagement?
9. Which occasional or moderate-value households show potential for increased engagement?
10. How do coupon redemption and campaign participation differ across customer segments?
11. Are promotional engagement patterns associated with subsequent changes in purchasing frequency or spending?

**Scope status for questions 10–11:** Promotional engagement is a **provisional supporting analysis** under Objective 3. We will assess its usefulness later; any decision to remove it from the final deliverable or expand it materially must be recorded as a scope decision.

## 5. Key performance indicators

These are proposed KPI definitions, not yet final calculation specifications. The precise eligibility rules, denominators, lookback windows, and treatment of special records will be tested and documented in `docs/methodology.md` before final reporting.

| KPI                                 | Intended meaning                                                                                   |
| ----------------------------------- | -------------------------------------------------------------------------------------------------- |
| Active purchasing households        | Distinct households with at least one qualifying purchase in a defined period                      |
| Purchase frequency                  | Number of qualifying baskets per household within a defined period                                 |
| Average days between shopping trips | Average elapsed days between qualifying shopping days for households with repeated activity        |
| Average basket value                | Sales value per qualifying basket, using a documented revenue treatment                            |
| Revenue per household               | Observed sales value attributed to each household during the measurement window                    |
| Top 10% revenue contribution        | Share of observed revenue generated by the highest-spending decile of households                   |
| RFM segment distribution            | Household counts and shares in behavior-based segments                                             |
| At-risk high-value households       | High-value households meeting an explicitly justified inactivity or decline rule                   |
| Coupon redemption rate              | Redemption measure with an explicitly defined eligible/targeted population and unit of measurement |

Supporting measures (for example, total sales, shopping days, product-category mix, and campaign-period activity) may be computed where they help answer an agreed question. They are not separate project objectives.

## 6. Data sources and analytical unit

### Data Source

This project uses the dunnhumby – The Complete Journey
dataset, accessed through Kaggle.

The dataset contains approximately two years of
historical retail transactions from 2,500 households,
along with product, demographic, and promotional data.

Original data provider: dunnhumby

Dataset:
https://www.kaggle.com/datasets/frtgnn/dunnhumby-the-complete-journey

The portfolio uses **seven original dunnhumby tables**, with no new household master table:

| Table              | Role                                                                                         |
| ------------------ | -------------------------------------------------------------------------------------------- |
| `transaction_data` | Transaction lines, household IDs, basket IDs, relative days, quantities, sales and discounts |
| `product`          | Product attributes and category classifications                                              |
| `hh_demographic`   | Optional household characteristics for a limited subset                                      |
| `campaign_desc`    | Campaign type and relative date range                                                        |
| `campaign_table`   | Household campaign assignments                                                               |
| `coupon`           | Coupon–product–campaign associations                                                         |
| `coupon_redempt`   | Observed household coupon redemption events                                                  |

**Primary analytical entity:** A household (not an individual customer).  
**Transaction grain:** A line within a shopping basket.  
**Basket identifier:** `basket_id`; basket ID consistency by household, day, and store has been checked.  
**Observed period:** Relative days 1–711 (102 numbered weeks); actual calendar dates are not established.

The very large `causal_data.csv` is excluded from the initial project. Promotion conclusions must reflect the limited exposure information available in the seven retained tables.

## 7. Feasibility findings, assumptions and limitations

The preliminary data review established:

- The main transaction table has **2,595,732 lines** and **276,484 distinct baskets**.
- The source represents approximately **2,500 purchasing households**, but only **801** have demographic records; **1,699 (67.96%)** have no demographic profile. Any age/income analysis must be labeled as limited to the profiled subset and not assumed representative.
- All 711 relative days contain some recorded activity; no verified calendar dates are available for seasonal claims.
- The six initially checked transaction fields have no SQL `NULL` values; this does **not** prove every field is complete or every record is valid.
- No exact duplicate lines were found across the 12 transaction columns.
- Some lines have zero quantity and/or zero sales; blank-department records and coupon-only baskets have been investigated. Source rows will remain unmodified.
- Some very large quantities are gasoline-related; unit-based comparisons across departments may be misleading without documented measurement rules.
- A basket may be recorded without a positive-value merchandise purchase. The **proposed** qualifying-purchase rule is: at least one line with `quantity > 0` and `sales_value > 0`. This rule needs a **dataset-wide impact check** before adoption for final KPIs.
- The data is observational and historical. Inactivity is not proof of permanent churn; promotional associations do not establish campaign lift or causality.

Detailed quality queries and evidence are retained in `sql/02_data_quality/`.

## 8. Scope boundaries

**In scope**

- Household shopping frequency, intervals and changes over the observed window.
- Historical household monetary contribution and differences in basket behavior.
- Product-category preferences as a supporting explanation of customer value.
- RFM segmentation, potential inactivity flags and segment-level opportunities.
- A limited descriptive exploration of campaign participation and coupon redemption under Objective 3.
- SQL scripts, documented metric logic, aggregated outputs, and recommendations supported by the data.

**Out of scope**

- Predictive lifetime value, causal uplift, definitive churn prediction, and experimental proof of intervention effectiveness.
- Full market-basket association mining or recommendation-engine development.
- Complete pricing, profitability or margin optimization (cost/margin information is unavailable).
- Claims about current consumer trends based on this historical dataset.
- Creating a separate `households` table or changing the original source tables merely for presentation.
- Full analysis of `causal_data.csv` in the current baseline.

## 9. Expected deliverables and success criteria

**Deliverables**

1. Reproducible and annotated PostgreSQL analysis scripts aligned with the three objectives.
2. A documented methodology defining qualifying purchases, revenue, RFM rules, and exclusions.
3. Concise, aggregated result tables and selected visuals supporting the key findings.
4. A final management-oriented insight report with evidence, uncertainties, and practical actions to test.
5. A GitHub README explaining the business case, data source, workflow, and navigation.

**Success criteria**

- Each of the three objectives is addressed with relevant evidence, or an explicit explanation of a data limitation.
- All headline KPIs have a clear definition, unit, time window and data-handling policy.
- Recommendations are linked to findings, not assumptions presented as facts.
- Raw data is preserved locally; large CSVs and sensitive local file paths are not published.
- A reviewer can follow the SQL logic and understand how outputs connect to business decisions.

## 10. Governance and change control

This document is the **scope baseline** for Phases 3–5. We will not silently rewrite objectives or add major analytical workstreams during analysis.

- **Methodology refinement:** Document in `docs/methodology.md` (for example, deciding a justified inactivity threshold or filtering rule). This does not automatically change the business scope.
- **Material scope change:** Record separately with date, proposed change, reason, implications for objectives/deliverables, and decision status before revising this baseline. This includes dropping agreed questions, adding a new objective, or expanding optional promotion analysis substantially.
- **Findings and recommendations:** Record later in `docs/final_insights.md`, not as retrospective edits to this initial business case.

**Baseline decision:** Proceed with Objectives 1–3, keeping promotion questions 10–11 provisionally under Objective 3, subject to an explicit later decision.
