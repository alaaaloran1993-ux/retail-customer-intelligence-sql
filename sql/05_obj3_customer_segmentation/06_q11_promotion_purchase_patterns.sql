-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- BUSINESS QUESTION 11: 
-- Are promotional engagement patterns associated with subsequent changes in purchasing frequency or spending?
-- =====================================================
-- Query 3.5: Purchasing Before and After Coupon Redemption
-- Purpose:
-- Compare purchase frequency and recorded spending during the 30 days before and after first coupon redemption.
-- =====================================================
WITH first_redemption AS (
    SELECT household_key,
        MIN(day) AS redemption_day
    FROM coupon_redempt
    GROUP BY household_key
    HAVING MIN(day) BETWEEN 31 AND 681
),
household_activity AS (
    SELECT r.household_key,
        COUNT(DISTINCT t.basket_id) FILTER (
            WHERE t.day BETWEEN r.redemption_day - 30 AND r.redemption_day - 1
        ) AS baskets_before,
        COUNT(DISTINCT t.basket_id) FILTER (
            WHERE t.day BETWEEN r.redemption_day + 1 AND r.redemption_day + 30
        ) AS baskets_after,
        COALESCE(
            SUM(t.sales_value) FILTER (
                WHERE t.day BETWEEN r.redemption_day - 30 AND r.redemption_day - 1
            ),
            0
        ) AS spending_before,
        COALESCE(
            SUM(t.sales_value) FILTER (
                WHERE t.day BETWEEN r.redemption_day + 1 AND r.redemption_day + 30
            ),
            0
        ) AS spending_after
    FROM first_redemption r
        LEFT JOIN transaction_data t ON r.household_key = t.household_key
        AND t.basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        )
    GROUP BY r.household_key
)
SELECT COUNT(*) AS households_with_complete_30day_windows,
,
    ROUND(AVG(baskets_before), 2) AS avg_baskets_before,
    ROUND(AVG(baskets_after), 2) AS avg_baskets_after,
    ROUND(AVG(baskets_after - baskets_before), 2) AS avg_basket_change,
    ROUND(AVG(spending_before), 2) AS avg_spending_before,
    ROUND(AVG(spending_after), 2) AS avg_spending_after,
    ROUND(AVG(spending_after - spending_before), 2) AS avg_spending_change
FROM household_activity;
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - BUSINESS QUESTION 11
 
 Key Findings: Business Question 11: Purchasing After Redemption
 - 432 households had complete 30-day observation windows
 before and after their first coupon redemption.
 - Average purchase baskets decreased slightly
 from 9.04 to 8.90 (change: -0.15).
 - Average household spending increased slightly
 from 297.31 to 305.34 (change: +8.04).
 
 Business Insight:
 Purchasing frequency remained relatively stable, while
 recorded spending increased modestly after redemption.
 Promotional engagement does not automatically correspond
 to a meaningful increase in purchasing.
 
 Methodology Note:
 The comparison uses equal 30-day periods and excludes
 the redemption day. These descriptive changes cannot
 be attributed to coupons without further analysis.
 */