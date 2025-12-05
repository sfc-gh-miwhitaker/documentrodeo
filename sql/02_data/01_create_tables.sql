/*
================================================================================
 * Script: 01_create_tables.sql
 * Purpose: Create tables for Document Rodeo
 * Author: SE Community
 * Expires: 2026-01-04
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA DOC_QA;
USE WAREHOUSE SFE_DOC_QA_WH;

-- Uploads metadata table
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

-- Verify
DESCRIBE TABLE UPLOADS;

