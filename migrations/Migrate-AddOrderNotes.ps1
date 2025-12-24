<#
Safe migration: add Notes column to Orders if missing
#>
param(
    [string]$DatabasePath = (Join-Path $PSScriptRoot '..\data\ButcherShop.db')
)

if (-not (Test-Path $DatabasePath)) { throw "Database not found: $DatabasePath" }

Write-Host "Checking Orders table for Notes column in $DatabasePath"
$cols = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('Orders');"
if ($cols | Where-Object { $_.name -eq 'Notes' }) {
    Write-Host "Notes column already exists. Nothing to do."
    return
}

$bak = "$DatabasePath.bak.order-notes.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item -Path $DatabasePath -Destination $bak -Force
Write-Host "Backed up DB to $bak"

# SQLite can add new nullable columns with ALTER TABLE
Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "ALTER TABLE Orders ADD COLUMN Notes TEXT;"
Write-Host "Added Notes column to Orders"

