/*
================================================================================
 * Script: 03_create_warehouse.sql
 * Purpose: Create warehouse for Document Rodeo
 * Author: SE Community
 * Expires: 2026-01-04
================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Create warehouse (X-SMALL for demo, auto-suspend after 60s)
CREATE WAREHOUSE IF NOT EXISTS SFE_DOC_QA_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'DEMO: Document Rodeo Q&A | Author: SE Community | Expires: 2026-01-04';

-- Verify
SHOW WAREHOUSES LIKE 'SFE_DOC_QA_WH';

