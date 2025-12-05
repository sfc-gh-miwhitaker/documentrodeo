# Deployment Guide

**Author:** SE Community  
**Last Updated:** 2025-12-05  
**Expires:** 2026-01-04

## Prerequisites

- Snowflake account with ACCOUNTADMIN role (or role with CREATE DATABASE, WAREHOUSE privileges)
- Access to Cortex AI functions (CORTEX_USER role)

## Primary Deployment Method (Recommended)

**Copy/paste into Snowsight - that's it!**

1. Open [`deploy_all.sql`](../deploy_all.sql) in this repository
2. Copy the entire script
3. Open Snowsight → **+ (New)** → **SQL Worksheet**
4. Paste the script
5. Click **Run All** (or Ctrl/Cmd + Shift + Enter)
6. Wait ~1-2 minutes for deployment to complete

### What Gets Created

| Object | Full Name | Purpose |
|--------|-----------|---------|
| Warehouse | `SFE_DOC_QA_WH` | Query execution (X-SMALL) |
| Schema | `SNOWFLAKE_EXAMPLE.DOC_QA` | Project namespace |
| Stage | `@DOC_QA_STAGE` | Document storage |
| Table | `UPLOADS` | Upload metadata |
| Streamlit | `DOC_QA_APP` | The application |

## Alternative: Snow CLI Deployment

If you have Snow CLI installed:

```bash
# Clone the repository
git clone https://github.com/sfc-gh-miwhitaker/documentrodeo.git
cd documentrodeo

# Set environment variables (see config/env.example)
export SNOWFLAKE_ACCOUNT=your_account
export SNOWFLAKE_USER=your_user
# ... other vars

# Deploy using Snow CLI
snow sql -f deploy_all.sql
```

## Verification

After deployment, verify objects were created:

```sql
-- Check schema
SHOW SCHEMAS LIKE 'DOC_QA' IN DATABASE SNOWFLAKE_EXAMPLE;

-- Check stage
SHOW STAGES IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

-- Check table
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;

-- Check Streamlit app
SHOW STREAMLITS IN SCHEMA SNOWFLAKE_EXAMPLE.DOC_QA;
```

## Accessing the App

1. In Snowsight, navigate to **Projects → Streamlit**
2. Find and click **DOC_QA_APP**
3. The app will open in a new tab

## Troubleshooting

### "Insufficient privileges"
- Ensure you're running as ACCOUNTADMIN or a role with appropriate grants
- Verify CORTEX_USER role is available: `SHOW GRANTS TO USER <your_user>;`

### "Database SNOWFLAKE_EXAMPLE does not exist"
- The deploy script will create it if it doesn't exist
- If using a different database, modify `deploy_all.sql`

### "Warehouse does not exist"
- The deploy script creates `SFE_DOC_QA_WH`
- Ensure CREATE WAREHOUSE privilege is available

### Streamlit app shows error
- Check that QUERY_WAREHOUSE is set correctly
- Verify the stage and table exist
- Check Streamlit logs in Snowsight

## Expected Deployment Time

| Phase | Duration |
|-------|----------|
| Create warehouse | ~5 seconds |
| Create schema/stage/table | ~5 seconds |
| Deploy Streamlit | ~30-60 seconds |
| **Total** | **~1-2 minutes** |

