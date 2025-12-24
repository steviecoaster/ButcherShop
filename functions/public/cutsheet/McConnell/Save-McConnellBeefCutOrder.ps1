function Save-McConnellBeefCutOrder {
<#
.SYNOPSIS
Persist a McConnell beef cut order to the database.

.DESCRIPTION
Inserts or updates a McConnell beef cut sheet record. Accepts the object produced by New-McConnellBeefCutOrder.

.PARAMETER CutOrder
The PSCustomObject representing the cut order to save.

.EXAMPLE
$cut = New-McConnellBeefCutOrder -OrderId 42 -CustomerName 'Acme'
Save-McConnellBeefCutOrder -CutOrder $cut

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]
        $CutOrder
    )

  Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query @"
INSERT INTO McConnellBeefCutSheets
(
  OrderId, CustomerName, Phone, CallWhenReady,
  BeefPortion, HangingWeight,
  SteaksPerPackage, SteakThickness,
  ArmRoastSizeLbs, ChuckRoastSizeLbs, RumpRoastSizeLbs, TipRoastSizeLbs,
  RoundSteaksPerPackage, RoundSteakTenderized, RoundSteakPlain,
  ShortRibs, StewMeat,
  BulkGroundPkgSizeLbs, Patties, PattySize,
  Liver, Heart, Tongue, SoupBones,
  SpecialInstructions
)
VALUES (
  $($CutOrder.OrderId),
  $(Sql-Text $CutOrder.CustomerName),
  $(Sql-Text $CutOrder.Phone),
  $($CutOrder.CallWhenReady),
  '$($CutOrder.BeefPortion)',
  $($CutOrder.HangingWeight),
  $($CutOrder.SteaksPerPackage),
  $(Sql-Text $CutOrder.SteakThickness),
  $($CutOrder.ArmRoastSizeLbs),
  $($CutOrder.ChuckRoastSizeLbs),
  $($CutOrder.RumpRoastSizeLbs),
  $($CutOrder.TipRoastSizeLbs),
  $($CutOrder.RoundSteaksPerPackage),
  $($CutOrder.RoundSteakTenderized),
  $($CutOrder.RoundSteakPlain),
  $($CutOrder.ShortRibs),
  $($CutOrder.StewMeat),
  $($CutOrder.BulkGroundPkgSizeLbs),
  $($CutOrder.Patties),
  $(Sql-Text $CutOrder.PattySize),
  $($CutOrder.Liver),
  $($CutOrder.Heart),
  $($CutOrder.Tongue),
  $($CutOrder.SoupBones),
  $(Sql-Text $CutOrder.SpecialInstructions)
)
ON CONFLICT(OrderId) DO UPDATE SET
  CustomerName=excluded.CustomerName,
  Phone=excluded.Phone,
  CallWhenReady=excluded.CallWhenReady,
  SpecialInstructions=excluded.SpecialInstructions;
"@ | Out-Null

  # Return the OrderId for the saved cut order (mirrors Save-McConnellHogCutOrder behavior)
  return [int]$CutOrder.OrderId
}
