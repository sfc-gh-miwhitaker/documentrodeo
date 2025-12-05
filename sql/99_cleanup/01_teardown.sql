/*
================================================================================
 * Script: 01_teardown.sql
 * Purpose: Remove all Document Rodeo objects
 * Author: SE Community
 * 
 * Note: This is the modular cleanup script. For one-click cleanup,
 *       use teardown_all.sql in the project root.
================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Drop Streamlit app first (depends on other objects)
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;

-- Remove all staged files
REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';

-- Drop stage
DROP STAGE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE;

-- Drop table
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS;

-- Drop schema (cascades any remaining objects)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;

-- Drop Git repository
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO;

-- Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;

-- Verification
SELECT 'Cleanup complete' AS STATUS;

