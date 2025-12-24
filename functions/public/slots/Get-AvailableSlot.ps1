function Get-AvailableSlot {
<#
.SYNOPSIS
Retrieve available slot information for a month or a specific date.

.DESCRIPTION
Get-AvailableSlot returns availability information for booking slots. It accepts either a month/year pair or a specific date depending on the parameter usage.

.PARAMETER Month
Month number (1-12) when querying by month.

.PARAMETER Year
Year when querying by month.

.PARAMETER Date
Exact date to query availability for a single day.

.EXAMPLE
Get-AvailableSlot -Month 12 -Year 2025

.EXAMPLE
Get-AvailableSlot -YearOnly 2025

#>
  [CmdletBinding(DefaultParameterSetName = 'ByMonth')]
  param(
    # Month/Year parameter set (default)
    [Parameter(ParameterSetName = 'ByMonth')]
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [string]
    $Month = (Get-Date).ToString('MMMM'),

    [Parameter(ParameterSetName = 'ByMonth')]
    [int]
    $Year = (Get-Date).Year,

    # Exact date parameter set
    [Parameter(ParameterSetName = 'ByDate', Mandatory = $true)]
    [DateTime]
    $Date,

    # Year parameter set — return the whole year
    [Parameter(ParameterSetName = 'ByYear', Mandatory = $true)]
    [int]
    $YearOnly,

    # Species filter (allow null/empty and specific values)
    [Parameter()]
    [ValidateScript({ $_ -eq $null -or $_ -eq '' -or @('All','Beef','Hog') -contains $_ })]
    [string]
    $Type = 'All',

    [Parameter()]
    [ValidateScript({ $_ -eq $null -or $_ -eq '' -or @('All','Don','McConnell') -contains $_ })]
    [string]
    $Shop = 'All',

  [Parameter()]
  [ValidateSet('Whole','Half')]
  [string]
  $Portion,

    [Parameter()]
    [switch]
    $OnlyAvailable
  )

  # Determine start/end based on parameter set
  if ($PSCmdlet.ParameterSetName -eq 'ByDate') {
    $start = $Date.Date
    $end = $start.AddDays(1)
  }
  elseif ($PSCmdlet.ParameterSetName -eq 'ByYear') {
    $start = Get-Date -Year $YearOnly -Month 1 -Day 1
    $end = $start.AddYears(1)
  }
  else {
    $monthNumber = ([datetime]::ParseExact($Month, 'MMMM', $null)).Month
    $start = Get-Date -Year $Year -Month $monthNumber -Day 1
    $end = $start.AddMonths(1)
  }

  $startStr = $start.ToString('yyyy-MM-dd')
  $endStr = $end.ToString('yyyy-MM-dd')

  # Normalize Type: treat empty or 'All' as no filter
  if ([string]::IsNullOrWhiteSpace([string]$Type) -or [string]::Equals([string]$Type, 'All', 'InvariantCultureIgnoreCase')) {
    $speciesFilter = ''
  }
  else {
    $speciesFilter = " AND Species = '$Type'"
  }

  # Normalize Shop: treat empty or 'All' as no filter
  if ([string]::IsNullOrWhiteSpace([string]$Shop) -or [string]::Equals([string]$Shop, 'All', 'InvariantCultureIgnoreCase')) {
    $shopFilter = ''
  }
  else {
    $shopFilter = " AND Shop = '$Shop'"
  }

  # Determine available filter. If a Portion is provided, compute required portion-units and filter by AvailablePortionUnits >= requiredUnits.
  if ($Portion) {
    switch ($Portion) {
      'Whole' { $requiredUnits = 4 }
      'Half'  { $requiredUnits = 2 }
      default { $requiredUnits = 4 }
    }
    $availableFilter = if ($OnlyAvailable) { " AND (TotalSlots * 4 - ReservedPortionUnits) >= $requiredUnits" } else { "" }
  }
  else {
    # Backwards compatibility: when no Portion specified, OnlyAvailable filters by animal-level availability.
    $availableFilter = if ($OnlyAvailable) { " AND (TotalSlots - ReservedSlots) > 0" } else { "" }
  }

  $query = @"
SELECT
  SlotDate,
  Shop,
  Species,
  TotalSlots,
  ReservedSlots,
  ReservedPortionUnits,
  (TotalSlots * 4 - ReservedPortionUnits) AS AvailablePortionUnits,
  ((TotalSlots * 4 - ReservedPortionUnits) / 4) AS AvailableAnimals
FROM DailySlots
WHERE SlotDate >= '$startStr'
  AND SlotDate <  '$endStr'
$speciesFilter
$shopFilter
$availableFilter
ORDER BY SlotDate, Species;
"@

  try {
    return Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
  }
  catch {
    throw "Get-AvailableSlot failed for range $startStr..$endStr [$Type]: $($_.Exception.Message)"
  }
}