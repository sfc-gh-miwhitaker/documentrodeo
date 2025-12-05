"""
Document Rodeo - Minimal Document Q&A
=====================================
A simple Streamlit in Snowflake app that answers questions about uploaded documents
using Cortex AI functions (PARSE_DOCUMENT + COMPLETE).

Author: SE Community
Expires: 2026-01-04
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import tempfile
import os
import json

# =============================================================================
# Page Configuration
# =============================================================================
st.set_page_config(
    page_title="Document Rodeo",
    page_icon="📄",
    layout="wide"
)

# =============================================================================
# Session & Constants
# =============================================================================
session = get_active_session()

STAGE_NAME = "@SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE"
UPLOADS_TABLE = "SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS"
SUPPORTED_TYPES = ["pdf", "txt", "docx"]
MAX_CONTEXT_CHARS = 30000  # Limit context to fit in LLM window


# =============================================================================
# Helper Functions
# =============================================================================
def upload_to_stage(uploaded_file):
    """Upload file to Snowflake stage and record metadata."""
    filename = uploaded_file.name
    file_type = filename.split(".")[-1].lower()
    file_size = uploaded_file.size

    # Write to temp file, then upload to stage
    with tempfile.NamedTemporaryFile(delete=False, suffix=f".{file_type}") as tmp:
        tmp.write(uploaded_file.getvalue())
        tmp_path = tmp.name

    try:
        # Upload to stage
        put_result = session.file.put(
            tmp_path,
            STAGE_NAME,
            auto_compress=False,
            overwrite=True
        )

        # Record metadata
        stage_path = f"{STAGE_NAME}/{filename}"
        session.sql(f"""
            INSERT INTO {UPLOADS_TABLE} (filename, stage_path, file_size_bytes, file_type)
            VALUES ('{filename}', '{stage_path}', {file_size}, '{file_type}')
        """).collect()

        return filename, stage_path
    finally:
        # Cleanup temp file
        os.unlink(tmp_path)


def parse_document(filename):
    """Extract text from document using Cortex PARSE_DOCUMENT."""
    # Use PARSE_DOCUMENT to extract text (OCR mode is default)
    query = f"""
        SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '{STAGE_NAME}',
            '{filename}',
            {{'mode': 'OCR'}}
        ) AS parsed_content
    """
    result = session.sql(query).collect()

    if result and len(result) > 0:
        parsed_json = result[0]["PARSED_CONTENT"]
        # PARSE_DOCUMENT returns JSON with 'content' key
        try:
            parsed = json.loads(parsed_json)
            if isinstance(parsed, dict) and "content" in parsed:
                return parsed["content"]
            elif isinstance(parsed, str):
                return parsed
            else:
                return str(parsed)
        except (json.JSONDecodeError, TypeError):
            return str(parsed_json)
    return ""


def answer_question(question, document_text):
    """Use Cortex COMPLETE to answer question based on document."""
    # Truncate context if too long
    context = document_text[:MAX_CONTEXT_CHARS]

    # Build prompt
    prompt = f"""You are a helpful assistant that answers questions based on the provided document.
Answer the question based ONLY on the information in the document below.
If the answer is not in the document, say "I cannot find this information in the document."

DOCUMENT:
{context}

QUESTION: {question}

ANSWER:"""

    # Escape single quotes for SQL
    safe_prompt = prompt.replace("'", "''")

    query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'llama3.1-70b',
            '{safe_prompt}'
        ) AS answer
    """
    result = session.sql(query).collect()

    if result and len(result) > 0:
        return result[0]["ANSWER"]
    return "Unable to generate an answer."


def get_recent_uploads():
    """Get list of recent uploads."""
    query = f"""
        SELECT filename, file_type, file_size_bytes, uploaded_at
        FROM {UPLOADS_TABLE}
        WHERE status = 'active'
        ORDER BY uploaded_at DESC
        LIMIT 10
    """
    return session.sql(query).to_pandas()


# =============================================================================
# UI Layout
# =============================================================================

# Header
st.title("📄 Document Rodeo")
st.markdown("*Upload a document and ask questions about it*")
st.markdown("---")

# Sidebar for upload
with st.sidebar:
    st.header("📤 Upload Document")

    uploaded_file = st.file_uploader(
        "Choose a file",
        type=SUPPORTED_TYPES,
        help="Supported formats: PDF, TXT, DOCX (max 200MB)"
    )

    if uploaded_file:
        if st.button("📥 Upload to Snowflake", type="primary"):
            with st.spinner("Uploading..."):
                try:
                    filename, stage_path = upload_to_stage(uploaded_file)
                    st.session_state["current_file"] = filename
                    st.session_state["document_text"] = None  # Reset parsed text
                    st.success(f"✅ Uploaded: {filename}")
                except Exception as e:
                    st.error(f"Upload failed: {str(e)}")

    st.markdown("---")
    st.header("📁 Recent Uploads")

    try:
        uploads_df = get_recent_uploads()
        if not uploads_df.empty:
            for _, row in uploads_df.iterrows():
                col1, col2 = st.columns([3, 1])
                with col1:
                    if st.button(f"📄 {row['FILENAME']}", key=row['FILENAME']):
                        st.session_state["current_file"] = row['FILENAME']
                        st.session_state["document_text"] = None
                with col2:
                    st.caption(f"{row['FILE_TYPE'].upper()}")
        else:
            st.info("No documents uploaded yet")
    except Exception:
        st.info("Upload a document to get started")


# Main area
col1, col2 = st.columns([1, 1])

with col1:
    st.header("📖 Document")

    current_file = st.session_state.get("current_file")

    if current_file:
        st.info(f"**Current document:** {current_file}")

        # Parse document button
        if st.button("🔍 Extract Text", type="secondary"):
            with st.spinner("Parsing document with Cortex AI..."):
                try:
                    text = parse_document(current_file)
                    st.session_state["document_text"] = text
                    st.success("✅ Text extracted!")
                except Exception as e:
                    st.error(f"Parse failed: {str(e)}")

        # Show extracted text preview
        doc_text = st.session_state.get("document_text")
        if doc_text:
            with st.expander("📝 Document Preview", expanded=False):
                st.text_area(
                    "Extracted text (first 5000 chars)",
                    value=doc_text[:5000] + ("..." if len(doc_text) > 5000 else ""),
                    height=300,
                    disabled=True
                )
            st.caption(f"Total characters: {len(doc_text):,}")
    else:
        st.info("👈 Upload a document or select from recent uploads")


with col2:
    st.header("❓ Ask a Question")

    doc_text = st.session_state.get("document_text")

    if doc_text:
        question = st.text_input(
            "Your question",
            placeholder="What is this document about?"
        )

        if st.button("🚀 Get Answer", type="primary", disabled=not question):
            with st.spinner("Thinking with Cortex AI..."):
                try:
                    answer = answer_question(question, doc_text)
                    st.session_state["last_answer"] = answer
                    st.session_state["last_question"] = question
                except Exception as e:
                    st.error(f"Error: {str(e)}")

        # Show answer
        if st.session_state.get("last_answer"):
            st.markdown("### Answer")
            st.markdown(st.session_state["last_answer"])

            st.markdown("---")
            st.caption(f"Question: *{st.session_state.get('last_question', '')}*")
    else:
        st.info("⬅️ First extract text from your document, then ask questions")


# Footer
st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #666; font-size: 0.8em;">
    <p>Powered by <strong>Snowflake Cortex AI</strong></p>
    <p>PARSE_DOCUMENT (text extraction) • COMPLETE (llama3.1-70b)</p>
    <p>Demo expires: 2026-01-04 | Author: SE Community</p>
</div>
""", unsafe_allow_html=True)

