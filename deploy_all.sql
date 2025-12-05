/*
================================================================================
 * PROJECT: Document Rodeo
 * AUTHOR: SE Community
 * CREATED: 2025-12-05
 * EXPIRES: 2026-01-04
 * PURPOSE: Minimal document Q&A using Streamlit in Snowflake with Cortex AI
 * LAST_UPDATED: 2025-12-05
 * GITHUB_REPO: https://github.com/sfc-gh-miwhitaker/documentrodeo
================================================================================

DEPLOYMENT INSTRUCTIONS:
------------------------
1. Open this file in Snowsight
2. Select role: ACCOUNTADMIN (or role with CREATE privileges)
3. Click "Run All" (Ctrl/Cmd + Shift + Enter)
4. Wait ~2 minutes for completion
5. Navigate to Projects → Streamlit → DOC_QA_APP

WHAT THIS CREATES:
- Warehouse: SFE_DOC_QA_WH (X-SMALL, auto-suspend 60s)
- Schema: SNOWFLAKE_EXAMPLE.DOC_QA
- Stage: DOC_QA_STAGE (internal, for document uploads)
- Table: UPLOADS (document metadata)
- Git Repo: SFE_DOC_QA_REPO (for Streamlit source)
- Streamlit: DOC_QA_APP

================================================================================
*/

-- ============================================================================
-- EXPIRATION CHECK (Halt deployment if demo expired)
-- ============================================================================
EXECUTE IMMEDIATE
$$
DECLARE
    v_expiration_date DATE := '2026-01-04';
    demo_expired EXCEPTION (-20001, 'DEMO EXPIRED: This project expired on 2026-01-04. Please contact the SE team for an updated version.');
BEGIN
    IF (CURRENT_DATE() > v_expiration_date) THEN
        RAISE demo_expired;
    END IF;
    RETURN 'Demo is active. Expiration: ' || v_expiration_date::STRING;
END;
$$;

-- ============================================================================
-- ROLE CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS SFE_DOC_QA_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'DEMO: Document Rodeo Q&A | Author: SE Community | Expires: 2026-01-04';

USE WAREHOUSE SFE_DOC_QA_WH;

-- ============================================================================
-- DATABASE & SCHEMA
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Shared database for SE demo projects';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.DOC_QA
    COMMENT = 'DEMO: Document Rodeo - Minimal Doc Q&A | Author: SE Community | Expires: 2026-01-04';

USE SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

-- ============================================================================
-- INTERNAL STAGE (for document uploads)
-- ============================================================================
CREATE STAGE IF NOT EXISTS DOC_QA_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'DEMO: Document storage for Q&A | Author: SE Community | Expires: 2026-01-04';

-- ============================================================================
-- UPLOADS TABLE (metadata tracking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS UPLOADS (
    upload_id INT AUTOINCREMENT PRIMARY KEY,
    filename VARCHAR(500) NOT NULL,
    stage_path VARCHAR(1000) NOT NULL,
    file_size_bytes INT,
    file_type VARCHAR(20),
    uploaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    uploaded_by VARCHAR(500) DEFAULT CURRENT_USER(),
    status VARCHAR(20) DEFAULT 'active'
)
COMMENT = 'DEMO: Document upload metadata | Author: SE Community | Expires: 2026-01-04';

-- ============================================================================
-- GIT INTEGRATION (for Streamlit source code)
-- ============================================================================
-- Create API integration for GitHub (public repos - no auth needed)
CREATE API INTEGRATION IF NOT EXISTS SFE_DOC_QA_GIT_API_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Git API for Document Rodeo | Author: SE Community | Expires: 2026-01-04';

-- Create schema for Git repos (if not exists)
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS
    COMMENT = 'DEMO: Git repository storage | Author: SE Community';

-- Create Git repository reference
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO
    API_INTEGRATION = SFE_DOC_QA_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/documentrodeo'
    COMMENT = 'DEMO: Document Rodeo source | Author: SE Community | Expires: 2026-01-04';

-- Fetch latest from Git
ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO FETCH;

-- ============================================================================
-- STREAMLIT APPLICATION
-- ============================================================================
CREATE OR REPLACE STREAMLIT SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_DOC_QA_REPO/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_DOC_QA_WH
    TITLE = 'Document Rodeo - Q&A'
    COMMENT = 'DEMO: Minimal Doc Q&A with Cortex AI | Author: SE Community | Expires: 2026-01-04';

-- ============================================================================
-- GRANT ACCESS (for other roles to use the app)
-- ============================================================================
-- Uncomment and modify to grant access to other roles:
-- GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE <your_role>;
-- GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA TO ROLE <your_role>;
-- GRANT USAGE ON WAREHOUSE SFE_DOC_QA_WH TO ROLE <your_role>;
-- GRANT USAGE ON STREAMLIT SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP TO ROLE <your_role>;
-- GRANT READ, WRITE ON STAGE SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE TO ROLE <your_role>;
-- GRANT SELECT, INSERT ON TABLE SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS TO ROLE <your_role>;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW WAREHOUSES LIKE 'SFE_DOC_QA_WH';
SHOW SCHEMAS LIKE 'DOC_QA' IN DATABASE SNOWFLAKE_EXAMPLE;
SHOW STAGES IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;
SHOW STREAMLITS IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

SELECT '✅ Deployment complete! Navigate to Projects → Streamlit → DOC_QA_APP' AS STATUS;

