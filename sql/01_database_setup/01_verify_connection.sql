-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Verify Connection to Database
-- DATABASE: retail_customer_intelligence
-- =====================================================
SELECT current_database() AS database_name,
    current_user AS connected_user,
    version() AS postgresql_version;
/*
 "database_name": "retail_customer_intelligence",
 */