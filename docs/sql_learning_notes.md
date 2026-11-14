# SQL Learning Notes

Practical SQL techniques applied in the Retail Customer
Intelligence project.

| SQL technique        | Purpose                                                | Project application                       |
| -------------------- | ------------------------------------------------------ | ----------------------------------------- |
| `CTE (WITH)`         | Break complex queries into understandable steps        | Household and basket analysis             |
| `LAG()`              | Compare a row with the previous row                    | Days between shopping trips               |
| `FILTER (WHERE ...)` | Apply conditions to individual aggregate calculations  | Purchase counts and customer status       |
| `PERCENTILE_CONT()`  | Calculate percentiles, including the median            | Shopping frequency and household spending |
| `NTILE()`            | Divide ranked records into approximately equal groups  | Revenue deciles and customer value groups |
| `ROW_NUMBER()`       | Assign sequential row numbers                          | Household spending rankings               |
| `CORR()`             | Measure linear correlation between numerical variables | Spending frequency versus basket value    |

## Key Learning: NTILE()

`NTILE(n)` is a SQL window function that divides ordered
records into approximately equal-sized groups.

It helps us segment customers based on their ranking,
without manually setting spending thresholds.

Examples:

- `NTILE(10)`: Spending deciles (10% groups).
- `NTILE(5)`: Spending quintiles (20% groups).

NTILE is a SQL ranking and segmentation function,
not a statistical hypothesis test.

## Key Learning: CORR()

`CORR()` calculates the Pearson correlation coefficient.

- Near +1: Strong positive linear relationship.
- Near 0: Weak or no linear relationship.
- Near -1: Strong negative linear relationship.

A correlation does not prove that one variable causes
changes in another.

### EXISTS — Checking Whether a Matching Record Exists

`EXISTS` checks whether a subquery returns at least one row.

- Returns TRUE if a matching record exists.
- Returns FALSE if no matching record exists.
- `SELECT 1` is a convention; the actual value is irrelevant.

**Project example:** Check whether each household was
assigned to a campaign or redeemed a coupon.

**Why use it?** Unlike a regular JOIN, EXISTS does not
duplicate the original household rows when multiple
matching records are found.

## Objective 3 — Useful SQL techniques

| Technique                     | What it does                                                           | How we used it                                                                     |
| ----------------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `CUME_DIST()`                 | Cumulative relative position; identical values receive the same result | Recency scoring without splitting households with the same last-purchase day       |
| `NTILE(5)`                    | Divides ordered rows into five approximately equal ranking groups      | Frequency and Monetary scores, without manually choosing spending thresholds       |
| `CASE WHEN`                   | Applies ordered classification rules; first matching rule wins         | Six RFM customer segments                                                          |
| `COUNT(*) FILTER (WHERE ...)` | Counts rows meeting a condition without losing other rows              | 90+ day inactivity and segment-level campaign statistics                           |
| `EXISTS (SELECT 1 ...)`       | Tests whether at least one matching record exists                      | Household-level campaign assignment and coupon redemption, avoiding duplicate rows |
| `COUNT(*) OVER ()`            | Returns the total row count alongside each row                         | Shows 328 qualifying growth candidates even when displaying only 20                |
| `MIN(day)` and `HAVING`       | Finds the first redemption and restricts the eligible analysis cohort  | Choosing households with complete 30-day pre/post windows                          |
| `COALESCE()`                  | Replaces `NULL` with a fallback value                                  | Includes zero-spending before/after windows correctly                              |

**`NTILE()` example:** With 2,500 households sorted by spending ascending, `NTILE(5)` assigns scores 1–5 in groups of 500: the lowest 500 get 1, the next 500 get 2, and the highest 500 get 5. The scores represent **relative positions**, not equal amounts of spending. Ties may be split between groups.

**`CUME_DIST()` distinction:** Unlike `NTILE`, all households with the same Recency value receive the same cumulative proportion and therefore the same R score when applying `CEIL(5 * CUME_DIST())`. Group sizes can vary.

**`EXISTS` takeaway:** Use it for _“Did this household do something at least once?”_ rather than _“How many times did it do so?”_ `SELECT 1` does not count events; it only tests for a matching row.

**Learning caution:** Correlations, RFM labels, and coupon before/after differences describe historical patterns, not causal effects.
