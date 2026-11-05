---
name: format-markdown
version: 1.1
description: Load this skill when a .md (markdown) file is created, modified, or when the user requests formatting of markdown content. Auto-applies consistent formatting to markdown files.
last_updated: 2026-11-05
related: pre-commit-review
---

# Format Markdown Skill

You are in auto-format markdown mode. **Whenever a .md file is created, modified, or explicitly referenced for formatting, automatically apply consistent formatting without asking for confirmation.**

## When This Skill Applies

This skill loads automatically when:
- A `.md` file is created via `write_file`
- A `.md` file is modified via `edit`
- The user explicitly requests markdown formatting
- You are about to write markdown content to any file

## Formatting Rules

Apply these rules **automatically** to all markdown content:

### 1. Tables
- Ensure all columns in a table have **equal width**
- Pad each column to the length of the longest entry in that column
- Align the pipe separators (`|`) vertically
- Maintain consistent spacing around pipes (one space on each side)

**Before:**
```markdown
| Name | Age | City |
|------|-----|------|
| Alice | 30 | New York |
| Bob | 5 | LA |
```

**After:**
```markdown
| Name   | Age | City     |
|--------|-----|----------|
| Alice  | 30  | New York |
| Bob    | 5   | LA       |
```

### 2. Code Comments (in code blocks)
- Align comment prefixes (`#`, `//`, `/*`, etc.) vertically when they appear in consecutive lines
- Maintain consistent indentation of comments relative to code

**Before:**
````markdown
```python
# This is a comment
x = 5  # another comment
   # indented comment
```
````

**After:**
````markdown
```python
# This is a comment
# another comment
# indented comment
x = 5
```
````

### 3. Code Blocks
- Ensure language specifier is present when applicable (e.g., ```python, ```bash)
- Remove unnecessary blank lines at start/end of code blocks
- Consistent indentation: 2 or 4 spaces (match surrounding content)
- If no language specified and content is code, add appropriate language tag

**Before:**
````markdown
```
function test() {
  return true;
}

```
````

**After:**
````markdown
```javascript
function test() {
  return true;
}
```
````

### 4. Headers
- **One blank line** before each header (except for the first header at file start)
- **One blank line** after each header
- Consistent header hierarchy (don't skip levels)
- Use ATX-style headers (`#`, `##`, etc.) consistently
- No trailing `#` characters

**Before:**
````markdown
# Title
## Section 1
Content here
### Subsection
More content
````

**After:**
````markdown
# Title

## Section 1

Content here

### Subsection

More content
````

### 5. Lists
- Consistent bullet character: use `-` for all unordered list items
- Indent nested lists with 2 or 4 spaces (match document style)
- Add blank line between list items when they contain multiple paragraphs
- Consistent spacing: one space after bullet

**Before:**
```markdown
* Item 1
* Item 2
  * Nested
- Item 3
```

**After:**
```markdown
- Item 1
- Item 2
  - Nested
- Item 3
```

### 6. Links
- Consistent format: `[text](url)`
- No spaces around brackets or parentheses
- Use descriptive link text (not "click here")
- For reference-style links, use consistent format

**Before:**
```markdown
Check out [this site]( https://example.com ) for more.
```

**After:**
```markdown
Check out [this site](https://example.com) for more.
```

### 7. Images
- Consistent format: `![alt text](url)`
- No spaces around brackets or parentheses
- Always include descriptive alt text
- Consistent syntax for image paths (relative vs absolute)

**Before:**
```markdown
![My Image]( /images/logo.png )
```

**After:**
```markdown
![My Image](/images/logo.png)
```

### 8. Line Length
- Preserve original line lengths for readability
- For code blocks: preserve original formatting (don't wrap)
- For tables: let columns expand to fit content

### 9. Trailing Whitespace
- **Remove all trailing whitespace** from every line
- Ensure no line ends with spaces or tabs

### 10. Edge Cases
- **Markdown in code blocks**: If a code block contains markdown syntax (e.g., ````markdown` blocks), format the inner content
- **Inline code**: Don't format content within backticks
- **HTML in markdown**: Leave `<tag>` content unchanged

## Application Rules

### When to Apply
1. **After writing a new .md file** - Format immediately after `write_file`
2. **After editing a .md file** - Format the entire file after `edit`
3. **Before returning markdown content** - Format any markdown in your response
4. **When user requests formatting** - Apply to specified file(s)
5. **Before committing** - Auto-format any staged .md files before `git commit`

### When NOT to Apply
1. **Code blocks with explicit formatting** - Preserve intentional formatting
2. **Pre-formatted content** - If content is clearly meant to be as-is
3. **Third-party content** - Quoted/copied content that should remain unchanged

## Implementation Guidance

### For `write_file` Operations
- After writing the file, read it back
- Apply all formatting rules
- Write the formatted version back

### For `edit` Operations
- After each edit, re-read the entire file
- Apply formatting to the entire file
- Write the formatted version back

### For User Requests
- When user says "format this markdown" or similar, apply all rules
- Show the formatted result

## Performance Considerations

- Format files **once** after the last change in a sequence
- Don't format after every minor change if multiple changes are planned
- For large files (>1000 lines), format in sections if needed

## Quality Assurance

After formatting, verify:
- File is still valid markdown
- All links still work
- Code blocks are still executable
- Tables are still readable
- No information was lost

## Never Do

- Format content inside `<pre>` tags
- Change the meaning or content of the text
- Reorder lists or tables
- Modify URLs or file paths
- Add or remove actual content (only formatting)

## Error Recovery

- If formatting corrupts a file: Restore from git or backup, then manually review the formatting rules
- If tables break alignment: Re-run formatting with simpler content, then manually adjust
- If links break: Verify the formatting didn't add/remove characters from URLs

## Related Skills

- **pre-commit-review**: Use together for commit message formatting before git operations
