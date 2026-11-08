-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Validate Table Relationships
-- =====================================================
-- Check transaction records without a matching product
SELECT COUNT(*) AS unmatched_product_records
FROM transaction_data AS t
    LEFT JOIN product AS p ON t.product_id = p.product_id
WHERE p.product_id IS NULL;
/* Every product_id in transaction_data exists in product
 [
 {
 "unmatched_product_records": "0"
 }
 ]
 */
-- Check households without demographic information
SELECT COUNT(DISTINCT t.household_key) AS households_without_demographics
FROM transaction_data AS t
    LEFT JOIN hh_demographic AS d ON t.household_key = d.household_key
WHERE d.household_key IS NULL;
/* Confirmed Kaggle information: Demographic information is available for certain households
 transactions represent 2,500 households, but only 801 have demographic profiles
 [
 {
 "households_without_demographics": "1699"
 }
 ]
 */
-- Check campaign assignments without a matching campaign
SELECT COUNT(*) AS unmatched_campaign_records
FROM campaign_table AS ct
    LEFT JOIN campaign_desc AS cd ON ct.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/* Every campaign in campaign_table exists in campaign_desc
 [
 {
 "unmatched_campaign_records": "0"
 }
 ]
 */
-- Check coupons without a matching campaign
SELECT COUNT(*) AS unmatched_coupon_campaigns
FROM coupon AS c
    LEFT JOIN campaign_desc AS cd ON c.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/* All coupon records reference valid campaigns
 [
 {
 "unmatched_coupon_campaigns": "0"
 }
 ]
 */
-- Check coupon records without a matching product
SELECT COUNT(*) AS unmatched_coupon_products
FROM coupon AS c
    LEFT JOIN product AS p ON c.product_id = p.product_id
WHERE p.product_id IS NULL;
/* All coupon records reference valid products
 [
 {
 "unmatched_coupon_products": "0"
 }
 ]
 */
-- Check coupon redemptions without a matching campaign
SELECT COUNT(*) AS unmatched_redemption_campaigns
FROM coupon_redempt AS cr
    LEFT JOIN campaign_desc AS cd ON cr.campaign = cd.campaign
WHERE cd.campaign IS NULL;
/* All coupon redemption records reference valid campaigns
 [
 {
 "unmatched_redemption_campaigns": "0"
 }
 ]
 */
-- Check redemptions without a matching coupon
-- in the same campaign
SELECT COUNT(*) AS unmatched_redeemed_coupons
FROM coupon_redempt AS cr
WHERE NOT EXISTS (
        SELECT 1
        FROM coupon AS c
        WHERE c.coupon_upc = cr.coupon_upc
            AND c.campaign = cr.campaign
    );
/* All coupon redemption records reference valid coupons in the same campaign
 [
 {
 "unmatched_redeemed_coupons": "0"
 }
 ]
 */
-- Check NULL values in proposed foreign key columns
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
 [
 {
 "null_campaign_assignments": "0",
 "null_coupon_campaigns": "0",
 "null_coupon_products": "0",
 "null_redemption_campaigns": "0"
 }
 ]
 */