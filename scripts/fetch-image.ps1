[CmdletBinding()]
param(
    [string]$OutputDirectory = (Get-Location).Path,
    [int]$CropTopPixels = 140,
    [int]$CropBottomPixels = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not ('ScreenCapture.DpiNativeMethods' -as [type])) {
    Add-Type -Namespace ScreenCapture -Name DpiNativeMethods -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)]
public static extern bool SetProcessDpiAwarenessContext(System.IntPtr dpiContext);
'@
}

# PowerShell 5.1 is DPI-unaware by default and otherwise receives logical
# coordinates (for example 1536x864 on a 1920x1080 display at 125% scaling).
[void][ScreenCapture.DpiNativeMethods]::SetProcessDpiAwarenessContext([System.IntPtr](-4))

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if ($CropTopPixels -lt 0 -or $CropBottomPixels -lt 0) {
    throw "CropTopPixels and CropBottomPixels must be 0 or greater."
}

if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
}

$resolvedOutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$height = $bounds.Height - $CropTopPixels - $CropBottomPixels
if ($height -le 0) {
    throw "The combined crop ($CropTopPixels + $CropBottomPixels) must be smaller than the screen height ($($bounds.Height))."
}
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
        $bounds.Top + $CropTopPixels,
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
