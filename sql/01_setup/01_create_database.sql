/*
================================================================================
 * Script: 01_create_database.sql
 * Purpose: Create shared database for SE demo projects
 * Author: SE Community
 * Expires: 2026-01-04
 * 
 * Note: This script creates the shared SNOWFLAKE_EXAMPLE database.
 *       It is safe to run if the database already exists.
================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Create shared database (if not exists)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Shared database for SE demo projects';

-- Verify
SHOW DATABASES LIKE 'SNOWFLAKE_EXAMPLE';

