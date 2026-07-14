# fetch-image

`fetch-image` is a Windows Codex skill for fetching the latest image. It runs one deterministic PowerShell script, omits the first 140 pixel rows, and writes exactly one timestamped PNG.

> [!IMPORTANT]
> Run only `scripts/fetch-image.ps1`. Do not invoke a wrapper, helper, second-stage process, retry, or fallback script.

## Requirements

- Windows with an active interactive desktop session
- Windows PowerShell 5.1
- The built-in `.NET` assemblies `System.Windows.Forms` and `System.Drawing`
- Git, when installing by cloning the repository

No additional runtime packages are required.

## Installation

Clone the repository into the Codex skills directory:

```powershell
git clone https://github.com/Alexander-Bruce/fetch-image.git "$HOME\.codex\skills\fetch-image"
```

Start a new Codex task if the installed skill is not immediately listed.

## Usage

### With Codex

```text
Use $fetch-image to fetch the latest image.
```

### From PowerShell

Run exactly this one script:

```powershell
& "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File "$HOME\.codex\skills\fetch-image\scripts\fetch-image.ps1"
```

To choose another output directory, pass `-OutputDirectory` to the same script:

```powershell
& "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File "$HOME\.codex\skills\fetch-image\scripts\fetch-image.ps1" `
  -OutputDirectory "C:\Images"
```

## Output

Each successful run:

- Writes exactly one PNG named `image-yyyyMMdd-HHmmss.png`
- Omits the first 140 pixel rows
- Uses the working directory unless `-OutputDirectory` is provided
- Creates the requested output directory when it does not exist
- Prints the absolute path of the resulting file

Generated `image-*.png` files at the repository root are ignored by Git.

## Error behavior

System exceptions propagate unchanged. The script does not catch, retry, wrap, suppress, replace, or fall back from an error. Graphics resources are still disposed during cleanup.

## Repository layout

```text
fetch-image/
├── .gitignore
├── README.md
├── SKILL.md
├── agents/
│   └── openai.yaml
└── scripts/
    └── fetch-image.ps1
```

The resulting PNG may contain sensitive visible information, so review it before sharing.
