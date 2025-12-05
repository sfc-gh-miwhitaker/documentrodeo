![Reference Implementation](https://img.shields.io/badge/Reference-Implementation-blue)
![Ready to Run](https://img.shields.io/badge/Ready%20to%20Run-Yes-green)
![Expires](https://img.shields.io/badge/Expires-2026--01--04-orange)
![Snowflake Native](https://img.shields.io/badge/Snowflake-Native-29B5E8?logo=snowflake)

# Document Rodeo

> **DEMONSTRATION PROJECT** - EXPIRES: 2026-01-04  
> This demo uses Snowflake Cortex AI features current as of December 2025.  
> After expiration, this repository will be archived and made private.

**Author:** SE Community  
**Purpose:** Minimal document Q&A using Streamlit in Snowflake with Cortex AI  
**Created:** 2025-12-05 | **Expires:** 2026-01-04 (30 days) | **Status:** ACTIVE

---

## What This Demo Shows

Upload a PDF, TXT, or DOCX document, then ask questions about it - all within a single Streamlit in Snowflake app. **100% Snowflake native.**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    STREAMLIT IN SNOWFLAKE                           │
│                                                                     │
│   Upload Document  ───▶  Parse Text  ───▶  Ask Questions            │
│   (st.file_uploader)     (PARSE_DOCUMENT)   (CORTEX.COMPLETE)       │
└─────────────────────────────────────────────────────────────────────┘
```

### Cortex AI Features Used

| Feature | Purpose |
|---------|---------|
| `AI_PARSE_DOCUMENT` | Extract text from PDF/DOCX/TXT files |
| `SNOWFLAKE.CORTEX.COMPLETE` | Answer questions using LLM (llama3.1-70b) |

---

## 👋 First Time Here?

**One-step deployment - copy/paste into Snowsight:**

1. **Deploy to Snowflake (~2 min)**
   - Open [`deploy_all.sql`](deploy_all.sql) in Snowsight as ACCOUNTADMIN
   - Click **Run All**
   - Creates: warehouse, schema, stage, table, Streamlit app

2. **Open the App**
   - Navigate to **Projects → Streamlit** in Snowsight
   - Click **DOC_QA_APP**
   - Upload a document and ask questions!

**Total setup time: ~2 minutes**

---

## Project Structure

```
documentrodeo/
├── deploy_all.sql          # Single-run deployment (copy/paste to Snowsight)
├── teardown_all.sql        # Single-run cleanup
├── streamlit/
│   └── streamlit_app.py    # The Streamlit application
├── sql/
│   ├── 01_setup/           # Database, schema, warehouse
│   ├── 02_data/            # Tables and stage
│   ├── 05_streamlit/       # Streamlit deployment
│   └── 99_cleanup/         # Teardown scripts
├── diagrams/               # Architecture diagrams
└── docs/                   # Documentation
```

---

## How It Works

1. **Upload**: User uploads PDF/TXT/DOCX via Streamlit file uploader
2. **Stage**: File is uploaded to internal stage `@DOC_QA_STAGE`
3. **Parse**: `AI_PARSE_DOCUMENT` extracts text (OCR for scanned PDFs)
4. **Question**: User enters a question about the document
5. **Answer**: `CORTEX.COMPLETE` generates answer using document text as context

---

## Objects Created

| Object | Type | Purpose |
|--------|------|---------|
| `SFE_DOC_QA_WH` | Warehouse (X-SMALL) | Query execution |
| `SNOWFLAKE_EXAMPLE.DOC_QA` | Schema | Project namespace |
| `DOC_QA_STAGE` | Internal Stage | Document storage |
| `DOC_QA_APP` | Streamlit | The application |

---

## Cleanup

**Preferred:** Run [`teardown_all.sql`](teardown_all.sql) in Snowsight (Run All)

**Manual:**
```sql
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.DOC_QA CASCADE;
DROP WAREHOUSE IF EXISTS SFE_DOC_QA_WH;
```

---

## Estimated Demo Costs

| Resource | Size/Type | Est. Cost | Notes |
|----------|-----------|-----------|-------|
| Warehouse | X-SMALL | ~$0.08/5min | Only runs during queries |
| AI_PARSE_DOCUMENT | Per-page | ~$0.01/page | OCR text extraction |
| CORTEX.COMPLETE | Per-call | ~$0.01/call | LLM inference |
| **Total Demo** | ~5 min | **< $0.50** | Minimal usage |

**Edition:** Standard ($2/credit) - No enterprise features required

---

## Documentation

- [`docs/01-DEPLOYMENT.md`](docs/01-DEPLOYMENT.md) - Deployment guide
- [`docs/02-USAGE.md`](docs/02-USAGE.md) - How to use the app
- [`docs/03-CLEANUP.md`](docs/03-CLEANUP.md) - Cleanup instructions

---

*Reference Implementation: Review and customize security, networking, and logic for your organization's specific requirements before production use.*

