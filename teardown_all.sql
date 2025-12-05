/*
================================================================================
 * PROJECT: Document Rodeo - CLEANUP
 * AUTHOR: SE Community
================================================================================
*/

USE ROLE ACCOUNTADMIN;

DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO;
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;

SELECT '✅ Cleanup complete' AS STATUS;
