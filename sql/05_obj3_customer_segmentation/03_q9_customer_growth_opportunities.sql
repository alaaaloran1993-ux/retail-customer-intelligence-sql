-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- BUSINESS QUESTION 9: 
-- Which occasional or moderate-value households show potential for increased engagement?
-- =====================================================
-- Query 3.3A: Growth Opportunity Profiles
-- Purpose:
-- Compare purchase frequency, spending, and basket value among households with potential for greater engagement.
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
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    ROUND(AVG(purchase_frequency), 2) AS avg_purchase_frequency,
    ROUND(AVG(total_spending), 2) AS avg_household_spending,
    ROUND(
        AVG(total_spending / NULLIF(purchase_frequency, 0)),
        2
    ) AS avg_basket_value
FROM customer_segments
WHERE customer_segment IN (
        'Potential Loyalists',
        'Regular / Moderate Engagement',
        'Loyal Households'
    )
GROUP BY customer_segment
ORDER BY avg_household_spending DESC;
/*
 Findings - Growth Opportunity Profiles:
 
 - Loyal Households average 160.04 purchase baskets,
 compared with 57.88 for Potential Loyalists and
 55.90 for Regular / Moderate households.
 - Both growth-candidate groups have higher average
 basket values (33.65 and 35.05) than Loyal (25.30).
 - Potential Loyalists show very recent activity,
 with an average recency of 1.68 days.
 
 Business Insight:
 Potential Loyalists and Regular / Moderate households
 already demonstrate meaningful spending per basket.
 Encouraging repeat purchasing may offer greater growth
 opportunities than focusing only on basket size.
 
 Methodology Note:
 Average basket value is calculated per household,
 then averaged across the segment. Differences are
 descriptive and do not demonstrate growth potential
 or predict responses to marketing initiatives.
 */
-- =====================================================
-- Query 3.3B: Growth Opportunity Candidates
-- Purpose:
-- Identify households with meaningful spending and opportunities to increase purchase frequency.
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
)
SELECT household_key,
    CASE
        WHEN r_score >= 4 THEN 'Potential Loyalists'
        ELSE 'Regular / Moderate Engagement'
    END AS customer_segment,
    recency_days,
    purchase_frequency,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(
        total_spending / NULLIF(purchase_frequency, 0),
        2
    ) AS avg_basket_value,
    r_score,
    f_score,
    m_score,
    COUNT(*) OVER () AS total_eligible_households
FROM rfm_scores
WHERE r_score >= 3
    AND f_score <= 3
    AND m_score >= 3
ORDER BY m_score DESC,
    total_spending DESC
LIMIT 20;
/*
 Findings - Growth Opportunity Candidates:
 - 328 households (13.12% of all households-2500) meet
 the selected RFM-based growth criteria.
 - The shortlist includes recently active households
 with moderate or high spending but lower frequency.
 - Several top candidates show substantial basket values,
 suggesting that basket size is not their main limitation.
 
 Business Insight:
 These households may be suitable for targeted initiatives
 aimed at encouraging more frequent purchasing.
 
 Methodology Note:
 Candidates are selected using R >= 3, F <= 3, M >= 3.
 Only the 20 highest-spending candidates are displayed.
 The criteria identify opportunities for investigation,
 not predicted responses to marketing.
 */
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - BUSINESS QUESTION 9
 
 Key Findings:
 - Potential Loyalists and Regular / Moderate households
 represent 680 households (27.20% of customers).
 - Both groups shop less frequently than Loyal Households,
 but have higher average basket values.
 - 328 households (13.12% of all customers) meet our
 RFM-based growth opportunity criteria.
 
 Business Insight:
 Encouraging repeat purchases may offer opportunities
 to increase engagement among these households,
 particularly those already demonstrating strong
 spending per basket.
 
 Methodology Note:
 Growth candidates were identified using R >= 3,
 F <= 3, and M >= 3. These are analytical screening
 criteria, not predictions of future purchasing behavior.
 */