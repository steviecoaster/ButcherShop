# Wrapper for tests: call the top-level seed script from project tools to match test expectation
param(
    [int]$Scale = 1,
    [string]$DatabasePath
)

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$tool = Join-Path $root 'tools\Invoke-SeedLargeDataset.ps1'
if (-not (Test-Path $tool)) { throw "Seed tool not found: $tool" }
& $tool -Scale $Scale -DatabasePath $DatabasePath
