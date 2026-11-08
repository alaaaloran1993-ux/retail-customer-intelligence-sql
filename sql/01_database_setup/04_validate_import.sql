-- Final verification of our the first three imported tables
-- Core Tables — Customer & Sales Data
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
 [
 {
 "table_name": "product",
 "total_rows": "92353"
 },
 {
 "table_name": "hh_demographic",
 "total_rows": "801"
 },
 {
 "table_name": "transaction_data",
 "total_rows": "2595732"
 }
 ]
 */
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
 [
 {
 "table_name": "campaign_desc",
 "total_rows": "30"
 },
 {
 "table_name": "campaign_table",
 "total_rows": "7208"
 },
 {
 "table_name": "coupon",
 "total_rows": "124548"
 },
 {
 "table_name": "coupon_redempt",
 "total_rows": "2318"
 }
 ]
 */