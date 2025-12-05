# Cleanup Guide

**Author:** SE Community  
**Last Updated:** 2025-12-05  
**Expires:** 2026-01-04

## Quick Cleanup (Recommended)

Run [`teardown_all.sql`](../teardown_all.sql) in Snowsight:

1. Open the file in Snowsight
2. Click **Run All**
3. All demo objects are removed

## What Gets Removed

| Object | Full Name | 
|--------|-----------|
| Streamlit App | `SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP` |
| Stage (+ files) | `@SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE` |
| Table | `SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS` |
| Schema | `SNOWFLAKE_EXAMPLE.DOC_QA` |
| Warehouse | `SFE_DOC_QA_WH` |

## What Is NOT Removed

These shared resources are preserved:
- `SNOWFLAKE_EXAMPLE` database (may be used by other demos)
- Any API integrations created for Git access

## Manual Cleanup

If you prefer to run commands individually:

```sql
-- 1. Drop the Streamlit app first
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;

-- 2. Remove all staged files
REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';

-- 3. Drop the stage
DROP STAGE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE;

-- 4. Drop the table
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS;

-- 5. Drop the schema (cascades remaining objects)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;

-- 6. Drop the warehouse
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;
```

## Partial Cleanup

### Clear Documents Only (Keep App)

```sql
-- Remove uploaded files but keep the app running
REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';
TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS;
```

### Stop Warehouse (Reduce Costs)

```sql
-- Suspend warehouse when not in use
ALTER WAREHOUSE SFE_DOC_QA_WH SUSPEND;

-- Resume when needed
ALTER WAREHOUSE SFE_DOC_QA_WH RESUME;
```

## Verification

Confirm cleanup was successful:

```sql
-- Should return no rows
SHOW SCHEMAS LIKE 'DOC_QA' IN DATABASE SNOWFLAKE_EXAMPLE;
SHOW WAREHOUSES LIKE 'SFE_DOC_QA_WH';
```

## Re-Deployment

To redeploy after cleanup, simply run `deploy_all.sql` again. The script is idempotent (safe to re-run).

## Expiration Note

This demo expires on **2026-01-04**. After expiration:
- The `deploy_all.sql` script will refuse to run
- This repository will be archived
- For an updated version, contact the SE team

