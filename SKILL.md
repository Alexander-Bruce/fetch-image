---
name: fetch-image
description: Run only the bundled fetch-image PowerShell script to fetch the latest image and save it as image-timestamp.png. Use when the user asks for fetch-image or 获取最新图片.
---

**Only run one script: `scripts/fetch-image.ps1`. Do not run any other script for this skill.**

# Fetch Image

## Workflow

Run exactly this one script from the current working directory unless the user specifies another output directory:

```powershell
& "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\fetch-image\scripts\fetch-image.ps1"
```

The script performs the complete operation in one pass, omits the first 140 pixel rows, and writes exactly one PNG named `image-yyyyMMdd-HHmmss.png`.

## Rules

- Run exactly one script per request.
- Do not invoke a wrapper, helper, second-stage script, or fallback.
- Do not interact with applications before fetching the latest image.
- Use the current working directory unless the user specifies another output directory with `-OutputDirectory`.
- Let any system exception surface unchanged. Do not retry, catch, wrap, suppress, or replace it.
- Report the absolute path printed by the script.
- If the user asks what the latest image contains, inspect the resulting PNG with the local image viewer and describe only its visible contents.
