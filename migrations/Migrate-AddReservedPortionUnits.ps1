param(
    [string]$DatabasePath = "./data/ButcherShop.db"
)

Set-StrictMode -Version Latest

if (-not (Test-Path $DatabasePath)) { throw "Database not found: $DatabasePath" }

$backup = "$DatabasePath.bak.reservedunits.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item -Path $DatabasePath -Destination $backup -Force
Write-Host "Backed up $DatabasePath -> $backup"

# Ensure module functions available (for sqlite helper)
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    $modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath '..\ButcherShop.psd1'
    if (Test-Path $modulePath) { Import-Module $modulePath -Force }
}
if (-not (Get-Command Invoke-UniversalSQLiteQuery -ErrorAction SilentlyContinue)) {
    throw "Could not import module functions. Ensure you run this from the project where the module is available."
}

# Build migration SQL: create new table, copy data (computing ReservedPortionUnits from Orders), swap names
$migration = @"
PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS DailySlots_new (
  SlotDate        TEXT NOT NULL,
  Species         TEXT NOT NULL CHECK (Species IN ('Beef','Hog')),
  Shop            TEXT NOT NULL CHECK (Shop IN ('Don','McConnell')) DEFAULT 'Don',
  TotalSlots      INTEGER NOT NULL CHECK (TotalSlots >= 0),
  ReservedSlots   INTEGER NOT NULL DEFAULT 0 CHECK (ReservedSlots >= 0),
  ReservedPortionUnits INTEGER NOT NULL DEFAULT 0 CHECK (ReservedPortionUnits >= 0),
  PRIMARY KEY (SlotDate, Species, Shop),
  CHECK (ReservedPortionUnits <= TotalSlots * 4)
);

-- Compute ReservedPortionUnits by summing portions from Orders for that date/species/shop
INSERT INTO DailySlots_new (SlotDate, Species, Shop, TotalSlots, ReservedSlots, ReservedPortionUnits)
SELECT
  ds.SlotDate,
  ds.Species,
  ds.Shop,
  ds.TotalSlots,
  ds.ReservedSlots,
  COALESCE((
    SELECT SUM(
      CASE o.Portion WHEN 'Whole' THEN 4 WHEN 'Half' THEN 2 ELSE 0 END
    )
    FROM Orders o
    WHERE o.SlotDate = ds.SlotDate
      AND o.Species = ds.Species
      AND (o.SlotShop = ds.Shop OR (o.SlotShop IS NULL AND ds.Shop = 'Don'))
  ), 0) AS ReservedPortionUnits
FROM (
  SELECT SlotDate, Species, Shop, TotalSlots, ReservedSlots FROM DailySlots
) ds;

-- Handle any DailySlots that didn't exist in original (no-op)

DROP VIEW IF EXISTS v_DailyAvailability;
DROP TABLE IF EXISTS DailySlots;
ALTER TABLE DailySlots_new RENAME TO DailySlots;

CREATE INDEX IF NOT EXISTS idx_dailyslots_date ON DailySlots(SlotDate);

CREATE VIEW IF NOT EXISTS v_DailyAvailability AS
SELECT
  SlotDate,
  Species,
  TotalSlots,
  ReservedSlots,
  ReservedPortionUnits,
  (TotalSlots * 4 - ReservedPortionUnits) AS AvailablePortionUnits,
  ((TotalSlots * 4 - ReservedPortionUnits) / 4) AS AvailableAnimals
FROM DailySlots;

COMMIT;
PRAGMA foreign_keys = ON;
"@

Write-Host "Running migration SQL against: $DatabasePath"
Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $migration | Out-Null
Write-Host "Migration complete. Verifying schema..."

Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('DailySlots');" | Format-Table -AutoSize

Write-Host "Done."
