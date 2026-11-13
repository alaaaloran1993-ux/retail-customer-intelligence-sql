-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 2: IDENTIFY CUSTOMER VALUE DRIVERS
-- =====================================================
-- BUSINESS QUESTION 5:
-- Is higher household spending associated more strongly with shopping frequency, basket value, or both?
-- =====================================================
-- Query 2.2: Customer Spending Drivers
-- Purpose:
-- Examine whether higher household spending is more strongly associated with purchase frequency, average basket value, or both.
-- =====================================================
WITH basket_spending AS (
    SELECT household_key,
        basket_id,
        SUM(sales_value) AS basket_value
    FROM transaction_data
    WHERE basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        ) -- Include all sales lines from qualifying baskets.
    GROUP BY household_key,
        basket_id
),
household_metrics AS (
    SELECT household_key,
        COUNT(*) AS purchase_frequency,
        SUM(basket_value) AS total_spending,
        AVG(basket_value) AS avg_basket_value
    FROM basket_spending
    GROUP BY household_key
)
SELECT COUNT(*) AS total_households,
    ROUND(
        CORR(total_spending, purchase_frequency)::NUMERIC,
        3
    ) AS frequency_correlation,
    ROUND(
        CORR(total_spending, avg_basket_value)::NUMERIC,
        3
    ) AS basket_value_correlation
FROM household_metrics;
/*
 Findings - Customer Spending Drivers:
 - Shopping frequency has a strong positive correlation
 with household spending (0.703).
 - Average basket value shows a weaker positive
 correlation with spending (0.390).
 
 Business Insight:
 Higher-spending households tend to shop more frequently,
 suggesting that encouraging repeat purchases could be
 an important opportunity for the retailer.
 
 Note:
 Correlation does not establish causation. Total spending
 depends on both purchase frequency and basket value.
 */