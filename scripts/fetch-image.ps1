[CmdletBinding()]
param(
    [string]$OutputDirectory = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
}

$resolvedOutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$height = $bounds.Height - 140
$size = [System.Drawing.Size]::new($bounds.Width, $height)
$path = Join-Path $resolvedOutputDirectory (
    'image-{0}.png' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
)

$bitmap = $null
$graphics = $null

try {
    $bitmap = [System.Drawing.Bitmap]::new($bounds.Width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen(
        $bounds.Left,
        $bounds.Top + 140,
        0,
        0,
        $size,
        [System.Drawing.CopyPixelOperation]::SourceCopy
    )
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    if ($graphics) {
        $graphics.Dispose()
    }
    if ($bitmap) {
        $bitmap.Dispose()
    }
}

Write-Output ([System.IO.Path]::GetFullPath($path))
