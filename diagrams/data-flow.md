# Data Flow - Document Rodeo

**Author:** SE Community  
**Last Updated:** 2025-12-05  
**Expires:** 2026-01-04 (30 days)  
**Status:** Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

> **Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview

This diagram shows how document data flows through the Document Rodeo application - from user upload through text extraction to question answering. All processing happens within Snowflake using native Cortex AI functions.

```mermaid
flowchart TB
    subgraph User["User Interaction"]
        U1[/"Upload Document<br/>(PDF, TXT, DOCX)"/]
        U2[/"Enter Question"/]
        U3[/"View Answer"/]
    end

    subgraph SiS["Streamlit in Snowflake"]
        S1["st.file_uploader<br/>Accept file upload"]
        S2["Write to Stage<br/>session.file.put_stream()"]
        S3["Insert Metadata<br/>session.sql()"]
        S4["st.text_input<br/>Capture question"]
        S5["st.markdown<br/>Display answer"]
    end

    subgraph Cortex["Snowflake Cortex AI"]
        C1["PARSE_DOCUMENT<br/>Extract text from document"]
        C2["COMPLETE<br/>llama3.1-70b<br/>Generate answer"]
    end

    subgraph Storage["Snowflake Storage"]
        ST1[("@DOC_QA_STAGE<br/>Internal Stage")]
        ST2[("UPLOADS<br/>Metadata Table")]
    end

    U1 --> S1
    S1 --> S2
    S2 --> ST1
    S1 --> S3
    S3 --> ST2
    
    U2 --> S4
    S4 --> C1
    ST1 --> C1
    C1 --> C2
    C2 --> S5
    S5 --> U3

    style Cortex fill:#29B5E8,color:#fff
    style Storage fill:#1a1a2e,color:#fff
```

## Component Descriptions

### User Interaction Layer
- **Purpose:** Provide interface for document upload and Q&A
- **Technology:** Streamlit widgets
- **Location:** `streamlit/streamlit_app.py`
- **Dependencies:** Streamlit in Snowflake

### Streamlit Application
- **Purpose:** Orchestrate upload, parsing, and Q&A workflow
- **Technology:** Streamlit in Snowflake (Python)
- **Location:** `SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_APP`
- **Dependencies:** Snowpark session, Cortex functions

### Cortex AI Functions
- **Purpose:** Text extraction and LLM-based Q&A
- **Technology:** SNOWFLAKE.CORTEX.PARSE_DOCUMENT, SNOWFLAKE.CORTEX.COMPLETE
- **Location:** Built-in Snowflake functions
- **Dependencies:** Cortex access, warehouse compute

### Storage Layer
- **Purpose:** Persist documents and metadata
- **Technology:** Internal Stage + Table
- **Location:** `SNOWFLAKE_EXAMPLE.DOC_QA`
- **Dependencies:** Schema must exist

## Data Flow Steps

| Step | Action | Input | Output |
|------|--------|-------|--------|
| 1 | Upload file | User file selection | File bytes |
| 2 | Stage file | File bytes | Staged document |
| 3 | Record metadata | Filename, size, type | UPLOADS row |
| 4 | Parse document | Stage path | Extracted text |
| 5 | Generate answer | Question + text | LLM response |
| 6 | Display answer | LLM response | Formatted markdown |

## Change History

See `.cursor/DIAGRAM_CHANGELOG.md` for version history.

