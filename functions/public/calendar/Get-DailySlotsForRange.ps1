function Get-DailySlotsForRange {
<#
.SYNOPSIS
Get daily booking slot rows for a date range.

.DESCRIPTION
Returns DailySlots rows (and optionally filters by species) for the provided date range.

.PARAMETER StartDate
Range start date.

.PARAMETER EndDate
Range end date.

.PARAMETER Type
Optional species filter (Beef/Hog).

.EXAMPLE
Get-DailySlotsForRange -StartDate (Get-Date) -EndDate (Get-Date).AddDays(30)

#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][DateTime]$Start,
        [Parameter(Mandatory)][DateTime]$End,
    [Parameter()][ValidateSet('Beef','Hog')][string]$Type,
    [Parameter()][ValidateScript({ $_ -eq $null -or $_ -eq '' -or @('Don','McConnell') -contains $_ })][string]$Shop,
  [Parameter()][ValidateSet('Whole','Half')][string]$Portion,
    [Parameter()][switch]$OnlyAvailable
    )

    $startStr = $Start.ToString('yyyy-MM-dd')
    $endStr   = $End.ToString('yyyy-MM-dd')

  $speciesFilter = if ($Type) { " AND species.s = '$Type'" } else { "" }

  if ($Portion) {
    switch ($Portion) {
      'Whole' { $requiredUnits = 4 }
      'Half'  { $requiredUnits = 2 }
      default { $requiredUnits = 4 }
    }
    $availableFilter = if ($OnlyAvailable) { " AND (COALESCE(ds.TotalSlots, 0) * 4 - COALESCE(ds.ReservedPortionUnits, 0)) >= $requiredUnits" } else { "" }
  }
  else {
    # Backwards compatibility: when no Portion specified, OnlyAvailable filters by animal-level availability.
    $availableFilter = if ($OnlyAvailable) { " AND (COALESCE(ds.TotalSlots, 0) - COALESCE(ds.ReservedSlots, 0)) > 0" } else { "" }
  }

    $query = @"
WITH RECURSIVE dates(d) AS (
  SELECT date('$startStr')
  UNION ALL
  SELECT date(d, '+1 day')
  FROM dates
  WHERE d < date('$endStr', '-1 day')
),
species(s) AS (
  SELECT 'Beef' UNION ALL SELECT 'Hog'
)
,
shops(sh) AS (
  SELECT 'Don' UNION ALL SELECT 'McConnell'
)
SELECT
  dates.d AS SlotDate,
  species.s AS Species,
  shops.sh AS Shop,
  COALESCE(ds.TotalSlots, 0) AS TotalSlots,
  COALESCE(ds.ReservedSlots, 0) AS ReservedSlots,
  COALESCE(ds.ReservedPortionUnits, 0) AS ReservedPortionUnits,
  (COALESCE(ds.TotalSlots, 0) * 4 - COALESCE(ds.ReservedPortionUnits, 0)) AS AvailablePortionUnits,
  ((COALESCE(ds.TotalSlots, 0) * 4 - COALESCE(ds.ReservedPortionUnits, 0)) / 4) AS AvailableAnimals
FROM dates
CROSS JOIN species
CROSS JOIN shops
LEFT JOIN DailySlots ds
  ON ds.SlotDate = dates.d
 AND ds.Species  = species.s
 AND ds.Shop     = shops.sh
WHERE 1=1
AND (COALESCE('$Shop','') = '' OR shops.sh = '$Shop')
$speciesFilter
$availableFilter
ORDER BY dates.d, species.s;
"@

    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}