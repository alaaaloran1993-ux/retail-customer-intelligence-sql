-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Validate Table Relationships
-- DATABASE: retail_customer_intelligence
-- =====================================================
-- Check transaction records without a matching product
-- =====================================================
SELECT COUNT(*) AS unmatched_product_records
FROM transaction_data AS t
    LEFT JOIN product AS p ON t.product_id = p.product_id
WHERE p.product_id IS NULL;
/*
 Finding: No transaction records reference an unmatched product
 (0 unmatched records).
 */
-- =====================================================
-- Check households without demographic information
-- =====================================================
SELECT COUNT(DISTINCT t.household_key) AS households_without_demographics
FROM transaction_data AS t
    LEFT JOIN hh_demographic AS d ON t.household_key = d.household_key
WHERE d.household_key IS NULL;
/*
 Finding: 1,699 of 2,500 purchasing households (67.96%)
 have no demographic profile; only 801 are covered.
 Note: Demographic analysis applies only to the covered subset.
 */
-- =====================================================
-- Check campaign assignments without a matching campaign
-- =====================================================
SELECT COUNT(*) AS unmatched_campaign_records
FROM campaign_table AS ct
    LEFT JOIN campaign_desc AS cd ON ct.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/*
 Finding: All campaign assignments reference a matching campaign
 (0 unmatched records).
 */
-- =====================================================
-- Check coupons without a matching campaign
-- =====================================================
SELECT COUNT(*) AS unmatched_coupon_campaigns
FROM coupon AS c
    LEFT JOIN campaign_desc AS cd ON c.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/*
 Finding: All coupon records reference a matching campaign
 (0 unmatched records).
 */
-- =====================================================
-- Check coupon records without a matching product
-- =====================================================
SELECT COUNT(*) AS unmatched_coupon_products
FROM coupon AS c
    LEFT JOIN product AS p ON c.product_id = p.product_id
WHERE p.product_id IS NULL;
/*
 Finding: All coupon records reference a matching product
 (0 unmatched records).
 */
-- =====================================================
-- Check coupon redemptions without a matching campaign
-- =====================================================
SELECT COUNT(*) AS unmatched_redemption_campaigns
FROM coupon_redempt AS cr
    LEFT JOIN campaign_desc AS cd ON cr.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/*
 Finding: All coupon redemptions reference a matching campaign
 (0 unmatched records).
 */
-- =====================================================
-- Check redemptions without a matching coupon in the same campaign
-- =====================================================
SELECT COUNT(*) AS unmatched_redeemed_coupons
FROM coupon_redempt AS cr
WHERE NOT EXISTS (
        SELECT 1
        FROM coupon AS c
        WHERE c.coupon_upc = cr.coupon_upc
            AND c.campaign = cr.campaign
    );
/*
 Finding: All redeemed coupons match a coupon within the same
 campaign (0 unmatched redemption records).
 */
-- =====================================================
-- Check NULL values in proposed foreign key columns
-- =====================================================
SELECT (
        SELECT COUNT(*)
        FROM campaign_table
        WHERE campaign IS NULL
    ) AS null_campaign_assignments,
    (
        SELECT COUNT(*)
        FROM coupon
        WHERE campaign IS NULL
    ) AS null_coupon_campaigns,
    (
        SELECT COUNT(*)
        FROM coupon
        WHERE product_id IS NULL
    ) AS null_coupon_products,
    (
        SELECT COUNT(*)
        FROM coupon_redempt
        WHERE campaign IS NULL
    ) AS null_redemption_campaigns;
/*
 Finding: No NULL values were found in the four tested
 campaign and product reference columns.
 */
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - RELATIONSHIP VALIDATION
 - All tested product, campaign, and coupon references matched.
 - The tested reference columns contain no NULL values.
 - Demographic coverage is limited to 801 of 2,500 households.
 
 Methodology Note:
 These queries validate the tested data relationships; they do
 not by themselves establish that foreign key constraints exist.
 Demographic analyses must disclose the limited coverage.
 */