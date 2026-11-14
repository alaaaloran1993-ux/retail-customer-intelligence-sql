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

## Objective 2 — Customer Value Analysis

### Spending Measurement

Household spending is calculated by summing all recorded
sales lines within qualifying purchase baskets, consistent
with Objective 1. Values represent recorded sales in the
dataset's units, not verified profit or net revenue.

### Customer Revenue Distribution (Q4)

Households are ranked by total historical spending and
divided into ten approximately equal groups using
`NTILE(10)`. This allows us to compare revenue contributions
across spending deciles without fixed spending thresholds.

### Spending Drivers (Q5)

Pearson correlation (`CORR`) measures the strength and
direction of the linear relationships between total
household spending and:

- Purchase frequency (qualifying baskets per household).
- Average recorded sales per qualifying basket.

Correlation is descriptive and does not establish causation.
Total spending is mathematically related to both measures.

### Customer Groups (Q6)

Based on Q4, households are classified as:

- High-Value: Top 20% by total historical spending
  (500 households).
- Lower-Value: Remaining 80% (2,000 households).

`NTILE(5)` is used to assign these groups dynamically.
These are analysis-defined classifications, not official
customer segments or the RFM segments planned for Objective 3.

### Department Preferences and Diversity

- Department spending shares are calculated separately
  within each customer group.
- Department diversity counts distinct departments with
  positive quantity and positive recorded sales per household.
- Blank department names are excluded from diversity.
- Fuel and miscellaneous transaction departments remain
  included unless otherwise specified.

Department diversity is measured across the observation
period and may partly reflect differences in shopping
frequency and opportunities to purchase.

_Future Objective 3 methods will be added here after those analyses are completed._

### Reusable SQL Logic

Some queries repeat calculations from earlier objectives,
including qualifying purchase baskets, household spending,
and customer rankings.

This is intentional to keep analytical definitions
consistent and allow each SQL query to run independently.

### RFM Segmentation Approach

Households are segmented using Recency, Frequency,
and Monetary scores ranging from 1 to 5.

Recency uses CUME_DIST() to preserve identical
inactivity values within the same scoring group.
Frequency and Monetary use NTILE(5) to assign
approximately equal-sized ranking groups.

Customer segments are defined using combinations
of RFM scores, following common retail RFM practices.
Actual inactivity days are retained for subsequent
validation and retention analysis.

RFM scores reflect relative purchasing behavior,
not confirmed customer loyalty or churn.

## Objective 3 — Retention and Growth Opportunities

### Repeated SQL definitions

Some stand-alone SQL queries repeat qualifying-basket, household-spending and RFM-segmentation logic. This is intentional: each business question remains independently executable while using consistent definitions. Repetition does not indicate additional transactions or households.

### RFM measurement and scoring (Q7)

The reference date is **dataset day 711**. Each household's metrics use the same qualifying basket rule established in Objective 1: a basket qualifies when **at least one** line has `quantity > 0 AND sales_value > 0`; all sales lines belonging to qualifying baskets contribute to monetary spending.

- **Recency (R):** `711 - MAX(day)` for qualifying purchases. Fewer days means a more recent purchase.
- **Frequency (F):** Distinct qualifying `basket_id` values per household over the observation period.
- **Monetary (M):** Total recorded `sales_value` from all lines of qualifying baskets; this is not verified profit or net revenue.

R is scored from **1 (least recent) to 5 (most recent)** using `CEIL(5 * CUME_DIST() OVER (ORDER BY recency_days DESC))`. Equal recency values get equal scores. F and M use `NTILE(5)` on ascending values, with `household_key` as a deterministic tie-breaker: approximately 500 households receive each F and M score. **`NTILE()` groups households according to ranking, without manually choosing spending thresholds.** F and M ties can be split at score boundaries; Recency group sizes can differ because tied days are preserved.

Observed R score ranges were: **R5 = 0–1 days (629 households)**; **R4 = 2–4 (460)**; **R3 = 5–9 (436)**; **R2 = 10–27 (487)**; **R1 = 28–657 (488)**. R scores describe relative position, not verified churn severity.

### RFM segments and business interpretation (Q7)

The following **ordered CASE rules** classify all 2,500 households exactly once using R, F and M **scores only**. They were refined after reviewing an initially large residual group; the final result has no unclassified households.

| Segment                       | RFM rule (in CASE order)    | Typical behavior                                | Potential business action           |
| ----------------------------- | --------------------------- | ----------------------------------------------- | ----------------------------------- |
| Champions                     | R ≥ 4, F ≥ 4, M ≥ 4         | Recent, frequent, high-spending                 | Reward and retain                   |
| Loyal Households              | R ≥ 3, F ≥ 4; not Champions | Repeat buyers with reasonably recent activity   | Maintain loyalty; cross-sell        |
| Potential Loyalists           | R ≥ 4, F ≤ 3                | Recently active, less frequent                  | Encourage repeat purchasing         |
| Regular / Moderate Engagement | R = 3, F ≤ 3                | Intermediate or occasional activity             | Explore engagement opportunities    |
| At-Risk Households            | R ≤ 2 and (F ≥ 3 or M ≥ 3)  | Less recent with some historical activity/value | Investigate potential disengagement |
| Hibernating Households        | R ≤ 2, F ≤ 2, M ≤ 2         | Less recent and historically low engagement     | Consider low-cost reactivation      |

These are **analytical segment labels**, not evidence that individual customers are loyal, lost, or at risk of churn. The conditions are checked in order, so prior matches take precedence. The segment definitions were adapted for this retail dataset rather than presented as a universal standard.

### Revenue contribution and inactivity (Q8)

Segment sales equal the sum of household M values; revenue shares use total recorded sales across all 2,500 households (**8,057,462.65**). Average spending is the mean of household spending within each segment. To validate the segment labels, inactivity is examined using actual `recency_days`, reported as average, median, and the count/share with **90 or more days** since last qualifying purchase. The 90-day threshold carries forward the **assumed inactivity indicator** from Objective 1; it is not confirmed churn.

### Growth opportunity screening (Q9)

The group-profile query compares Potential Loyalists and Regular / Moderate Engagement with Loyal Households as a reference. **Average basket value** is first calculated for each household (`total_spending / purchase_frequency`) and then averaged across households, giving each household equal weight.

A narrower **candidate shortlist** uses **R ≥ 3, F ≤ 3, M ≥ 3**, producing 328 households. The displayed 20 households are the highest-spending members of that shortlist; the complete qualifying population remains 328. This screen is not a forecast of marketing response or incremental sales.

### Promotional data validation and engagement (Q10; supporting)

Campaign-to-household assignments (`campaign_table`) and coupon redemptions (`coupon_redempt`) are analyzed alongside RFM segments. Campaign definitions and periods come from `campaign_desc`; coupon/product mappings are available in `coupon`. All **2,318** recorded redemptions matched the household's campaign assignment and occurred within the recorded campaign period. Campaign assignment **does not establish actual exposure, attention, or participation**.

Segment-level campaign-assignment and redemption measures use `EXISTS` to count **unique households**, avoiding multiplication caused by repeated campaign assignments or redemption events. Assignment rate is assigned households divided by all segment households. Redemption rate is coupon-redeeming households divided by campaign-assigned households in that segment; it is **not** the proportion of coupons redeemed or a measure of campaign effectiveness. RFM segments reflect the full observation window, not customer status at each campaign's start.

### Before/after coupon redemption (Q11; exploratory supporting)

For each household, the first recorded coupon-redemption day serves as the reference event. Households are included when the full **30 days before and 30 days after** fall within transaction days 1–711: first redemption day **31–681** inclusive. **432 of 434** redeeming households qualify. Redemption day is excluded, the before/after periods have equal duration, and zero-purchase windows remain in the averages. Purchase frequency counts qualifying baskets; spending includes all transaction lines in those baskets.

The before/after comparison has **no non-redeeming control group**, and does not control for seasonality, concurrent promotions, selection effects, or baseline purchasing patterns. It is **descriptive**, not a causal estimate of promotional impact. Some campaigns extend to day 719, beyond the transaction observation end; the 30-day redemption windows are specifically restricted to avoid incomplete follow-up.

### Scope and limitations

Questions **Q10–Q11 remain supporting analyses under Objective 3**. Q10 provides descriptive promotional engagement by segment; Q11 is retained as **exploratory before/after analysis**, not evidence of effectiveness. This is a methodology/scope-status clarification, not a change to the agreed questions in `docs/business_case.md`. All results describe historical observed behavior, and future purchases and campaign outcomes are not available.
