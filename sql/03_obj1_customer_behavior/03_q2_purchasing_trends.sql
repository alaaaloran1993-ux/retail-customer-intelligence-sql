-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 1: CUSTOMER PURCHASING BEHAVIOR
-- =====================================================
-- BUSINESS QUESTION 2:
-- How do purchasing frequency and spending patterns hange over the observation period?
-- =====================================================
-- Query 1.2A: Purchasing Frequency Over Time
-- Purpose:
-- Examine weekly purchasing activity across the retailer's 102-week observation period.
-- =====================================================
WITH weekly_purchases AS (
    SELECT week_no,
        MIN(day) AS first_day,
        MAX(day) AS last_day,
        COUNT(DISTINCT day) AS observed_purchase_days,
        COUNT(DISTINCT basket_id) AS purchase_baskets,
        COUNT(DISTINCT household_key) AS purchasing_households
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0
    GROUP BY week_no
)
SELECT week_no,
    first_day,
    last_day,
    observed_purchase_days,
    purchasing_households,
    purchase_baskets,
    ROUND(
        purchase_baskets::NUMERIC / NULLIF(purchasing_households, 0),
        2
    ) AS avg_weekly_baskets_per_active_household
FROM weekly_purchases
WHERE observed_purchase_days = 7 --weekly comparisons only include weeks with seven observed purchasing days
ORDER BY week_no;
/*
 Findings - Weekly Purchasing Frequency:
 
 - Weeks 1 and 102 are partial and excluded.
 - Purchasing activity increased sharply during the
 first 17 weeks, then largely stabilized.
 - Weeks 17–92 averaged approximately 2,972 baskets
 and 1,324 active households per week.
 
 Insight:
 Early growth was accompanied by an increase in active
 households. Later, purchasing activity remained relatively
 stable at around 2.25 baskets per active household weekly.
 
 Note:
 Only complete weeks are compared. The weekly average
 includes households that purchased during that week,
 not all 2,500 households.
 */
-- =====================================================
-- Query 1.2B: Customer Spending Over Time
-- Purpose:
-- Examine weekly sales and average spending per active household across the observation period.
-- =====================================================
WITH qualifying_baskets AS (
    SELECT DISTINCT basket_id
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0
),
weekly_spending AS (
    SELECT t.week_no,
        COUNT(DISTINCT t.day) AS observed_days,
        COUNT(DISTINCT t.household_key) AS active_households,
        COUNT(DISTINCT t.basket_id) AS purchase_baskets,
        SUM(t.sales_value) AS weekly_sales
    FROM transaction_data AS t
        JOIN qualifying_baskets AS qb ON t.basket_id = qb.basket_id -- Include all transaction lines from qualifying baskets when calculating recorded sales.
    GROUP BY t.week_no
)
SELECT week_no,
    ROUND(weekly_sales, 2) AS weekly_sales,
    active_households,
    purchase_baskets,
    ROUND(
        weekly_sales / NULLIF(active_households, 0),
        2
    ) AS avg_weekly_spending_per_active_household,
    ROUND(
        weekly_sales / NULLIF(purchase_baskets, 0),
        2
    ) AS avg_basket_value
FROM weekly_spending
WHERE observed_days = 7 -- Exclude partial weeks for fair comparisons.
ORDER BY week_no;
/*
 Findings - Customer Spending Over Time:
 
 - Weekly sales increased sharply during the early weeks.
 - Average weekly sales increased from approximately
 $83,690 (Weeks 17–52) to $88,804 (Weeks 53–92).
 - Average basket value increased from $28.53 to $29.53.
 - Week 92 recorded the highest sales at $113,193.
 
 Insight:
 Spending increased moderately after purchasing activity
 stabilized, suggesting that basket value also contributed
 to sales growth.
 
 Note:
 Only complete weeks are compared. Sales are based on
 recorded sales_value from qualifying baskets.
 */
/*
 FINAL SUMMARY - BUSINESS QUESTION 2
 
 Key Findings:
 - Customer purchasing activity grew rapidly during
 the first 17 weeks, then became relatively stable.
 - Weekly sales continued to fluctuate but were
 generally higher in the later period.
 - Customers also spent slightly more per basket
 in the later period.
 
 Business Insight:
 The retailer's sales improved even when customers
 were not shopping much more frequently. This suggests
 that how much customers spend during each purchase
 is just as important as how often they shop.
 
 Note:
 We cannot yet determine why customers spent more.
 */