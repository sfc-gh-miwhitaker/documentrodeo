/*
================================================================================
 * PROJECT: Document Rodeo - CLEANUP
 * AUTHOR: SE Community
 * PURPOSE: Remove all demo objects
================================================================================

CLEANUP INSTRUCTIONS:
---------------------
1. Open this file in Snowsight
2. Select role: ACCOUNTADMIN
3. Click "Run All"

WHAT THIS REMOVES:
- Streamlit: DOC_QA_APP
- Stage: DOC_QA_STAGE (and all uploaded files)
- Table: UPLOADS
- Schema: SNOWFLAKE_EXAMPLE.DOC_QA
- Git Repo: SFE_DOC_QA_REPO
- Warehouse: SFE_DOC_QA_WH

PRESERVED (shared resources):
- Database: SNOWFLAKE_EXAMPLE
- Schema: SNOWFLAKE_EXAMPLE.GIT_REPOS
- API Integration: SFE_DOC_QA_GIT_API_INTEGRATION

================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- DROP STREAMLIT APP
-- ============================================================================
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;

-- ============================================================================
-- REMOVE STAGED FILES
-- ============================================================================
REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';

-- ============================================================================
-- DROP STAGE
-- ============================================================================
DROP STAGE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE;

-- ============================================================================
-- DROP TABLE
-- ============================================================================
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS;

-- ============================================================================
-- DROP SCHEMA (cascades any remaining objects)
-- ============================================================================
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;

-- ============================================================================
-- DROP GIT REPOSITORY
-- ============================================================================
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO;

-- ============================================================================
-- DROP WAREHOUSE
-- ============================================================================
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW SCHEMAS LIKE 'DOC_QA' IN DATABASE SNOWFLAKE_EXAMPLE;
SHOW WAREHOUSES LIKE 'SFE_DOC_QA_WH';

SELECT '✅ Cleanup complete! All Document Rodeo objects have been removed.' AS STATUS;

