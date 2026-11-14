-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Validate Data Import
-- DATABASE: retail_customer_intelligence
-- =====================================================
-- Final verification of the first three imported tables
-- Core Tables — Customer & Sales Data
-- =====================================================
SELECT 'product' AS table_name,
    COUNT(*) AS total_rows
FROM product
UNION ALL
SELECT 'hh_demographic',
    COUNT(*)
FROM hh_demographic
UNION ALL
SELECT 'transaction_data',
    COUNT(*)
FROM transaction_data;
/*
 Findings - Core Table Import:
 - product: 92,353 rows.
 - hh_demographic: 801 rows.
 - transaction_data: 2,595,732 rows.
 - All three tables contain imported records.
 */
-- =====================================================
-- Final verification of the next four imported tables
-- Marketing & Promotion Tables
-- =====================================================
SELECT 'campaign_desc' AS table_name,
    COUNT (*) AS total_rows
FROM campaign_desc
UNION ALL
SELECT 'campaign_table',
    COUNT (*)
FROM campaign_table
UNION ALL
SELECT 'coupon',
    COUNT (*)
FROM coupon
UNION ALL
SELECT 'coupon_redempt',
    COUNT (*)
FROM coupon_redempt;
/*
 Findings - Promotional Table Import:
 - campaign_desc: 30 rows; campaign_table: 7,208 rows.
 - coupon: 124,548 rows; coupon_redempt: 2,318 rows.
 - All four promotional tables contain imported records.
 */
-- =====================================================
--FINAL SUMMARY
-- =====================================================
/*
 FINAL SUMMARY - DATA IMPORT VALIDATION
 All seven source tables were imported and contain records.
 These row counts establish the imported data volumes; they do
 not by themselves confirm completeness or data accuracy.
 */