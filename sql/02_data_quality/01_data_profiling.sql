-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 2: Data Exploration & Quality
-- PURPOSE: Profile transaction data completeness
-- =====================================================
-- Step 2.1: Check Missing Values 
-- =====================================================
SELECT COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE household_key IS NULL
    ) AS null_households,
    COUNT(*) FILTER (
        WHERE basket_id IS NULL
    ) AS null_baskets,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS null_products,
    COUNT(*) FILTER (
        WHERE day IS NULL
    ) AS null_days,
    COUNT(*) FILTER (
        WHERE quantity IS NULL
    ) AS null_quantities,
    COUNT(*) FILTER (
        WHERE sales_value IS NULL
    ) AS null_sales
FROM transaction_data;
/*
 Findings - Missing Values Analysis:
 - Reviewed 2,595,732 transaction lines.
 - No NULL values were found in household_key, basket_id,
 product_id, day, quantity, or sales_value.
 
 Conclusion:
 All six checked fields passed the completeness test.
 
 Note:
 This does not establish that all fields or values are valid;
 zero values, blank text, and other anomalies need separate checks.
 */
-- =====================================================
-- Step 2.2: Explore transaction value ranges
-- =====================================================
SELECT MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(sales_value) AS min_sales_value,
    MAX(sales_value) AS max_sales_value,
    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS non_positive_quantities,
    COUNT(*) FILTER (
        WHERE sales_value <= 0
    ) AS non_positive_sales
FROM transaction_data;
/*
 Findings - Transaction Value Ranges:
 - Quantity ranges from 0 to 89,638.
 - Sales value ranges from 0.00 to 840.00.
 - 14,466 lines have non-positive quantity (minimum is 0).
 - 18,879 lines have non-positive sales (minimum is 0).
 
 Conclusion:
 Zero values and unusually high quantities need investigation
 before establishing purchasing and unit-based KPIs.
 
 Note:
 These counts overlap; do not add them as distinct records.
 */
-- =====================================================
-- Step 2.3: Investigate highest-quantity transactions
-- =====================================================
SELECT t.household_key,
    t.basket_id,
    t.product_id,
    p.department,
    p.commodity_desc,
    p.sub_commodity_desc,
    t.quantity,
    t.sales_value
FROM transaction_data AS t
    LEFT JOIN product AS p ON t.product_id = p.product_id
ORDER BY t.quantity DESC
LIMIT 20;
/*
 Findings - Highest-Quantity Transactions:
 - All 20 highest-quantity lines are classified as
 GASOLINE-REG UNLEADED under COUPON/MISC ITEMS.
 - Departments include KIOSK-GAS and MISC SALES TRAN.
 - The maximum quantity is 89,638, with sales of 250.00.
 
 Conclusion:
 Large gasoline quantities suggest a measurement convention
 that may differ from ordinary grocery unit counts.
 
 Note:
 The exact gasoline quantity unit and scaling are unverified;
 do not interpret these quantities as individual items.
 */
-- =====================================================
-- Step 2.4: Investigate gasoline transaction quantities
-- =====================================================
SELECT p.department,
    COUNT(*) AS transaction_lines,
    MIN(t.quantity) AS min_quantity,
    MAX(t.quantity) AS max_quantity,
    SUM(t.sales_value) AS total_sales
FROM transaction_data AS t
    JOIN product AS p ON t.product_id = p.product_id
WHERE p.sub_commodity_desc = 'GASOLINE-REG UNLEADED'
GROUP BY p.department
ORDER BY transaction_lines DESC;
/*
 Findings - Gasoline Transaction Analysis:
 - KIOSK-GAS: 22,059 lines; sales value 544,222.28;
 quantity ranges from 1 to 89,638.
 - MISC SALES TRAN: 2,903 lines; sales value 89,734.98;
 quantity ranges from 1 to 85,055.
 - Together: 24,962 lines and 633,957.26 in sales value,
 approximately 0.96% of all transaction lines.
 
 Conclusion:
 Gasoline quantities should be evaluated separately from
 ordinary merchandise units until their meaning is established.
 
 Note:
 Retain the source transactions and monetary values; apply
 special handling only to unit-based analysis as appropriate.
 */
-- =====================================================
-- Step 2.5: Investigate zero-quantity and zero-sales records
-- =====================================================
SELECT COUNT(*) FILTER (
        WHERE quantity = 0
            AND sales_value = 0
    ) AS zero_quantity_and_sales,
    COUNT(*) FILTER (
        WHERE quantity = 0
            AND sales_value > 0
    ) AS zero_quantity_positive_sales,
    COUNT(*) FILTER (
        WHERE quantity > 0
            AND sales_value = 0
    ) AS positive_quantity_zero_sales
FROM transaction_data;
/*
 Findings - Zero Quantity and Zero Sales Analysis:
 - 14,428 lines have both zero quantity and zero sales.
 - 38 lines have zero quantity but positive sales.
 - 4,451 lines have positive quantity but zero sales.
 
 Conclusion:
 The zero-value records represent several distinct patterns
 and should not be treated as a single issue.
 
 Note:
 Their business purpose is not confirmed; investigate product
 categories and transaction details before excluding records.
 */
-- =====================================================
-- Step 2.6: Investigate unusual transactions by department
-- =====================================================
SELECT p.department,
    COUNT(*) AS unusual_transaction_lines,
    COUNT(*) FILTER (
        WHERE t.quantity = 0
            AND t.sales_value = 0
    ) AS zero_quantity_and_sales,
    COUNT(*) FILTER (
        WHERE t.quantity = 0
            AND t.sales_value > 0
    ) AS zero_quantity_positive_sales,
    COUNT(*) FILTER (
        WHERE t.quantity > 0
            AND t.sales_value = 0
    ) AS positive_quantity_zero_sales
FROM transaction_data AS t
    JOIN product AS p ON t.product_id = p.product_id
WHERE t.quantity = 0
    OR t.sales_value = 0
GROUP BY p.department
ORDER BY unusual_transaction_lines DESC;
/*
 Findings - Unusual Transactions by Department:
 - A blank/whitespace-only department accounts for 7,839
 unusual lines, all with zero quantity and zero sales.
 - GROCERY has 3,770 unusual lines; DRUG GM has 2,003;
 PRODUCE has 1,686.
 - COUP/STR & MFG has 444 lines with positive quantity
 and zero sales.
 
 Conclusion:
 Unusual zero-value patterns occur in both blank product
 classifications and ordinary merchandise departments.
 
 Note:
 A blank department is not the same as SQL NULL. Use TRIM()
 when investigating whitespace-only text values.
 */
-- =====================================================
-- Step 2.7: Investigate blank department records
-- =====================================================
SELECT p.product_id,
    p.department,
    p.commodity_desc,
    p.sub_commodity_desc,
    COUNT(*) AS transaction_lines,
    MIN(t.quantity) AS min_quantity,
    MAX(t.quantity) AS max_quantity,
    SUM(t.sales_value) AS total_sales
FROM transaction_data AS t
    JOIN product AS p ON t.product_id = p.product_id
WHERE TRIM(p.department) = ''
GROUP BY p.product_id,
    p.department,
    p.commodity_desc,
    p.sub_commodity_desc
ORDER BY transaction_lines DESC
LIMIT 20;
/*
 Findings - Blank Department Investigation:
 - Identified 7,839 lines associated with 15 product IDs.
 - Product IDs 5978656 and 5978648 account for 7,754 lines
 (98.9% of the blank-department lines).
 - All 7,839 lines have zero quantity and zero sales,
 and blank department, commodity and subcommodity fields.
 
 Conclusion:
 The pattern is consistent with unidentified placeholder
 or non-merchandise records, but their purpose is unconfirmed.
 
 Note:
 Keep original records. Test whether associated baskets
 contain qualifying purchase activity before excluding them.
 */
-- =====================================================
-- Step 2.8: Check whether blank-department records belong to baskets containing valid purchases
-- =====================================================
WITH blank_baskets AS (
    SELECT DISTINCT t.basket_id
    FROM transaction_data AS t
        JOIN product AS p ON t.product_id = p.product_id
    WHERE TRIM(p.department) = ''
),
basket_activity AS (
    SELECT t.basket_id,
        COUNT(*) AS total_lines,
        COUNT(*) FILTER (
            WHERE t.quantity > 0
                AND t.sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data AS t
    WHERE t.basket_id IN (
            SELECT basket_id
            FROM blank_baskets
        )
    GROUP BY t.basket_id
)
SELECT COUNT(*) AS baskets_with_blank_department,
    COUNT(*) FILTER (
        WHERE positive_purchase_lines > 0
    ) AS baskets_with_valid_purchases,
    COUNT(*) FILTER (
        WHERE positive_purchase_lines = 0
    ) AS baskets_without_positive_purchases
FROM basket_activity;
/*
 Findings - Blank Department Basket Analysis:
 - Found 7,392 distinct baskets with blank-department lines.
 - 7,075 baskets (95.7%) also contain at least one line
 with positive quantity and positive sales.
 - 317 baskets (4.3%) contain no such positive purchase line.
 
 Conclusion:
 Removing entire baskets merely because they contain blank
 lines would also discard substantial valid purchase activity.
 
 Note:
 Retain the 7,075 baskets in purchase-related investigations;
 inspect the 317 exceptions before defining purchase baskets.
 */
-- =====================================================
-- Step 2.9: Examine baskets without positive purchase lines
-- =====================================================
WITH blank_baskets AS (
    SELECT DISTINCT t.basket_id
    FROM transaction_data AS t
        JOIN product AS p ON t.product_id = p.product_id
    WHERE TRIM(p.department) = ''
),
basket_summary AS (
    SELECT t.basket_id,
        SUM(t.sales_value) AS basket_sales,
        SUM(t.quantity) AS basket_quantity,
        COUNT(*) FILTER (
            WHERE t.quantity > 0
                AND t.sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data AS t
    WHERE t.basket_id IN (
            SELECT basket_id
            FROM blank_baskets
        )
    GROUP BY t.basket_id
)
SELECT COUNT(*) AS baskets_without_positive_purchases,
    COUNT(*) FILTER (
        WHERE basket_sales = 0
            AND basket_quantity = 0
    ) AS entirely_zero_baskets,
    COUNT(*) FILTER (
        WHERE basket_sales > 0
            OR basket_quantity > 0
    ) AS baskets_with_other_activity
FROM basket_summary
WHERE positive_purchase_lines = 0;
/*
 Findings - Baskets Without Positive Purchases:
 - Of 317 baskets lacking positive-quantity, positive-sales
 lines, 315 have total quantity = 0 and total sales = 0.
 - Two baskets have other recorded activity.
 
 Conclusion:
 The 315 entirely zero baskets appear non-purchasing under
 our proposed positive-purchase definition.
 
 Note:
 The remaining two baskets require line-level review;
 source records should not be deleted.
 */
-- =====================================================
-- Step 2.10: Investigate exceptional baskets
-- =====================================================
WITH blank_baskets AS (
    SELECT DISTINCT t.basket_id
    FROM transaction_data AS t
        JOIN product AS p ON t.product_id = p.product_id
    WHERE TRIM(p.department) = ''
),
basket_summary AS (
    SELECT t.basket_id,
        SUM(t.sales_value) AS basket_sales,
        SUM(t.quantity) AS basket_quantity,
        COUNT(*) FILTER (
            WHERE t.quantity > 0
                AND t.sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data AS t
    WHERE t.basket_id IN (
            SELECT basket_id
            FROM blank_baskets
        )
    GROUP BY t.basket_id
)
SELECT t.basket_id,
    t.household_key,
    t.product_id,
    p.department,
    p.commodity_desc,
    t.quantity,
    t.sales_value
FROM transaction_data AS t
    JOIN product AS p ON t.product_id = p.product_id
    JOIN basket_summary AS bs ON t.basket_id = bs.basket_id
WHERE bs.positive_purchase_lines = 0
    AND (
        bs.basket_sales > 0
        OR bs.basket_quantity > 0
    )
ORDER BY t.basket_id,
    t.product_id;
/*
 Findings - Exceptional Basket Investigation:
 - Examined baskets 31625342103 and 31687292733.
 - Each contains a coupon-related line (quantity 1,
 sales 0.00) and a blank-department line (quantity 0,
 sales 0.00).
 - Neither basket has a line with positive quantity
 AND positive sales.
 
 Conclusion:
 All 317 exceptional baskets lack positive purchase lines.
 
 Proposed Rule:
 A qualifying purchase basket contains at least one line
 where quantity > 0 AND sales_value > 0.
 
 Note:
 Validate the rule across all baskets before using it for
 frequency and retention KPIs. Keep original data unchanged.
 */
-- =====================================================
-- Step 2.11: Check for exact duplicate transaction records
-- =====================================================
SELECT household_key,
    basket_id,
    day,
    product_id,
    quantity,
    sales_value,
    store_id,
    retail_disc,
    trans_time,
    week_no,
    coupon_disc,
    coupon_match_disc,
    COUNT(*) AS duplicate_count
FROM transaction_data
GROUP BY household_key,
    basket_id,
    day,
    product_id,
    quantity,
    sales_value,
    store_id,
    retail_disc,
    trans_time,
    week_no,
    coupon_disc,
    coupon_match_disc
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;
/*
 Findings - Exact Duplicate Transaction Analysis:
 - No exact duplicate groups were returned when comparing
 all 12 transaction_data columns.
 - The check covered 2,595,732 transaction lines.
 
 Conclusion:
 No exact duplicates were detected by this test, so there
 is no basis for deduplication from this check alone.
 
 Note:
 Repeated products in one basket may still be legitimate;
 there is no separate source transaction-line identifier.
 */
-- =====================================================
-- Step 2.12: Validate transaction period
-- =====================================================
SELECT MIN(day) AS first_transaction_day,
    MAX(day) AS last_transaction_day,
    COUNT(DISTINCT day) AS active_transaction_days,
    MIN(week_no) AS first_week,
    MAX(week_no) AS last_week
FROM transaction_data;
/*
 Findings - Transaction Period Validation:
 - Transaction days range from 1 through 711.
 - All 711 distinct day numbers are represented.
 - Week numbers range from 1 to 102.
 
 Conclusion:
 The dataset supports longitudinal purchasing analysis over
 711 relative days (approximately 23 months).
 
 Note:
 Calendar dates were not verified; do not label relative
 days or weeks as specific real-world calendar dates.
 */
-- =====================================================
-- Step 2.13: Validate basket consistency
-- =====================================================
SELECT COUNT(*) AS total_baskets,
    COUNT(*) FILTER (
        WHERE household_count > 1
    ) AS baskets_multiple_households,
    COUNT(*) FILTER (
        WHERE day_count > 1
    ) AS baskets_multiple_days,
    COUNT(*) FILTER (
        WHERE store_count > 1
    ) AS baskets_multiple_stores
FROM (
        SELECT basket_id,
            COUNT(DISTINCT household_key) AS household_count,
            COUNT(DISTINCT day) AS day_count,
            COUNT(DISTINCT store_id) AS store_count
        FROM transaction_data
        GROUP BY basket_id
    ) AS basket_summary;
/*
 Findings - Basket Consistency Validation:
 - Identified 276,484 distinct shopping baskets.
 - No basket IDs occur across multiple households.
 - No basket IDs occur across multiple transaction days.
 - No basket IDs occur across multiple stores.
 
 Conclusion:
 BASKET_ID consistently identifies one household, day and
 store, and supports basket-level aggregation.
 
 Note:
 A consistent basket ID does not prove a completed purchase.
 Apply a validated qualifying-purchase rule when computing
 frequency, basket value and customer-retention metrics.
 */