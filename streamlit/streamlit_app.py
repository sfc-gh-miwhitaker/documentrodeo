"""
Document Rodeo - Document Q&A with AI_PARSE_DOCUMENT
====================================================
Upload PDF/TXT/DOCX documents to a Snowflake stage, extract text with 
AI_PARSE_DOCUMENT, and answer questions using CORTEX.COMPLETE.

Author: SE Community
Expires: 2026-01-04
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import tempfile
import os
import time

# Page Configuration
st.set_page_config(
    page_title="Document Rodeo",
    page_icon="📄",
    layout="wide"
)

# Session & Constants
session = get_active_session()
STAGE_PATH = "@SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE"
MAX_CONTEXT_CHARS = 30000


def upload_to_stage(uploaded_file):
    """Upload file to Snowflake stage."""
    filename = uploaded_file.name
    # Add timestamp to avoid collisions
    ts = int(time.time())
    staged_name = f"{ts}_{filename}"
    
    # Write to temp file
    with tempfile.NamedTemporaryFile(delete=False, suffix=f"_{filename}") as tmp:
        tmp.write(uploaded_file.getvalue())
        tmp_path = tmp.name
    
    try:
        # Upload to stage
        session.file.put(
            tmp_path,
            STAGE_PATH,
            auto_compress=False,
            overwrite=True
        )
        # The file gets uploaded with the temp filename, extract just the name part
        staged_filename = os.path.basename(tmp_path)
        return staged_filename
    finally:
        os.unlink(tmp_path)


def parse_document(staged_filename):
    """Extract text from staged document using AI_PARSE_DOCUMENT."""
    query = f"""
        SELECT AI_PARSE_DOCUMENT(
            '{STAGE_PATH}',
            '{staged_filename}',
            {{'mode': 'OCR'}}
        ):content::STRING AS extracted_text
    """
    result = session.sql(query).collect()
    
    if result and len(result) > 0:
        return result[0]["EXTRACTED_TEXT"] or ""
    return ""


def answer_question(question, document_text):
    """Use Cortex COMPLETE to answer question based on document."""
    context = document_text[:MAX_CONTEXT_CHARS]
    
    prompt = f"""You are a helpful assistant that answers questions based on the provided document.
Answer the question based ONLY on the information in the document below.
If the answer is not in the document, say "I cannot find this information in the document."

DOCUMENT:
{context}

QUESTION: {question}

ANSWER:"""

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


# UI Layout
st.title("📄 Document Rodeo")
st.markdown("*Upload a document and ask questions about it*")
st.markdown("---")

col1, col2 = st.columns([1, 1])

with col1:
    st.header("📤 Upload Document")
    
    uploaded_file = st.file_uploader(
        "Choose a file",
        type=["pdf", "txt", "docx"],
        help="Supported: PDF, TXT, DOCX (max 200MB)"
    )
    
    if uploaded_file:
        st.success(f"📄 **{uploaded_file.name}** ({uploaded_file.size:,} bytes)")
        
        if st.button("🔍 Upload & Parse", type="primary"):
            with st.spinner("Uploading to stage..."):
                try:
                    staged_filename = upload_to_stage(uploaded_file)
                    st.session_state["staged_filename"] = staged_filename
                    st.info(f"Staged as: {staged_filename}")
                except Exception as e:
                    st.error(f"Upload failed: {str(e)}")
                    st.stop()
            
            with st.spinner("Parsing with AI_PARSE_DOCUMENT..."):
                try:
                    text = parse_document(staged_filename)
                    if text:
                        st.session_state["document_text"] = text
                        st.session_state["filename"] = uploaded_file.name
                        st.success(f"✅ Extracted {len(text):,} characters")
                    else:
                        st.warning("No text extracted - file may be empty or unsupported")
                except Exception as e:
                    st.error(f"Parse failed: {str(e)}")
        
        if st.session_state.get("document_text"):
            with st.expander("📝 Document Preview", expanded=False):
                preview = st.session_state["document_text"][:3000]
                st.text_area("Content", value=preview, height=200, disabled=True)

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
        
        if st.session_state.get("last_answer"):
            st.markdown("### Answer")
            st.markdown(st.session_state["last_answer"])
            st.markdown("---")
            st.caption(f"Q: *{st.session_state.get('last_question', '')}*")
    else:
        st.info("⬅️ Upload a document and parse it first")

# Footer
st.markdown("---")
st.caption("**Cortex AI:** AI_PARSE_DOCUMENT + COMPLETE (llama3.1-70b) | Expires: 2026-01-04")
