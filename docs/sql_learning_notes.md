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
