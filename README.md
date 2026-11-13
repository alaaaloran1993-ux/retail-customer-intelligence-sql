# Retail Customer Intelligence

## Customer Behavior, Loyalty & Value Analysis Using PostgreSQL

A SQL portfolio project analyzing real retail transaction data from the dunnhumby Complete Journey dataset.

### Tools

- PostgreSQL
- VS Code
- SQLTools
- Git & GitHub

### Project Status

Phase 1 — Business Understanding & Database Setup

### Dataset

dunnhumby — The Complete Journey

The original dataset files are excluded from this repository.

## Customer Purchasing Behavior

### Weekly Purchasing Activity

![Weekly Purchasing Activity](outputs/charts/01_obj1_weekly_purchasing_activity.png)

### Weekly Customer Spending

![Weekly Customer Spending](outputs/charts/02_obj1_weekly_customer_spending.png)

### Customer Purchasing Activity Status

![Customer Activity Status](outputs/charts/03_obj1_customer_activity_status.png)

## Objective 2: Identify Customer Value Drivers

This analysis examines how recorded sales are distributed
across households, what distinguishes higher-spending
customers, and how purchasing preferences differ.

### Key Findings

- **Revenue concentration:** The top 10% of households
  generated 34.29% of total recorded sales, while the
  top 20% contributed 53.05%.
- **Spending drivers:** Shopping frequency showed a
  stronger positive correlation with total spending
  (0.703) than average basket value (0.390).
- **Department preferences:** Grocery represented the
  largest share of spending for both high-value and
  lower-value households.
- **Category diversity:** High-value households purchased
  from an average of 16.14 departments, compared with
  11.31 for lower-value households.

### Business Implications

The retailer's sales are concentrated among a relatively
small group of households. Maintaining their engagement
may help protect sales, while encouraging repeat purchases
and broader department exploration among lower-spending
households may offer growth opportunities.

These findings describe historical purchasing patterns;
they do not establish causation or customer profitability.

### Visualizations

![Customer Revenue Distribution](outputs/charts/customer_revenue_by_decile.png)

![Department Spending Mix](outputs/charts/department_spending_mix.png)

![Category Diversity](outputs/charts/category_diversity_by_customer_group.png)
