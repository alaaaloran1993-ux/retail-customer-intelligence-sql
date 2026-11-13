-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 2: IDENTIFY CUSTOMER VALUE DRIVERS
-- =====================================================
-- BUSINESS QUESTION 4:
-- How is sales revenue distributed across households, and how much comes from the highest-spending 10%?
-- =====================================================
-- Query 2.1A: Overall Revenue & Top 10% Contribution
-- Purpose:
-- Measure overall household spending and determine how much revenue comes from the top 10% of spenders.
-- =====================================================
WITH household_spending AS (
    SELECT household_key,
        SUM(sales_value) AS total_spending
    FROM transaction_data
    WHERE basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        ) -- Include all sales lines from qualifying baskets.
    GROUP BY household_key
),
ranked_households AS (
    SELECT household_key,
        total_spending,
        NTILE(10) OVER (
            ORDER BY total_spending DESC,
                household_key
        ) AS spending_decile
    FROM household_spending
)
SELECT COUNT(*) AS total_households,
    ROUND(SUM(total_spending), 2) AS total_sales,
    ROUND(AVG(total_spending), 2) AS avg_household_spending,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_spending
        )::NUMERIC,
        2
    ) AS median_household_spending,
    ROUND(
        SUM(total_spending) FILTER (
            WHERE spending_decile = 1
        ),
        2
    ) AS top_10pct_sales,
    ROUND(
        100.0 * SUM(total_spending) FILTER (
            WHERE spending_decile = 1
        ) / NULLIF(SUM(total_spending), 0),
        2
    ) AS top_10pct_revenue_share
FROM ranked_households;
/*
 Findings - Overall Revenue & Top 10% Contribution:
 - Total recorded sales: 8,057,462.65 across 2,500 households.
 - Average household spending: 3,222.99; Median: 2,157.75.
 - The top 10% (250 households) generated 34.29% of sales.
 
 Business Insight:
 A relatively small group of households contributes
 a substantial share of sales. Maintaining their
 engagement could be important for the retailer.
 
 Note:
 Spending reflects historical recorded sales, not
 customer profitability or predicted future value.
 */
-- == == == == == == == == == == == == == == == == == == == == == == == == == == = 
-- Query 2.1B: Revenue Distribution by Household Decile
-- Purpose:
-- Compare the sales contribution of each 10% group of households, ranked from highest to lowest spending.
-- == == == == == == == == == == == == == == == == == == == == == == == == == == = 
WITH household_spending AS (
    SELECT household_key,
        SUM(sales_value) AS total_spending
    FROM transaction_data
    WHERE basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        ) -- Include recorded sales from qualifying baskets.
    GROUP BY household_key
),
spending_groups AS (
    SELECT household_key,
        total_spending,
        NTILE(10) OVER (
            ORDER BY total_spending DESC,
                household_key
        ) AS spending_decile
    FROM household_spending
)
SELECT spending_decile,
    COUNT(*) AS households,
    ROUND(SUM(total_spending), 2) AS group_sales,
    ROUND(AVG(total_spending), 2) AS avg_household_spending,
    ROUND(
        100.0 * SUM(total_spending) / NULLIF(SUM(SUM(total_spending)) OVER (), 0),
        2
    ) AS sales_share_pct
FROM spending_groups
GROUP BY spending_decile
ORDER BY spending_decile;
/*
 Findings - Revenue Distribution by Household Decile:
 - The top 10% of households generated 34.29% of sales.
 - The top 20% contributed 53.05% of total sales.
 - The bottom 50% contributed only 15.66%.
 
 Insight:
 Sales are concentrated among higher-spending households,
 with just 20% generating more than half of total sales.
 
 Note:
 Households are divided into 10 equally sized groups
 based on historical spending.
 */
/*
 FINAL SUMMARY - BUSINESS QUESTION 4
 Key Findings:
 - Total recorded sales reached 8.06 million.
 - The highest-spending 10% generated 34.29% of sales.
 - The top 20% contributed more than half of total sales (53.05%).
 
 Business Insight:
 A relatively small group of households contributes
 a large share of the retailer's sales. Keeping these
 customers engaged may help protect future revenue,
 while lower-spending households may offer opportunities
 for growth.
 
 Note:
 High spending does not necessarily mean high loyalty
 or profitability.
 */
--
--
/*
 Methodology Note:
 Pearson correlation is a statistical method used to measure
 the strength and direction of a linear relationship between
 two numerical variables.
 
 Values range from -1 to +1:
 - Near +1: Strong positive relationship.
 - Near  0: Weak or no linear relationship.
 - Near -1: Strong negative relationship.
 
 Correlation does not imply causation.
 */