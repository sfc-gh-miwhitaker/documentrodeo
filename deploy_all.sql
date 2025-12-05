/*
================================================================================
 * PROJECT: Document Rodeo
 * AUTHOR: SE Community
 * CREATED: 2025-12-05
 * EXPIRES: 2026-01-04
 * PURPOSE: Minimal document Q&A using Streamlit in Snowflake with Cortex AI
 * GITHUB_REPO: https://github.com/sfc-gh-miwhitaker/documentrodeo
================================================================================

DEPLOYMENT INSTRUCTIONS:
------------------------
1. Open this file in Snowsight
2. Select role: ACCOUNTADMIN
3. Click "Run All" (Ctrl/Cmd + Shift + Enter)
4. Navigate to Projects → Streamlit → DOC_QA_APP

WHAT THIS CREATES:
- Warehouse: SFE_DOC_QA_WH (X-SMALL)
- Schema: SNOWFLAKE_EXAMPLE.DOC_QA
- Stage: DOC_QA_STAGE (for document uploads)
- Git Repo: SFE_DOC_QA_REPO
- Streamlit: DOC_QA_APP

================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS SFE_DOC_QA_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'DEMO: Document Rodeo | Author: SE Community | Expires: 2026-01-04';

USE WAREHOUSE SFE_DOC_QA_WH;

-- ============================================================================
-- DATABASE & SCHEMA
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'Shared database for SE demo projects';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.DOC_QA
    COMMENT = 'DEMO: Document Rodeo | Author: SE Community | Expires: 2026-01-04';

USE SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

-- ============================================================================
-- STAGE (for document uploads)
-- ============================================================================
CREATE STAGE IF NOT EXISTS DOC_QA_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'DEMO: Document storage for AI parsing | Author: SE Community | Expires: 2026-01-04';

-- ============================================================================
-- GIT INTEGRATION
-- ============================================================================
CREATE API INTEGRATION IF NOT EXISTS SFE_DOC_QA_GIT_API_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Document Rodeo Git | Author: SE Community | Expires: 2026-01-04';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS
    COMMENT = 'Git repository storage';

CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO
    API_INTEGRATION = SFE_DOC_QA_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/documentrodeo'
    COMMENT = 'DEMO: Document Rodeo source | Author: SE Community | Expires: 2026-01-04';

ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO FETCH;

-- ============================================================================
-- STREAMLIT APPLICATION
-- ============================================================================
CREATE OR REPLACE STREAMLIT SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_DOC_QA_WH
    TITLE = 'Document Rodeo'
    COMMENT = 'DEMO: Doc Q&A with AI_PARSE_DOCUMENT | Author: SE Community | Expires: 2026-01-04';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW STAGES IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;
SHOW STREAMLITS LIKE 'DOC_QA_APP' IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

SELECT '✅ Deployment complete! Go to Projects → Streamlit → DOC_QA_APP' AS STATUS;
