# Usage Guide

**Author:** SE Community  
**Last Updated:** 2025-12-05  
**Expires:** 2026-01-04

## Opening the App

1. Log in to Snowsight
2. Navigate to **Projects → Streamlit**
3. Click **DOC_QA_APP**

## Uploading a Document

1. Click **Browse files** or drag and drop a file
2. Supported formats:
   - PDF (.pdf) - text and scanned documents
   - Text (.txt) - plain text files
   - Word (.docx) - Microsoft Word documents
3. Maximum file size: 200 MB
4. Wait for upload confirmation

### Upload Tips

- For best results, use text-based PDFs (not scanned images)
- Smaller documents process faster
- One document at a time is recommended for this demo

## Asking Questions

1. After upload, enter your question in the text box
2. Examples:
   - "What is the main topic of this document?"
   - "Summarize the key points"
   - "What dates are mentioned?"
   - "List all the people named in this document"
3. Click **Ask** or press Enter
4. Wait for the answer (typically 5-15 seconds)

### Question Tips

- Be specific - "What is the revenue for Q3?" vs "Tell me about revenue"
- Ask one question at a time for best results
- The model uses the document text as context, so questions should relate to the content

## Understanding the Response

The app displays:
- **Document Info:** Filename, size, upload time
- **Extracted Text Preview:** First portion of parsed text
- **Answer:** LLM-generated response to your question
- **Processing Time:** How long each step took

## Supported Document Types

| Format | Extension | Notes |
|--------|-----------|-------|
| PDF | `.pdf` | Text-based and scanned (OCR) |
| Plain Text | `.txt` | UTF-8 encoded |
| Word | `.docx` | Microsoft Word 2007+ |

## Limitations

- **File size:** 200 MB maximum per upload
- **Context length:** Very long documents may be truncated
- **Languages:** Best results with English; other languages supported but quality may vary
- **Scanned PDFs:** OCR quality depends on scan quality

## Example Workflow

```
1. Upload: annual_report_2024.pdf (2.3 MB)
   → "Document uploaded successfully"

2. Question: "What was the total revenue for 2024?"
   → "According to the document, total revenue for 2024 
      was $4.2 billion, representing a 12% increase 
      from the previous year."

3. Question: "Who is the CEO mentioned in the report?"
   → "The CEO mentioned in the report is Jane Smith, 
      who has been leading the company since 2021."
```

## Clearing Documents

To remove uploaded documents:
1. Use the app's "Clear" button (if available)
2. Or run cleanup SQL:
   ```sql
   -- Remove all files from stage
   REMOVE @SNOWFLAKE_EXAMPLE.DOC_QA.DOC_QA_STAGE PATTERN='.*';
   
   -- Clear metadata table
   TRUNCATE TABLE SNOWFLAKE_EXAMPLE.DOC_QA.UPLOADS;
   ```

## Cost Awareness

Each operation uses Snowflake credits:
- **Upload:** Minimal (storage write)
- **Parse:** ~$0.01 per page (PARSE_DOCUMENT)
- **Question:** ~$0.01 per question (CORTEX.COMPLETE)

For a typical demo session (5 documents, 20 questions): **< $1.00**

