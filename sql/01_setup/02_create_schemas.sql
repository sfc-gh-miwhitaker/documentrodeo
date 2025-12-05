/*
================================================================================
 * Script: 02_create_schemas.sql
 * Purpose: Create project schema for Document Rodeo
 * Author: SE Community
 * Expires: 2026-01-04
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;

-- Create project schema
CREATE SCHEMA IF NOT EXISTS DOC_QA
    COMMENT = 'DEMO: Document Rodeo - Minimal Doc Q&A | Author: SE Community | Expires: 2026-01-04';

-- Create Git repos schema (shared infrastructure)
CREATE SCHEMA IF NOT EXISTS GIT_REPOS
    COMMENT = 'DEMO: Git repository storage | Author: SE Community';

-- Verify
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE;

