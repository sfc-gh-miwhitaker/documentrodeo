/*
================================================================================
 * Script: 01_create_streamlit.sql
 * Purpose: Create Streamlit application for Document Rodeo
 * Author: SE Community
 * Expires: 2026-01-04
 * 
 * Prerequisites:
 * - Git API integration must exist
 * - Git repository must be created and fetched
 * - Warehouse must exist
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DOC_QA;

-- Create Git API integration (for public GitHub repos)
CREATE API INTEGRATION IF NOT EXISTS SFE_DOC_QA_GIT_API_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Git API for Document Rodeo | Author: SE Community | Expires: 2026-01-04';

-- Create Git repository reference
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO
    API_INTEGRATION = SFE_DOC_QA_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/documentrodeo'
    COMMENT = 'DEMO: Document Rodeo source | Author: SE Community | Expires: 2026-01-04';

-- Fetch latest from Git
ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO FETCH;

-- Create Streamlit app from Git repository
CREATE OR REPLACE STREAMLIT SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_DOC_QA_WH
    TITLE = 'Document Rodeo - Q&A'
    COMMENT = 'DEMO: Minimal Doc Q&A with Cortex AI | Author: SE Community | Expires: 2026-01-04';

-- Verify
SHOW STREAMLITS LIKE 'DOC_QA_APP';

