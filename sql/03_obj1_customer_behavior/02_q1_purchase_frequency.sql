-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 1: CUSTOMER PURCHASING BEHAVIOR
-- =====================================================
-- BUSINESS QUESTION 1:
-- How frequently do households shop, and how much time typically passes between shopping trips?
-- =====================================================
-- Query 1.1A: Household Purchase Frequency
-- Purpose:
-- Measure the number of qualifying purchase baskets per household during the observation period.
-- =====================================================
WITH household_frequency AS (
    SELECT household_key,
        COUNT(DISTINCT basket_id) AS purchase_frequency
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0 -- Apply the validated qualifying-purchase rule.
        -- A basket is counted once even if it contains
        -- multiple qualifying transaction lines.
    GROUP BY household_key
)
SELECT COUNT(*) AS purchasing_households,
    SUM(purchase_frequency) AS total_purchase_baskets,
    ROUND(AVG(purchase_frequency), 2) AS avg_purchase_frequency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY purchase_frequency
    ) AS median_purchase_frequency,
    MIN(purchase_frequency) AS min_purchase_frequency,
    MAX(purchase_frequency) AS max_purchase_frequency
FROM household_frequency;
/*
 Findings - Household Purchase Frequency:
 - 2,500 households made 275,539 qualifying purchases.
 - Average: 110 baskets; Median: 78 baskets per household.
 - Purchase frequency ranges from 1 to 1,298 baskets.
 
 Insight:
 The higher average compared to the median suggests
 that some households purchase much more frequently
 than others.
 
 Note:
 Frequency counts distinct qualifying baskets over
 711 days, not necessarily physical store visits.
 */
-- =====================================================
-- Query 1.1B: Time Between Purchases
-- Purpose:
-- Measure the number of days between consecutive purchasing days for each household.
-- =====================================================
WITH purchase_days AS (
    SELECT DISTINCT household_key,
        day
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0 -- Count qualifying purchasing days only.
        -- Multiple baskets on one day count as one day.
),
previous_purchases AS (
    SELECT household_key,
        day,
        LAG(day) OVER (
            PARTITION BY household_key
            ORDER BY day
        ) AS previous_purchase_day
    FROM purchase_days
),
days_between_purchases AS (
    SELECT household_key,
        day - previous_purchase_day AS days_between
    FROM previous_purchases
    WHERE previous_purchase_day IS NOT NULL -- Exclude the first purchasing day because
        -- no previous purchase is available.
)
SELECT COUNT(DISTINCT household_key) AS households_with_repeat_days,
    COUNT(*) AS total_purchase_gaps,
    ROUND(AVG(days_between), 2) AS avg_days_between_purchases,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY days_between
    ) AS median_days_between_purchases,
    MIN(days_between) AS min_days_between_purchases,
    MAX(days_between) AS max_days_between_purchases
FROM days_between_purchases;
/*
 Findings - Time Between Purchases:
 - 2,497 households purchased on multiple days.
 - Average time between purchases: 6.95 days.
 - Median time between purchases: 3 days.
 - Observed gaps range from 1 to 666 days.
 
 Insight:
 Customers often return within a few days,
 although some purchase gaps are much longer.
 
 Note:
 Calculated between distinct purchasing days.
 Three households purchased on only one observed day.
 */
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - BUSINESS QUESTION 1
 - 2,500 households recorded 275,539 qualifying baskets.
 - Median purchase frequency: 78 baskets per household
 over the 711-day observation period.
 - Median time between purchasing days: 3 days.
 - Purchasing frequency and timing vary considerably
 across households.
 
 Business Insight:
 Customer shopping behavior is not uniform,
 highlighting opportunities for more targeted
 customer engagement strategies.
 
 Note:
 The 3-day median is calculated across all observed
 purchase gaps, not individual household medians.
 */