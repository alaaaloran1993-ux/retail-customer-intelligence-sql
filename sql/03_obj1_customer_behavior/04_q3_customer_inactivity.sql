-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 1: CUSTOMER PURCHASING BEHAVIOR
-- =====================================================
-- BUSINESS QUESTION 3:
-- Which households show signs of declining purchase frequency or prolonged inactivity?
-- =====================================================
-- Query 1.3: Declining Purchasing Activity & Inactivity
-- Purpose: Identify households with reduced purchasing
-- frequency or prolonged periods without purchases.
-- =====================================================
WITH household_activity AS (
    SELECT household_key,
        MAX(day) AS last_purchase_day,
        COUNT(DISTINCT basket_id) FILTER (
            WHERE day BETWEEN 532 AND 621
        ) AS previous_90d_purchases,
        COUNT(DISTINCT basket_id) FILTER (
            WHERE day BETWEEN 622 AND 711
        ) AS recent_90d_purchases
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0 -- Only qualifying purchase baskets are counted.
    GROUP BY household_key
),
customer_status AS (
    SELECT household_key,
        previous_90d_purchases,
        recent_90d_purchases,
        711 - last_purchase_day AS days_since_last_purchase,
        -- 90 days is an assumed inactivity threshold, not a confirmed definition of customer churn.
        CASE
            WHEN 711 - last_purchase_day >= 90 THEN 'Inactive - 90+ Days'
            WHEN previous_90d_purchases > recent_90d_purchases THEN 'Active - Declining'
            WHEN previous_90d_purchases < recent_90d_purchases THEN 'Active - Increasing'
            ELSE 'Active - Stable'
        END AS customer_status
    FROM household_activity
)
SELECT customer_status,
    COUNT(*) AS households,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS household_pct
FROM customer_status
GROUP BY customer_status
ORDER BY households DESC;
/*
 Findings - Customer Purchasing Activity:
 
 - 43.00% of households increased their purchases.
 - 42.60% purchased less frequently.
 - 7.44% maintained the same purchase frequency.
 - 6.96% made no purchases in the last 90 days.
 
 Business Insight:
 Nearly half of households (49.56%) showed declining
 or inactive purchasing behavior. The retailer could
 prioritize these households for further investigation
 to identify potential customer retention opportunities.
 
 Note:
 Purchasing frequency compares two 90-day periods.
 Inactivity is defined using an assumed 90-day threshold.
 A decline does not necessarily indicate customer churn.
 */
-- =====================================================
-- OPTIONAL: View Individual Household Classifications
--
-- Run this query to see each household's purchase
-- activity, days since last purchase, and assigned
-- customer status (Inactive, Declining, Increasing,
-- or Stable).
-- =====================================================
WITH household_activity AS (
    SELECT household_key,
        MAX(day) AS last_purchase_day,
        COUNT(DISTINCT basket_id) FILTER (
            WHERE day BETWEEN 532 AND 621
        ) AS previous_90d_purchases,
        COUNT(DISTINCT basket_id) FILTER (
            WHERE day BETWEEN 622 AND 711
        ) AS recent_90d_purchases
    FROM transaction_data
    WHERE quantity > 0
        AND sales_value > 0
    GROUP BY household_key
)
SELECT household_key,
    previous_90d_purchases,
    recent_90d_purchases,
    711 - last_purchase_day AS days_since_last_purchase,
    CASE
        WHEN 711 - last_purchase_day >= 90 THEN 'Inactive - 90+ Days'
        WHEN previous_90d_purchases > recent_90d_purchases THEN 'Active - Declining'
        WHEN previous_90d_purchases < recent_90d_purchases THEN 'Active - Increasing'
        ELSE 'Active - Stable'
    END AS customer_status
FROM household_activity
ORDER BY customer_status,
    household_key;