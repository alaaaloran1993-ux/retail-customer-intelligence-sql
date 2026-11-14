-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: CUSTOMER PURCHASING BEHAVIOR
-- =====================================================
-- Step 3.1: Validate Qualifying Purchase Baskets
-- Purpose:
-- Identify how many recorded baskets contain actual purchasing activity before calculating purchase frequency and customer retention KPIs.
-- =====================================================
WITH basket_summary AS (
    SELECT basket_id,
        COUNT(*) AS total_lines,
        COUNT(*) FILTER (
            WHERE quantity > 0
                AND sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data
    GROUP BY basket_id
)
SELECT COUNT(*) AS total_baskets,
    COUNT(*) FILTER (
        WHERE positive_purchase_lines > 0
    ) AS qualifying_purchase_baskets,
    COUNT(*) FILTER (
        WHERE positive_purchase_lines = 0
    ) AS non_qualifying_baskets,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE positive_purchase_lines > 0
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS qualifying_purchase_pct
FROM basket_summary;
/*
 Findings - Qualifying Purchase Basket Validation:
 
 - Identified 276,484 unique baskets.
 - 275,539 baskets (99.66%) contain at least one
 transaction line with quantity > 0 AND sales_value > 0.
 - 945 baskets (0.34%) contain no such transaction lines.
 - The 945 non-qualifying baskets include the 317 baskets
 investigated during Phase 2.
 
 Conclusion:
 Most recorded baskets meet the proposed qualifying
 purchase definition.
 
 Methodological Decision:
 Use baskets containing at least one positive-quantity,
 positive-sales line when calculating purchase frequency,
 subject to the final review of non-qualifying activity.
 
 Note:
 The definition identifies positive purchasing activity,
 but does not independently verify the transaction type.
 All original records remain unchanged.
 */
-- =====================================================
-- Step 3.2: Investigate Non-Qualifying Baskets
--
-- Business Purpose:
-- Understand the transaction characteristics of
-- baskets that contain no positive purchase lines.
-- =====================================================
WITH basket_summary AS (
    SELECT basket_id,
        SUM(sales_value) AS basket_sales,
        SUM(quantity) AS basket_quantity,
        COUNT(*) FILTER (
            WHERE quantity > 0
                AND sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data
    GROUP BY basket_id
)
SELECT COUNT(*) AS non_qualifying_baskets,
    COUNT(*) FILTER (
        WHERE basket_sales = 0
            AND basket_quantity = 0
    ) AS zero_sales_zero_quantity,
    COUNT(*) FILTER (
        WHERE basket_sales = 0
            AND basket_quantity > 0
    ) AS zero_sales_positive_quantity,
    COUNT(*) FILTER (
        WHERE basket_sales > 0
            AND basket_quantity = 0
    ) AS positive_sales_zero_quantity
FROM basket_summary
WHERE positive_purchase_lines = 0;
/*
 Findings - Non-Qualifying Basket Investigation:
 - Identified 945 baskets without positive-quantity,
 positive-sales transaction lines.
 - 592 baskets have zero total sales and quantity.
 - 350 baskets have zero sales but positive quantity.
 - 3 baskets have positive sales but zero quantity.
 - All 945 non-qualifying baskets are accounted for.
 
 Conclusion:
 Most non-qualifying baskets (942 of 945) have zero
 recorded sales value and do not appear to represent
 revenue-generating purchases.
 
 Methodological Note:
 The 3 baskets with positive sales and zero quantity
 require further investigation before finalizing
 the qualifying-purchase definition.
 
 No original records have been modified or deleted.
 */
-- =====================================================
-- Step 3.3: Investigate Positive-Sales, Zero-Quantity Baskets
-- Purpose:
-- Examine baskets with recorded sales value but no qualifying purchase lines to understand whether they represent genuine purchasing activity.
-- =====================================================
WITH basket_summary AS (
    SELECT basket_id,
        SUM(sales_value) AS basket_sales,
        SUM(quantity) AS basket_quantity,
        COUNT(*) FILTER (
            WHERE quantity > 0
                AND sales_value > 0
        ) AS positive_purchase_lines
    FROM transaction_data
    GROUP BY basket_id
)
SELECT t.basket_id,
    t.household_key,
    t.product_id,
    p.department,
    p.commodity_desc,
    p.sub_commodity_desc,
    t.quantity,
    t.sales_value
FROM transaction_data AS t
    JOIN product AS p ON t.product_id = p.product_id
    JOIN basket_summary AS bs ON t.basket_id = bs.basket_id
WHERE bs.positive_purchase_lines = 0
    AND bs.basket_sales > 0
    AND bs.basket_quantity = 0
ORDER BY t.basket_id,
    t.product_id;
/*
 Findings - Exceptional Basket Investigation:
 - Identified 3 baskets with positive recorded sales
 but zero total quantity.
 - These baskets contain 5 transaction lines.
 - Recorded sales values are $0.01, $0.32, and $0.10,
 totaling $0.43.
 - Two baskets include ordinary grocery or meat
 products; one contains a miscellaneous sales item.
 - The reason for zero quantities cannot be confirmed
 from the available data.
 
 Conclusion:
 The 3 baskets do not meet our qualifying-purchase
 definition and will be excluded from purchase counts.
 
 Methodological Decision:
 A qualifying purchase basket must contain at least
 one transaction line satisfying:
 quantity > 0 AND sales_value > 0.
 
 - 275,539 baskets qualify as purchases.
 - 945 baskets do not qualify.
 - The rule applies to purchase-frequency and
 related customer engagement metrics.
 - Monetary KPI definitions will be established
 separately to avoid unintended sales exclusions.
 
 Limitation:
 This is an analytical definition, not independent
 proof that every qualifying basket represents
 a completed retail purchase.
 
 All original transaction records remain unchanged.
 */