-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- BUSINESS QUESTION 8: 
-- Which segments contribute the most revenue, and which show warning signs of disengagement?
-- =====================================================
-- Query 3.2A: Revenue Contribution by RFM Segment
-- Purpose:
-- Measure the sales contribution and average household spending of each RFM customer segment.
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
    ) AS household_share_pct,
    ROUND(SUM(total_spending), 2) AS segment_sales,
    ROUND(AVG(total_spending), 2) AS avg_household_spending,
    ROUND(
        100.0 * SUM(total_spending) / NULLIF(SUM(SUM(total_spending)) OVER (), 0),
        2
    ) AS share_of_total_sales_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_sales DESC;
/*
 Findings - Revenue Contribution by RFM Segment:
 
 - Champions represent 21.56% of households but
 generate 48.05% of total recorded sales.
 - Champions and Loyal Households together contribute
 62.76% of sales.
 - At-Risk Households generate 16.26%, making them
 the second-largest revenue segment.
 - Hibernating Households represent 21.96% of customers
 but contribute only 4.30% of sales.
 - Total segment sales reconcile to 8,057,462.65 (Q4).
 
 Business Insight:
 Revenue is concentrated among Champions and Loyal
 Households, making their continued engagement important.
 At-Risk Households also represent substantial historical
 sales, suggesting potential retention priorities.
 
 Note:
 Revenue contribution reflects historical spending.
 Actual inactivity patterns will be examined in Query 3.2B
 before confirming disengagement concerns.
 */
-- =====================================================
-- Query 3.2B: Inactivity Patterns by RFM Segment
-- Purpose:
-- Compare actual inactivity periods across RFM segments and identify households with prolonged inactivity.
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
    ROUND(AVG(recency_days), 2) AS avg_inactivity_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY recency_days
    ) AS median_inactivity_days,
    COUNT(*) FILTER (
        WHERE recency_days >= 90
    ) AS inactive_90plus_households,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE recency_days >= 90
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS inactive_90plus_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY avg_inactivity_days DESC;
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - BUSINESS QUESTION 8
 
 Key Findings: Inactivity Patterns by RFM Segment:
 - Hibernating households show the longest inactivity:
 median 41 days; 24.77% inactive for 90+ days.
 - At-Risk households have a median inactivity of 20 days;
 only 8.92% have been inactive for 90+ days.
 - Champions, Loyal, and other active segments have
 no households inactive for 90+ days.
 - All 174 households inactive for 90+ days belong to
 Hibernating (136) or At-Risk (38) segments,
 matching the findings from Objective 1.
 
 Business Insight:
 Hibernating households show stronger inactivity signals,
 while At-Risk households represent historical customer
 value that may warrant further retention investigation.
 
 Methodology Note:
 The 90-day threshold is an analytical assumption,
 not confirmed customer churn. RFM segment labels
 reflect relative purchasing behavior.
 */