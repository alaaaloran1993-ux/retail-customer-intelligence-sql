-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 3: CUSTOMER SEGMENTATION
-- =====================================================
-- Q10 and Q11 Feasibility Checking
-- =====================================================
-- Analysis 3.4.1: Promotional Data Structure
-- Purpose:
-- Review available campaign and coupon fields to assess whether Q10 and Q11 can be analyzed reliably.
-- =====================================================
SELECT table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name IN (
        'campaign_desc',
        'campaign_table',
        'coupon',
        'coupon_redempt'
    )
ORDER BY table_name,
    ordinal_position;
/*
 Findings - Promotional Data Structure:
 - All four promotional tables contain the key fields
 needed to link campaigns, households, and coupons.
 - Campaign dates and coupon redemption dates are available.
 
 Note:
 Campaign assignment does not confirm active engagement;
 coupon redemption provides evidence of coupon usage.
 */
-- =====================================================
-- Analysis 3.4.2: Promotional Data Coverage
-- Purpose:
-- Assess the volume and coverage of campaign assignments and coupon redemptions before analyzing Q10 and Q11.
-- =====================================================
SELECT (
        SELECT COUNT(*)
        FROM campaign_desc
    ) AS total_campaigns,
    (
        SELECT COUNT(DISTINCT household_key)
        FROM campaign_table
    ) AS campaign_assigned_households,
    (
        SELECT COUNT(DISTINCT household_key)
        FROM coupon_redempt
    ) AS coupon_redeeming_households,
    (
        SELECT COUNT(*)
        FROM coupon_redempt
    ) AS total_coupon_redemptions,
    (
        SELECT MIN(start_day)
        FROM campaign_desc
    ) AS earliest_campaign_start,
    (
        SELECT MAX(end_day)
        FROM campaign_desc
    ) AS latest_campaign_end,
    (
        SELECT MIN(day)
        FROM coupon_redempt
    ) AS earliest_redemption_day,
    (
        SELECT MAX(day)
        FROM coupon_redempt
    ) AS latest_redemption_day;
/*
 Findings - Promotional Data Coverage:
 - 30 campaigns cover 1,584 assigned households.
 - 434 households recorded 2,318 coupon redemptions.
 - Campaigns span days 224–719, while redemptions
 occurred between days 225–704.
 
 Note:
 Some campaigns extend beyond the transaction data
 (day 711), limiting subsequent purchasing analysis.
 */
-- =====================================================
-- Analysis 3.4.3: Promotional Relationship and Timing Validation
-- Purpose:
-- Check whether coupon redemptions match campaign assignments and occur within campaign periods.
-- =====================================================
SELECT COUNT(*) AS total_redemptions,
    COUNT(*) FILTER (
        WHERE ct.household_key IS NOT NULL
    ) AS matched_campaign_assignments,
    COUNT(*) FILTER (
        WHERE cd.campaign IS NOT NULL
            AND cr.day BETWEEN cd.start_day AND cd.end_day
    ) AS redemptions_within_campaign_period
FROM coupon_redempt cr
    LEFT JOIN campaign_table ct ON cr.household_key = ct.household_key
    AND cr.campaign = ct.campaign
    LEFT JOIN campaign_desc cd ON cr.campaign = cd.campaign;
/*
 Findings - Promotional Relationship Validation:
 - All 2,318 redemptions matched household campaign
 assignments.
 - All 2,318 occurred within their campaign periods.
 
 Business Insight:
 The promotional records show consistent relationships
 and timing, supporting further engagement analysis.
 */
-- =====================================================
-- Analysis 3.4.4: Q11 Feasibility Before/After Purchase Windows
-- Purpose:
-- Check how many coupon-redeeming households have complete 30-day observation windows around redemption.
-- =====================================================
WITH first_redemption AS (
    SELECT household_key,
        MIN(day) AS first_redemption_day
    FROM coupon_redempt
    GROUP BY household_key
)
SELECT COUNT(*) AS total_redeeming_households,
    COUNT(*) FILTER (
        WHERE first_redemption_day BETWEEN 31 AND 681
    ) AS eligible_30day_households,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE first_redemption_day BETWEEN 31 AND 681
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS eligible_30day_pct
FROM first_redemption;
/*
 Findings - Q11 Promotional Analysis Feasibility:
 - 432 of 434 coupon-redeeming households (99.54%)
 have complete 30-day observation windows before
 and after their first redemption.
 - Only 2 households fall outside the eligible period.
 
 Conclusion:
 The dataset supports a descriptive before-and-after
 purchase comparison for most coupon-redeeming households.
 
 Note:
 Eligibility confirms observation-window coverage,
 not purchasing activity or promotional effectiveness.
 */
/*
 FINAL SUMMARY - PROMOTIONAL DATA VALIDATION
 Key Findings:
 - 30 campaigns cover 1,584 assigned households.
 - 434 households recorded 2,318 coupon redemptions.
 - All redemptions matched campaign assignments
 and occurred within their campaign periods.
 - 432 of 434 redeeming households (99.54%) have
 complete 30-day before-and-after observation windows.
 
 Conclusion:
 The promotional data supports Q10's descriptive
 engagement analysis and provides sufficient observation
 coverage to investigate Q11.
 
 Note:
 Campaign assignment does not confirm engagement.
 Before-and-after associations cannot establish
 that promotions caused purchasing changes.
 */