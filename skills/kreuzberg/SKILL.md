---
name: kreuzberg
description: Extract text and metadata from 50+ document formats using Kreuzberg (PDF, Office, images with OCR, archives, emails)
---

# Kreuzberg Document Extraction

Kreuzberg is a high-performance document intelligence library with a Rust core and bindings for Python, Node.js, Ruby, Go, Java, C#, PHP, and Elixir.

Use this skill when users need to:
- Extract text from PDFs, Office documents, images, emails, or archives
- Perform OCR on scanned documents or images
- Get structured metadata from documents
- Batch process multiple files
- Configure extraction options (output format, chunking, language detection)

## Installation

### Python
```bash
pip install kreuzberg
```

### Rust
```bash
cargo add kreuzberg
```

### Node.js
```bash
npm install @kreuzberg/node
```

### CLI
```bash
cargo install kreuzberg-cli
```

## Quick Start

### Python (Async)
```python
from kreuzberg import extract_file

result = await extract_file("document.pdf")
print(result.content)
print(result.metadata)
```

### Python (Sync)
```python
from kreuzberg import extract_file_sync

result = extract_file_sync("document.pdf")
print(result.content)
```

### Rust
```rust
use kreuzberg::extract_file;

let result = extract_file("document.pdf", None, None).await?;
println!("{}", result.content);
```

### Node.js
```javascript
const { extractFile } = require('@kreuzberg/node');

const result = await extractFile('document.pdf');
console.log(result.content);
```

### CLI
```bash
kreuzberg extract document.pdf
kreuzberg extract document.pdf --format json
kreuzberg extract document.pdf --output-format markdown
```

## Configuration

### Python - Full Configuration Example
```python
from kreuzberg import (
    extract_file,
    ExtractionConfig,
    OcrConfig,
    TesseractConfig,
    PdfConfig,
    ChunkingConfig,
)

config = ExtractionConfig(
    ocr=OcrConfig(
        backend="tesseract",  # or "easyocr", "paddleocr"
        language="eng",       # Tesseract language code
        tesseract_config=TesseractConfig(
            psm=6,            # Page segmentation mode
            enable_table_detection=True,
        ),
    ),
    pdf_options=PdfConfig(
        passwords=["secret123"],  # For encrypted PDFs
    ),
    chunking=ChunkingConfig(
        max_characters=1000,
        overlap=100,
    ),
    output_format="markdown",  # "plain", "markdown", "djot", "html"
)

result = await extract_file("document.pdf", config=config)
```

### Python - PDF with Password
```python
from kreuzberg import extract_file_sync, ExtractionConfig, PdfConfig

config = ExtractionConfig(
    pdf_options=PdfConfig(passwords=["password1", "password2"])
)
result = extract_file_sync("encrypted.pdf", config=config)
```

### CLI Configuration
```bash
# With config file
kreuzberg extract doc.pdf --config kreuzberg.toml

# With inline JSON
kreuzberg extract doc.pdf --config-json '{"ocr":{"backend":"tesseract","language":"deu"}}'

# With individual flags
kreuzberg extract doc.pdf --ocr true --output-format markdown --chunk true
```

## OCR

OCR runs automatically for:
- Image files (PNG, JPG, TIFF, WebP, BMP, GIF)
- PDFs with low text content (scanned documents)

### Configure OCR Language
```python
from kreuzberg import extract_file_sync, ExtractionConfig, OcrConfig

# Single language
config = ExtractionConfig(ocr=OcrConfig(language="eng"))

# Multiple languages
config = ExtractionConfig(ocr=OcrConfig(language="eng+deu+fra"))

# All installed languages
config = ExtractionConfig(ocr=OcrConfig(language="all"))

result = extract_file_sync("scanned.pdf", config=config)
```

### OCR Backends

**Tesseract** (default, native binding):
```python
config = ExtractionConfig(ocr=OcrConfig(backend="tesseract", language="eng"))
```

**EasyOCR** (Python, requires `pip install kreuzberg[easyocr]`):
```python
config = ExtractionConfig(ocr=OcrConfig(backend="easyocr", language="en"))
result = extract_file_sync("image.png", config=config, easyocr_kwargs={"use_gpu": True})
```

**PaddleOCR** (Python, requires `pip install kreuzberg[paddleocr]`):
```python
config = ExtractionConfig(ocr=OcrConfig(backend="paddleocr", language="en"))
result = extract_file_sync("image.png", config=config, paddleocr_kwargs={"use_angle_cls": True})
```

## Batch Processing

### Python (Async)
```python
from kreuzberg import batch_extract_files

paths = ["doc1.pdf", "doc2.pdf", "doc3.docx"]
results = await batch_extract_files(paths)

for path, result in zip(paths, results):
    print(f"{path}: {len(result.content)} chars")
```

### Python (Sync)
```python
from kreuzberg import batch_extract_files_sync

results = batch_extract_files_sync(["doc1.pdf", "doc2.pdf"])
```

### CLI
```bash
kreuzberg batch *.pdf --format json
kreuzberg batch docs/*.docx --output-format markdown
```

## Supported Formats

### Documents
- **PDF**: `.pdf` - Text, tables, images, OCR support
- **Word**: `.docx`, `.odt` - Full text, tables, styles
- **Excel**: `.xlsx`, `.xlsm`, `.xlsb`, `.xls`, `.ods` - All sheets, formulas
- **PowerPoint**: `.pptx`, `.ppt`, `.ppsx` - Slides, speaker notes
- **eBooks**: `.epub`, `.fb2` - Chapters, metadata

### Images (with OCR)
- `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.bmp`, `.tiff`, `.tif`
- `.jp2`, `.jpx`, `.pnm`, `.pbm`, `.pgm`, `.ppm`
- `.svg` - Vector graphics with embedded text

### Web & Data
- **Markup**: `.html`, `.htm`, `.xhtml`, `.xml`
- **Data**: `.json`, `.yaml`, `.yml`, `.toml`, `.csv`, `.tsv`
- **Text**: `.txt`, `.md`, `.markdown`, `.rst`, `.org`, `.rtf`, `.djot`

### Email & Archives
- **Email**: `.eml`, `.msg` - Headers, body, attachments
- **Archives**: `.zip`, `.tar`, `.tgz`, `.gz`, `.7z`

### Academic
- **Citations**: `.bib`, `.ris`, `.enw`, `.csl`
- **Documents**: `.tex`, `.latex`, `.typ`, `.ipynb`, `.jats`

## Output Structure

`ExtractionResult` contains:
```python
result.content      # Extracted text (str)
result.metadata     # Document metadata (dict)
result.tables       # Extracted tables (list)
result.pages        # Page-by-page content (list, for PDFs)
result.chunks       # Text chunks (if chunking enabled)
```

### Metadata Fields
```python
result.metadata.get("title")       # Document title
result.metadata.get("authors")     # List of authors
result.metadata.get("pages")       # Page count
result.metadata.get("created_at")  # Creation date
result.metadata.get("format")      # Format-specific metadata
```

## Error Handling

### Python
```python
from kreuzberg import extract_file_sync, KreuzbergError, ParsingError, OCRError

try:
    result = extract_file_sync("file.pdf")
except ParsingError as e:
    print(f"Failed to parse document: {e}")
except OCRError as e:
    print(f"OCR failed: {e}")
except KreuzbergError as e:
    print(f"Extraction failed: {e}")
```

### Available Exception Types
- `KreuzbergError` - Base exception
- `ParsingError` - Document parsing failures
- `OCRError` - OCR processing failures
- `ValidationError` - Invalid input or configuration
- `MissingDependencyError` - Required dependency not installed

## MIME Type Detection

```python
from kreuzberg import detect_mime_type, detect_mime_type_from_path

# From bytes
with open("file.pdf", "rb") as f:
    mime = detect_mime_type(f.read())

# From path
mime = detect_mime_type_from_path("document.pdf")
```

## Configuration Files

Kreuzberg supports configuration via TOML, YAML, or JSON files.

### kreuzberg.toml
```toml
[ocr]
backend = "tesseract"
language = "eng"

[pdf_options]
passwords = ["secret"]

[chunking]
max_characters = 1000
overlap = 100

output_format = "markdown"
```

### Load Configuration
```python
from kreuzberg import load_extraction_config_from_file, extract_file_sync

config = load_extraction_config_from_file("kreuzberg.toml")
result = extract_file_sync("document.pdf", config=config)
```

## Common Patterns

### Extract and Chunk for LLM
```python
from kreuzberg import extract_file_sync, ExtractionConfig, ChunkingConfig

config = ExtractionConfig(
    chunking=ChunkingConfig(max_characters=4000, overlap=200),
    output_format="markdown",
)
result = extract_file_sync("large_document.pdf", config=config)

for chunk in result.chunks:
    # Send chunk to LLM
    print(f"Chunk {chunk.metadata.get('chunk_index')}: {len(chunk.content)} chars")
```

### Process All PDFs in Directory
```python
from pathlib import Path
from kreuzberg import batch_extract_files_sync

pdf_files = list(Path("documents").glob("*.pdf"))
results = batch_extract_files_sync(pdf_files)
```

## Resources

- Documentation: https://docs.kreuzberg.dev
- GitHub: https://github.com/kreuzberg-dev/kreuzberg
- PyPI: https://pypi.org/project/kreuzberg/
- npm: https://www.npmjs.com/package/@kreuzberg/node
