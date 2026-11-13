-- The Evidence, business interpretation, recommendations

# Retail Customer Intelligence — Findings & Business Implications

> **Project status:** Objective 1 completed. Objectives 2 and 3 will be added as the analysis progresses.
>
> **Context:** This is a portfolio analysis of the dunnhumby _The Complete Journey_ dataset, using a hypothetical retail client scenario.

## Objective 1 — Understand Customer Purchasing Behavior

### Q1. How frequently do households shop, and how much time typically passes between shopping trips?

Across **2,500 purchasing households**, the dataset contains **275,539 qualifying baskets** over **711 days**. The median household recorded **78 baskets**, while the median gap between consecutive purchasing days was **3 days**.

**Business insight:** Customers have different shopping habits. The retailer should consider both how often households purchase and how regularly they return when assessing engagement.

### Q2. How do purchasing frequency and spending patterns change over the observation period?

Purchasing activity increased rapidly during approximately the first **17 weeks** before becoming relatively stable. In later weeks, recorded sales were generally higher, and customers spent slightly more per basket.

**Business insight:** Sales performance is influenced by both the number of purchases and the amount spent per basket. A retailer can benefit from understanding both patterns rather than focusing on purchase counts alone.

### Q3. Which households show signs of declining purchase frequency or prolonged inactivity?

| Customer activity status | Households |  Share |
| ------------------------ | ---------: | -----: |
| Active — Increasing      |      1,075 | 43.00% |
| Active — Declining       |      1,065 | 42.60% |
| Active — Stable          |        186 |  7.44% |
| Inactive — 90+ Days      |        174 |  6.96% |

**Business insight:** **49.56% of households** either purchased less frequently or had not purchased in the latest 90 days. These households warrant further investigation, but a decline in purchasing does not necessarily mean a customer is leaving.

### Overall takeaway

Customer purchasing patterns vary substantially. While many households are increasing their activity, a similarly large group is purchasing less often, and some have stopped purchasing recently.

**What comes next:** Objective 2 will examine customer spending and value to help the retailer determine which households represent the most important retention and growth opportunities.

### Important interpretation notes

- A **qualifying basket** has at least one transaction line with `quantity > 0` and `sales_value > 0`.
- Purchase counts refer to **distinct baskets**, not confirmed physical store visits.
- The **3-day median** reflects all observed gaps between distinct purchasing days, not the median of each household's own gaps.
- Weekly trend comparisons exclude the partial **Weeks 1 and 102**.
- Activity status compares the two latest **90-day periods**; the inactivity threshold is an analytical assumption, not confirmed customer churn.
- These historical patterns do not establish what caused changes in purchasing or spending.

### Objective 1 visualizations

- [Weekly Purchasing Activity](../outputs/charts/01_obj1_weekly_purchasing_activity.png)
- [Weekly Customer Spending](../outputs/charts/01_obj2_weekly_customer_spending.png)
- [Customer Activity Status](../outputs/charts/01_obj3_customer_activity_status.png)

## Objective 2 — Identify Customer Value Drivers

### Q4. Customer Revenue Distribution

Total recorded sales across 2,500 households reached
8,057,462.65.

- Top 10% of households: 34.29% of sales.
- Top 20% of households: 53.05% of sales.
- Bottom 50% of households: approximately 15.66% of sales.
- Average household spending: 3,222.99.
- Median household spending: 2,157.75.

**Business Insight:** Sales are concentrated among
higher-spending households. Retaining their engagement
may be important for protecting future sales.

### Q5. Household Spending Drivers

Pearson correlations with total household spending:

- Shopping frequency: 0.703.
- Average basket value: 0.390.

**Business Insight:** Shopping frequency has a stronger
positive linear association with total spending than
average basket value. Encouraging repeat purchasing
could be explored as a growth opportunity.

These relationships do not demonstrate causation.

### Q6. Product Preferences and Diversity

Department share of each group's recorded sales:

| Department | High-Value | Lower-Value |
| ---------- | ---------: | ----------: |
| Grocery    |     49.01% |      52.84% |
| Drug GM    |     13.49% |      12.66% |
| Kiosk-Gas  |      8.30% |       5.01% |
| Produce    |      6.99% |       6.84% |
| Meat       |      6.48% |       7.19% |

Both groups concentrate spending in broadly similar
departments. Grocery is the largest department for each
group, while Kiosk-Gas represents a greater share of
High-Value household spending.

High-Value households purchased from an average of
16.14 departments (median 16), compared with 11.31
departments (median 11) for Lower-Value households.

**Business Insight:** Higher-spending households
purchase across a wider range of departments.
Broader category engagement among Lower-Value households
may offer opportunities for further investigation.

### Overall Objective 2 Conclusion

Revenue is concentrated among higher-spending households,
whose spending is more strongly associated with shopping
frequency and who purchase across more departments.

Potential opportunities include protecting engagement
among high-spending households, encouraging repeat
purchases, and exploring cross-category purchasing.

These are analytical opportunities, not demonstrated
effects of specific marketing interventions.

### Objective 1 visualizations

- ![Customer Revenue Distribution](outputs/charts/customer_revenue_by_decile.png)
- ![Department Spending Mix](outputs/charts/department_spending_mix.png)
- ![Category Diversity](outputs/charts/category_diversity_by_customer_group.png)
