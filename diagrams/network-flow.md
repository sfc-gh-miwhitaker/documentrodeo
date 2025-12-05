# Network Flow - Document Rodeo

**Author:** SE Community  
**Last Updated:** 2025-12-05  
**Expires:** 2026-01-04 (30 days)  
**Status:** Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

> **Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview

This diagram shows the network architecture for Document Rodeo. Being 100% Snowflake-native, all traffic stays within the Snowflake platform boundary. Users access the Streamlit app via Snowsight - no external services or network egress required.

```mermaid
flowchart TB
    subgraph External["External Network"]
        User["End User<br/>Browser"]
    end

    subgraph Snowflake["Snowflake Platform"]
        subgraph Snowsight["Snowsight UI"]
            SS["Snowsight<br/>account.snowflakecomputing.com<br/>:443 HTTPS"]
        end
        
        subgraph Compute["Compute Layer"]
            WH["SFE_DOC_QA_WH<br/>X-SMALL Warehouse"]
            SIS["Streamlit Runtime<br/>DOC_QA_APP"]
        end
        
        subgraph Cortex["Cortex AI Services"]
            PARSE["PARSE_DOCUMENT<br/>Document Processing"]
            LLM["COMPLETE<br/>LLM Inference<br/>(llama3.1-70b)"]
        end
        
        subgraph Storage["Storage Layer"]
            STAGE["@DOC_QA_STAGE<br/>Internal Stage"]
            TABLE["UPLOADS Table"]
        end
    end

    User -->|"HTTPS :443"| SS
    SS -->|"Session"| SIS
    SIS -->|"SQL Queries"| WH
    WH -->|"Read/Write"| STAGE
    WH -->|"Read/Write"| TABLE
    WH -->|"Function Call"| PARSE
    WH -->|"Function Call"| LLM
    PARSE -->|"Read"| STAGE

    style Snowflake fill:#f0f8ff,stroke:#29B5E8
    style Cortex fill:#29B5E8,color:#fff
    style Storage fill:#1a1a2e,color:#fff
```

## Component Descriptions

### External Access
- **Purpose:** User access to Snowflake
- **Technology:** HTTPS/TLS 1.2+
- **Location:** `<account>.snowflakecomputing.com`
- **Dependencies:** Valid Snowflake credentials

### Snowsight UI
- **Purpose:** Web interface for Snowflake
- **Technology:** Snowflake web application
- **Location:** Port 443 (HTTPS)
- **Dependencies:** Browser, network access

### Compute Layer
- **Purpose:** Execute queries and run Streamlit
- **Technology:** Virtual Warehouse, Streamlit Runtime
- **Location:** `SFE_DOC_QA_WH`, `DOC_QA_APP`
- **Dependencies:** Warehouse credits

### Cortex AI Services
- **Purpose:** Document parsing and LLM inference
- **Technology:** Managed Snowflake services
- **Location:** Internal to Snowflake platform
- **Dependencies:** Cortex access (CORTEX_USER role)

### Storage Layer
- **Purpose:** Persist documents and metadata
- **Technology:** Snowflake storage
- **Location:** `SNOWFLAKE_EXAMPLE.DOC_QA`
- **Dependencies:** Storage allocation

## Network Security

| Aspect | Implementation |
|--------|----------------|
| **Encryption in Transit** | TLS 1.2+ (Snowflake managed) |
| **Encryption at Rest** | AES-256 (Snowflake managed) |
| **Authentication** | Snowflake native (username/password, SSO, MFA) |
| **Authorization** | RBAC via Snowflake roles |
| **Network Egress** | None required (fully internal) |
| **External Access** | Not required |

## Key Points

- **Zero network egress:** All processing stays within Snowflake
- **No external integrations:** No API keys, webhooks, or external services
- **Single entry point:** Users access only via Snowsight
- **Managed security:** TLS, encryption, auth all handled by Snowflake

## Change History

See `.cursor/DIAGRAM_CHANGELOG.md` for version history.

