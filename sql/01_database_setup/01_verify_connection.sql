-- =====================================================
-- PROJECT: Retail Customer Intelligence
-- PHASE 1: Verify Connection to Database
-- DATABASE: retail_customer_intelligence
-- =====================================================
SELECT current_database() AS database_name,
    current_user AS connected_user,
    version() AS postgresql_version;
/*
 [
 {
 "database_name": "retail_customer_intelligence",
 "connected_user": "postgres",
 "postgresql_version": "PostgreSQL 18.6 on x86_64-windows, compiled by msvc-19.44.35229, 64-bit"
 }
 ]
 */