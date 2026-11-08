-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Database Setup
-- PURPOSE: Create the three core dataset tables
-- DATABASE: retail_customer_intelligence
-- =====================================================
-- =====================================================
-- Core Tables — Customer & Sales Data
-- =====================================================
-- 1. Create product reference table
CREATE TABLE public.product (
    product_id INTEGER PRIMARY KEY,
    manufacturer INTEGER,
    department VARCHAR(100),
    brand VARCHAR(50),
    commodity_desc VARCHAR(150),
    sub_commodity_desc VARCHAR(150),
    curr_size_of_product VARCHAR(100)
);
-- 2. Create household demographic table
CREATE TABLE public.hh_demographic (
    age_desc VARCHAR(20),
    marital_status_code VARCHAR(10),
    income_desc VARCHAR(30),
    homeowner_desc VARCHAR(50),
    hh_comp_desc VARCHAR(100),
    household_size_desc VARCHAR(20),
    kid_category_desc VARCHAR(30),
    household_key INTEGER PRIMARY KEY
);
-- 3. Create transaction data table
CREATE TABLE public.transaction_data (
    household_key INTEGER,
    basket_id BIGINT,
    day INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    sales_value NUMERIC(12, 2),
    store_id INTEGER,
    retail_disc NUMERIC(12, 2),
    trans_time INTEGER,
    week_no INTEGER,
    coupon_disc NUMERIC(12, 2),
    coupon_match_disc NUMERIC(12, 2)
);
-- =====================================================
-- FOREIGN KEY RELATIONSHIPS
-- Run only after tables are created and data is validated
-- =====================================================
-- Add relationship between transactions and products
ALTER TABLE transaction_data
ADD CONSTRAINT fk_transaction_product FOREIGN KEY (product_id) REFERENCES product(product_id);
-- =====================================================
-- MARKETING & PROMOTION TABLES
-- =====================================================
-- 4. Create campaign description table
CREATE TABLE campaign_desc (
    description VARCHAR(20),
    campaign INTEGER PRIMARY KEY,
    start_day INTEGER,
    end_day INTEGER
);
-- 5. Create campaign household assignment table
CREATE TABLE campaign_table (
    description VARCHAR(20),
    household_key INTEGER,
    campaign INTEGER
);
-- 6. Create coupon eligibility table
CREATE TABLE coupon (
    coupon_upc BIGINT,
    product_id INTEGER,
    campaign INTEGER
);
-- 7. Create coupon redemption table
CREATE TABLE coupon_redempt (
    household_key INTEGER,
    day INTEGER,
    coupon_upc BIGINT,
    campaign INTEGER
);
-- =====================================================
-- FOREIGN KEY RELATIONSHIPS
-- Run only after tables are created and data is validated
-- =====================================================
-- Add relationship between:
-- 1. Campaign assignments -> Campaign descriptions
ALTER TABLE campaign_table
ADD CONSTRAINT fk_campaign_table_campaign FOREIGN KEY (campaign) REFERENCES campaign_desc(campaign);
-- 2. Coupons -> Campaign descriptions
ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_campaign FOREIGN KEY (campaign) REFERENCES campaign_desc(campaign);
-- 3. Coupons -> Products
ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_product FOREIGN KEY (product_id) REFERENCES product(product_id);
-- 4. Coupon redemptions -> Campaign descriptions
ALTER TABLE coupon_redempt
ADD CONSTRAINT fk_redemption_campaign FOREIGN KEY (campaign) REFERENCES campaign_desc(campaign);