# Analytical Methodology

**Project:** Retail Customer Intelligence  
**Status:** Objective 1 methodology finalized; additional objectives will be documented as completed.

## 1. Data and Observation Period

Analysis uses the _dunnhumby – The Complete Journey_ dataset, sourced via Kaggle. Transactions cover 711 consecutive relative days (Days 1–711), organized into 102 dataset weeks. Day numbers are not converted into calendar dates.

## 2. Qualifying Purchase Baskets

A basket qualifies as a purchase when **at least one** of its transaction lines meets both conditions:

```sql
quantity > 0 AND sales_value > 0
```

- **275,539** unique baskets qualify; **945** do not.
- Each qualifying `basket_id` is counted once, regardless of its number of product lines.
- Non-qualifying baskets are excluded from **purchase-based activity metrics**, not automatically from every monetary calculation.
- Original transaction records remain unchanged.

## 3. Objective 1 — Customer Purchasing Behavior

### Q1. Purchase Frequency and Time Between Purchases

- **Purchase frequency:** Number of distinct qualifying baskets per household over the 711-day observation period.
- **Time between purchases:** Number of days between consecutive **distinct purchasing days** for each household, calculated using `LAG()`.
- Multiple qualifying baskets on the same day count as **one purchasing day** for time-gap calculations, but as separate baskets for purchase frequency.
- The first observed purchasing day has no preceding purchase day, so it contributes no time gap. Households with only one purchasing day do not contribute to the time-between-purchases summary.
- The reported median gap is calculated across **all observed gaps**, not from the median of household-level averages.

### Q2. Weekly Purchasing and Spending Trends

- Weekly purchasing activity counts distinct qualifying baskets and distinct households purchasing in each week.
- **Average weekly baskets per active household** = qualifying baskets / households making at least one qualifying purchase that week.
- **Weekly recorded sales** = sum of `sales_value` across **all transaction lines belonging to qualifying baskets**, including lines that do not independently meet the qualifying-line condition.
- **Average weekly spending per active household** = weekly recorded sales / active purchasing households.
- **Average basket value** = weekly recorded sales / qualifying baskets.
- **Weeks 1 and 102** have only five and six observed purchasing days, respectively. They are excluded from comparisons of full seven-day weeks; their original records remain in the dataset.
- Recorded sales are not labeled as verified net revenue, since the precise treatment of discounts has not been independently established.

### Q3. Declining Purchasing Activity and Inactivity

Household basket counts are compared over two equal, non-overlapping periods:

| Period           | Relative days |
| ---------------- | ------------- |
| Previous 90 days | 532–621       |
| Recent 90 days   | 622–711       |

Households receive **one** status, in the following priority order:

| Status              | Classification rule                                                                 |
| ------------------- | ----------------------------------------------------------------------------------- |
| Inactive – 90+ Days | No qualifying purchase in the most recent 90 days (`711 - last_purchase_day >= 90`) |
| Active – Declining  | Recent-period qualifying basket count is lower than the previous period             |
| Active – Increasing | Recent-period qualifying basket count is higher than the previous period            |
| Active – Stable     | Counts are equal in both periods                                                    |

The **90-day inactivity threshold is an analytical assumption**, not a verified definition of churn. A small increase or decrease in purchases is sufficient to change a household's active status; these labels are screening indicators, not proof of customer loss or satisfaction.

## 4. Interpretation and Limitations

- Basket counts do not independently establish distinct physical store visits.
- Time-between-purchases results may be influenced more heavily by households with many observed purchasing days.
- The dataset does not establish why customer behavior or spending changed. Observed associations should not be presented as causal effects.
- Customer activity is observed only within the available dataset period; purchases outside that period are unknown.
- Demographic information covers only **801 of 2,500** purchasing households and is not used to generalize Objective 1 findings to the full customer base.

## 5. Scope and Change Control

The business objectives and questions are governed by `docs/business_case.md` and remain the agreed scope baseline. Methodological details can be refined with documented justification; **material changes to scope must be recorded separately**, rather than silently rewriting the business case. Findings and business recommendations are maintained in `docs/final_insights.md`.

_Future Objective 2 and Objective 3 methods will be added here after those analyses are completed._
