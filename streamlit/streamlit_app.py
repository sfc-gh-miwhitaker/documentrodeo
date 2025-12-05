"""
Document Rodeo - Minimal Document Q&A
=====================================
A simple Streamlit in Snowflake app that answers questions about uploaded documents
using Cortex AI (COMPLETE function).

Author: SE Community
Expires: 2026-01-04
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session

# Page Configuration
st.set_page_config(
    page_title="Document Rodeo",
    page_icon="📄",
    layout="wide"
)

# Session
session = get_active_session()

MAX_CONTEXT_CHARS = 30000


def extract_text_from_file(uploaded_file):
    """Extract text content from uploaded file."""
    file_type = uploaded_file.name.split(".")[-1].lower()
    
    if file_type == "txt":
        return uploaded_file.getvalue().decode("utf-8")
    elif file_type == "pdf":
        # For PDF, we'll use a simple extraction
        # Note: Full PDF parsing would require PyPDF2 which may not be available
        try:
            content = uploaded_file.getvalue()
            # Try to extract readable text from PDF bytes
            text = content.decode("latin-1", errors="ignore")
            # Filter to printable characters
            text = "".join(c if c.isprintable() or c.isspace() else " " for c in text)
            return text
        except Exception:
            return "[PDF parsing limited - upload TXT for best results]"
    else:
        return uploaded_file.getvalue().decode("utf-8", errors="ignore")


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


# UI Layout
st.title("📄 Document Rodeo")
st.markdown("*Upload a document and ask questions about it*")
st.markdown("---")

# Two columns
col1, col2 = st.columns([1, 1])

with col1:
    st.header("📤 Upload Document")
    
    uploaded_file = st.file_uploader(
        "Choose a file",
        type=["txt", "pdf"],
        help="Supported formats: TXT (best), PDF (basic)"
    )
    
    if uploaded_file:
        st.success(f"📄 **{uploaded_file.name}** ({uploaded_file.size:,} bytes)")
        
        if st.button("🔍 Extract Text", type="primary"):
            with st.spinner("Extracting text..."):
                text = extract_text_from_file(uploaded_file)
                st.session_state["document_text"] = text
                st.session_state["filename"] = uploaded_file.name
                st.success(f"✅ Extracted {len(text):,} characters")
        
        # Show preview
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
        st.info("⬅️ Upload a document and extract text first")

# Footer
st.markdown("---")
st.caption("Powered by **Snowflake Cortex AI** (llama3.1-70b) | Demo expires: 2026-01-04")
