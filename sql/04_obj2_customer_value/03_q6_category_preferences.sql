-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 3: Customer Behavior Analysis
-- OBJECTIVE 2: IDENTIFY CUSTOMER VALUE DRIVERS
-- =====================================================
-- BUSINESS QUESTION 6: 
-- How do product category preferences and category diversity differ between high-value and lower-value households?
-- =====================================================
-- Query 2.3A: Product Category Preferences
-- Purpose:
-- Compare the top-selling product departments between high-value (top 20%) and lower-value households.
-- Note: Customer groups based on spending analysis (Q4Query 2.1B)
-- =====================================================
WITH household_spending AS (
    SELECT household_key,
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
customer_groups AS (
    SELECT household_key,
        -- Groups based on Q4 (Query 2.1B): High-Value = top 20%  (500 hh) by spending; Lower-Value = remaining 80% (2000 hh).
        CASE
            WHEN NTILE(5) OVER (
                ORDER BY total_spending DESC,
                    household_key
            ) = 1 THEN 'High-Value'
            ELSE 'Lower-Value'
        END AS customer_group
    FROM household_spending
)
SELECT cg.customer_group,
    p.department,
    ROUND(SUM(t.sales_value), 2) AS department_sales,
    ROUND(
        100.0 * SUM(t.sales_value) / NULLIF(
            SUM(SUM(t.sales_value)) OVER (PARTITION BY cg.customer_group),
            0
        ),
        2
    ) AS department_share_of_group_total_sales_pct -- Department's share of total sales within its group (High-Value group: 500 hh; Lower-Value group: 2000 hh).
FROM transaction_data t
    JOIN customer_groups cg ON t.household_key = cg.household_key
    JOIN product p ON t.product_id = p.product_id
WHERE t.basket_id IN (
        SELECT basket_id
        FROM transaction_data
        WHERE quantity > 0
            AND sales_value > 0
    )
GROUP BY cg.customer_group,
    p.department
ORDER BY cg.customer_group,
    department_sales DESC;
/*
 Findings - Product Category Preferences:
 - Grocery accounts for the largest share of sales in both
 groups: 49.01% for High-Value and 52.84% for Lower-Value.
 - Kiosk-Gas represents 8.30% of High-Value group sales,
 compared with 5.01% for Lower-Value households.
 - Produce represents a similar share of sales in both
 groups (6.99% vs. 6.84%).
 
 Business Insight:
 Both groups spend mainly on similar departments, but
 the proportion of spending allocated to each differs.
 Grocery is relatively more important for Lower-Value
 households, while Kiosk-Gas has a higher sales share
 among High-Value households.
 
 Methodology Note:
 High-Value = top 20% of households by total spending;
 Lower-Value = remaining 80% (based on Q4).
 Each department's percentage represents its share of
 total recorded sales within that customer group.
 Kiosk-Gas and miscellaneous transactions may not
 represent ordinary retail product preferences.
 */
-- =====================================================
-- Query 2.3B: Product Category Diversity
-- Purpose:
-- Compare the variety of departments purchased from by High-Value (top 20%) and Lower-Value households.
-- Note: Customer groups based on spending analysis (Q4-Query 2.1B)
-- =====================================================
WITH household_spending AS (
    SELECT household_key,
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
customer_groups AS (
    SELECT household_key,
        -- Groups based on Q4: High-Value = top 20%; Lower-Value = remaining 80%.
        CASE
            WHEN NTILE(5) OVER (
                ORDER BY total_spending DESC,
                    household_key
            ) = 1 THEN 'High-Value'
            ELSE 'Lower-Value'
        END AS customer_group
    FROM household_spending
),
household_diversity AS (
    SELECT cg.household_key,
        cg.customer_group,
        COUNT(DISTINCT p.department) AS departments_purchased
    FROM customer_groups cg
        JOIN transaction_data t ON cg.household_key = t.household_key
        JOIN product p ON t.product_id = p.product_id
    WHERE t.quantity > 0
        AND t.sales_value > 0
        AND TRIM(p.department) <> ''
    GROUP BY cg.household_key,
        cg.customer_group
)
SELECT customer_group,
    COUNT(*) AS households,
    ROUND(AVG(departments_purchased), 2) AS avg_departments_per_household,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY departments_purchased
    ) AS median_departments_per_household,
    MIN(departments_purchased) AS min_departments,
    MAX(departments_purchased) AS max_departments
FROM household_diversity
GROUP BY customer_group
ORDER BY customer_group;
/*
 Findings - Product Category Diversity:
 - High-Value households purchased from an average of
 16.14 departments, compared with 11.31 for Lower-Value.
 - Median department diversity was 16 versus 11,
 confirming a similar difference in typical behavior.
 
 Business Insight:
 Higher-spending households tend to purchase across a
 wider range of departments. Cross-category engagement
 may offer opportunities to grow lower-value households.
 
 Methodology Note:
 Diversity measures distinct departments with positive
 quantity and sales, excluding blank department names.
 More frequent shopping may partly explain the difference.
 */
/*
 FINAL SUMMARY - BUSINESS QUESTION 6
 Key Findings:
 - Grocery dominates spending in both customer groups.
 - High-Value households allocate a larger share of their
 spending to Kiosk-Gas (8.30% vs. 5.01%).
 - High-Value households purchase from more departments
 on average (16.14 vs. 11.31).
 
 Business Insight:
 Both groups show similar leading department preferences,
 but High-Value households purchase across a wider variety
 of departments. Encouraging broader category engagement
 among Lower-Value households may offer growth opportunities.
 
 Note:
 High-Value households represent the top 20% by historical
 spending (Q4). Greater shopping frequency may partly
 explain their broader department diversity.
 */