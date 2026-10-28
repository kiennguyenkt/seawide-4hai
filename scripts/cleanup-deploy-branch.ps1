$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$targets = @(
    "tools",
    "docs/assets",
    "docs/mine_docs",
    "docs/sea",
    ".playwright-mcp",
    "pyproject.toml",
    "README.BE.md",
    "uv.lock"
)

foreach ($item in $targets) {
    if (Test-Path $item) {
        Write-Host "Delete $item ... " -NoNewline
        Remove-Item -Recurse -Force $item
        Write-Host "Done"
    }
}
