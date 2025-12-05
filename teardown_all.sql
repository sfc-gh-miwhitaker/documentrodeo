/*
================================================================================
 * PROJECT: Document Rodeo - CLEANUP
 * AUTHOR: SE Community
================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Drop Streamlit first
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;

-- Clear and drop stage
REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';
DROP STAGE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE;

-- Drop schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;

-- Drop Git repo
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO;

-- Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;

SELECT '✅ Cleanup complete' AS STATUS;
