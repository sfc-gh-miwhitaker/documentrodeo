/*
================================================================================
 * Script: 02_create_stage.sql
 * Purpose: Create internal stage for document uploads
 * Author: SE Community
 * Expires: 2026-01-04
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DOC_QA;

-- Internal stage for document storage
CREATE STAGE IF NOT EXISTS DOC_QA_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'DEMO: Document storage for Q&A | Author: SE Community | Expires: 2026-01-04';

-- Verify
SHOW STAGES LIKE 'DOC_QA_STAGE';

