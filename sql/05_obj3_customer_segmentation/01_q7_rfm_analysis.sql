-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- BUSINESS QUESTION 7: 
-- How can households be segmented using Recency, Frequency, and Monetary (RFM) analysis?
-- =====================================================
-- Query 3.1A: Household RFM Metrics
-- Purpose:
-- Calculate recency, purchase frequency, and total recorded spending for each household.
-- =====================================================
SELECT household_key,
    711 - MAX(day) AS recency_days,
    COUNT(DISTINCT basket_id) AS purchase_frequency,
    ROUND(SUM(sales_value), 2) AS total_spending
FROM transaction_data
WHERE basket_id IN (
        SELECT basket_id
        FROM transaction_data
        WHERE quantity > 0
            AND sales_value > 0
    ) -- Include all sales lines from qualifying baskets
GROUP BY household_key
ORDER BY total_spending DESC
LIMIT 10;
/*
 Findings - Household RFM Metrics:
 - The 10 highest-spending households recorded total
 spending between 18,894.72 and 38,319.79.
 - Their purchase frequency ranged from 321 to 970 baskets.
 - All 10 made purchases within the final 7 days
 of the observation period.
 
 Business Insight:
 The highest-spending households show substantial
 purchasing activity and recent engagement. However,
 their shopping frequency and total spending differ,
 highlighting the value of analyzing all three RFM measures.
 
 Methodology Notes:
 - Recency: Days since the last qualifying purchase.
 Lower values indicate more recent activity.
 - Frequency: Number of qualifying purchase baskets.
 - Monetary: Total recorded sales from qualifying baskets.
 - Day 711 is the end of the observation period.
 - Results show only the 10 highest-spending households.
 */
-- =====================================================
-- Query 3.1B: RFM Scoring
-- Purpose:
-- Assign households scores from 1 to 5 based on recency, purchase frequency, and total spending.
-- Refer to "Optional-Extra Query" for a check on Recency distribution end of this document.
-- =====================================================
WITH household_rfm AS (
    SELECT household_key,
        711 - MAX(day) AS recency_days,
        COUNT(DISTINCT basket_id) AS purchase_frequency,
        ROUND(SUM(sales_value), 2) AS total_spending
    FROM transaction_data
    WHERE basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        )
    GROUP BY household_key
)
SELECT household_key,
    recency_days,
    purchase_frequency,
    total_spending,
    -- Lower recency = higher score; tied values stay together.
    CEIL(
        5 * CUME_DIST() OVER (
            ORDER BY recency_days DESC
        )
    ) AS r_score,
    -- Higher frequency = higher score.
    NTILE(5) OVER (
        ORDER BY purchase_frequency ASC,
            household_key
    ) AS f_score,
    -- Higher spending = higher score.
    NTILE(5) OVER (
        ORDER BY total_spending ASC,
            household_key
    ) AS m_score
FROM household_rfm
ORDER BY total_spending DESC
LIMIT 10;
/*
 Findings - RFM Scoring:
 
 - All 10 highest-spending households received F=5 and M=5.
 - Seven received R=5, while three had lower Recency scores.
 - Household 2459 scored R=3, F=5, M=5, showing that
 high spending and frequency do not always coincide
 with the highest Recency score.
 
 Business Insight:
 RFM scoring highlights differences in customer behavior
 that total spending alone may not reveal.
 
 Note:
 Scores are relative to the 2,500 households analyzed.
 Results display only the 10 highest-spending households.
 
 Scoring Method:
 - R: CUME_DIST() keeps identical recency values together.
 - F & M: NTILE(5) divides households into five groups
 based on their ranking.
 
 For 2,500 households, NTILE(5) assigns:
 Lowest 500 households  = Score 1
 Next 500 households    = Score 2
 Middle 500 households  = Score 3
 Next 500 households    = Score 4
 Highest 500 households = Score 5
 
 Scores reflect relative rankings, not fixed thresholds.
 */
-- =====================================================
-- Query 3.1C: RFM Customer Segmentation
-- Purpose:
-- Classify households into meaningful RFM segments to support customer retention and growth decisions.
-- =====================================================
WITH household_rfm AS (
    SELECT household_key,
        711 - MAX(day) AS recency_days,
        COUNT(DISTINCT basket_id) AS purchase_frequency,
        SUM(sales_value) AS total_spending
    FROM transaction_data
    WHERE basket_id IN (
            SELECT basket_id
            FROM transaction_data
            WHERE quantity > 0
                AND sales_value > 0
        )
    GROUP BY household_key
),
rfm_scores AS (
    SELECT *,
        CEIL(
            5 * CUME_DIST() OVER (
                ORDER BY recency_days DESC
            )
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY purchase_frequency,
                household_key
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY total_spending,
                household_key
        ) AS m_score
    FROM household_rfm
),
customer_segments AS (
    SELECT *,
        CASE
            WHEN r_score >= 4
            AND f_score >= 4
            AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3
            AND f_score >= 4 THEN 'Loyal Households'
            WHEN r_score >= 4
            AND f_score <= 3 THEN 'Potential Loyalists'
            WHEN r_score = 3
            AND f_score <= 3 THEN 'Regular / Moderate Engagement'
            WHEN r_score <= 2
            AND (
                f_score >= 3
                OR m_score >= 3
            ) THEN 'At-Risk Households'
            WHEN r_score <= 2
            AND f_score <= 2
            AND m_score <= 2 THEN 'Hibernating Households'
            ELSE 'Other / Mixed Behavior'
        END AS customer_segment
    FROM rfm_scores
)
SELECT customer_segment,
    COUNT(*) AS households,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS household_share_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY households DESC;
/*
 Findings - RFM Customer Segmentation:
 - All 2,500 households were classified into six segments.
 - Hibernating Households (21.96%) and Champions (21.56%)
 are the largest segments.
 - At-Risk Households represent 17.04% of customers.
 - Potential Loyalists account for 16.56%, indicating
 a group worth examining for engagement opportunities.
 
 Business Insight:
 RFM segmentation identifies distinct purchasing patterns
 that can support targeted retention and growth strategies.
 
 Methodology Note:
 Segments are based exclusively on RFM scores.
 At-Risk and Hibernating are provisional behavioral labels,
 not confirmed evidence of customer disengagement.
 We will test their actual inactivity patterns in Q8.
 */
/*
 FINAL SUMMARY - BUSINESS QUESTION 7
 Key Findings:
 - All 2,500 households were classified into six RFM segments.
 - Champions (21.56%) and Loyal Households (12.24%)
 together represent 33.80% of customers.
 - At-Risk (17.04%) and Hibernating (21.96%) households
 together account for 39.00% of customers.
 - Potential Loyalists represent 16.56% of households.
 
 Business Insight:
 RFM segmentation reveals different purchasing patterns,
 helping the retailer identify households for loyalty,
 retention, and growth initiatives.
 
 Note:
 Segments are based exclusively on relative RFM scores,
 not confirmed loyalty or churn. We will test their
 actual inactivity patterns and revenue contribution in Q8.
 */
--
--
-- =====================================================
-- Optional-Extra Query 1: Recency Distribution Check
-- Purpose:
-- Check how many households share the same Recency value.
-- =====================================================
SELECT 711 - last_purchase_day AS recency_days,
    COUNT(*) AS households
FROM (
        SELECT household_key,
            MAX(day) AS last_purchase_day
        FROM transaction_data
        WHERE quantity > 0
            AND sales_value > 0
        GROUP BY household_key
    ) AS household_activity
GROUP BY recency_days
ORDER BY households DESC
LIMIT 10;
/*
 Findings - Recency Distribution Check:
 - 367 households purchased on the final observation day.
 - Another 262 households made their last purchase 1 day earlier.
 - In total, 629 households share recency values of 0 or 1.
 
 Scoring Decision:
 NTILE(5) could assign different scores to households
 with identical recency. CUME_DIST() will be used instead
 to ensure identical recency values receive the same score.
 */