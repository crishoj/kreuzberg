# Kreuzberg Claude Code Skills

This directory contains [Claude Code](https://claude.com/claude-code) skills that help users work with the Kreuzberg document extraction library.

## Available Skills

### `kreuzberg`

A comprehensive skill that teaches Claude how to use Kreuzberg for document extraction, including:

- Installation across all supported languages (Python, Rust, Node.js, CLI)
- Basic and advanced extraction examples
- OCR configuration (Tesseract, EasyOCR, PaddleOCR)
- Batch processing
- Configuration files
- Error handling
- Common patterns

## Installation

### Option 1: Copy to Local Skills Directory

Copy the `kreuzberg` folder to your Claude Code skills directory:

```bash
# macOS/Linux
cp -r skills/kreuzberg ~/.claude/skills/

# Or create a symlink
ln -s $(pwd)/skills/kreuzberg ~/.claude/skills/kreuzberg
```

### Option 2: Project-Level Skills

For project-specific usage, the skills are already in the repository. Claude Code will automatically discover skills in the `skills/` directory when working within this project.

## Usage

Once installed, Claude Code will automatically use the Kreuzberg skill when you ask questions like:

- "Extract text from this PDF"
- "How do I configure OCR for German documents?"
- "Batch process all Word documents in this folder"
- "How do I handle password-protected PDFs?"

## Skill Structure

```
skills/
├── README.md           # This file
└── kreuzberg/
    └── SKILL.md        # Main skill instructions
```

## Creating Custom Skills

For information on creating your own Claude Code skills, see:
- [How to Create Custom Skills](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [Agent Skills Specification](https://agentskills.io)
