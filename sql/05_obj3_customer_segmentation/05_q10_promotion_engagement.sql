-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- BUSINESS QUESTION 10: 
-- How do coupon redemption and campaign participation differ across customer segments?
-- =====================================================
-- Query 3.4: Promotional Engagement by RFM Segment
-- Purpose:
-- Compare campaign assignments and coupon redemptions across the six RFM customer segments.
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
    SELECT household_key,
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
),
promotion_activity AS (
    SELECT cs.customer_segment,
        -- Used EXISTS instead of JOIN to avoid counting households multiple times.
        EXISTS (
            SELECT 1
            FROM campaign_table ct
            WHERE ct.household_key = cs.household_key
        ) AS assigned_campaign,
        -- checks whether the household in customer_segments CTE has appeared at least once in campaign_table.
        EXISTS (
            SELECT 1
            FROM coupon_redempt cr
            WHERE cr.household_key = cs.household_key
        ) AS redeemed_coupon -- checks whether the household in customer_segments CTE has redeemed at least one coupon.
    FROM customer_segments cs
)
SELECT customer_segment,
    COUNT(*) AS households,
    COUNT(*) FILTER (
        WHERE assigned_campaign
    ) AS campaign_assigned_households,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE assigned_campaign
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS campaign_assignment_rate_pct,
    COUNT(*) FILTER (
        WHERE redeemed_coupon
    ) AS coupon_redeeming_households,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE redeemed_coupon
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE assigned_campaign
            ),
            0
        ),
        2
    ) AS redemption_rate_among_assigned_pct
FROM promotion_activity
GROUP BY customer_segment
ORDER BY redemption_rate_among_assigned_pct DESC;
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - BUSINESS QUESTION 10
 
 Key Findings: Business Question 10: Promotional Engagement
 - Champions have the highest campaign assignment (97.96%)
 and coupon redemption rate (43.56%).
 - Loyal Households have the second-highest campaign assignment (94.12%)
 and second-highest redemption rate (28.13%).
 - At-Risk households show high campaign assignment
 (81.22%) but lower coupon redemption (18.79%).
 - Hibernating households have the lowest assignment
 (12.20%) and redemption (1.49%) rates.
 
 Business Insight:
 Coupon redemption is more common among highly engaged
 RFM segments. Lower redemption among At-Risk and
 Hibernating households may warrant further investigation.
 
 Methodology Note:
 Rates are based on unique households, with coupon
 redemption measured among campaign-assigned households.
 Campaign assignment does not confirm active participation,
 and these results do not establish promotional effectiveness.
 */