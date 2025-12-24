function Save-McConnellHogCutOrder {
<#
.SYNOPSIS
Persist a McConnell hog cut order to the database.

.DESCRIPTION
Inserts or updates a McConnell hog cut sheet record. Accepts the hashtable produced by New-McConnellHogCutOrder.

.PARAMETER CutOrder
The hashtable representing the cut order to save.

.EXAMPLE
$cut = New-McConnellHogCutOrder -OrderId 43 -CustomerName 'Acme'
Save-McConnellHogCutOrder -CutOrder $cut

#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [hashtable]
    $CutOrder
  )

  if (-not $CutOrder.OrderId) { throw "Save-McConnellHogCutOrder: CutOrder.OrderId is required." }
  $orderId = [int]$CutOrder.OrderId

  $q = @"
INSERT INTO McConnellHogCutSheets (
  OrderId,
  CustomerName, Phone,
  HogPortion, HangingWeight,
  PorkChopsPerPackage, ChopThickness, ChopStyle,
  LoinRoastSizeLbs, NoLoinRoast,
  BaconStyle, CountryStyleRibs, SpareRibsStyle,
  HamStyle, HamSizeLbs, HamSliced, HamWhole, HamHalved,
  ShoulderRoastSizeLbs, ShoulderSlicesPerPackage, NoShoulder,
  GroundPork,
  SausageRegular, SausageSweetItalian, SausageHotItalian,
  SausageBulk, SausageBigLinks, SausageSmallLinks, SausageQuarterLbPatties,
  SpecialInstructions
)
VALUES (
  $orderId,
  $(Sql-Text $CutOrder.CustomerName), $(Sql-Text $CutOrder.Phone),
  $(Sql-Text $CutOrder.HogPortion), $(Sql-Num $CutOrder.HangingWeight),
  $(Sql-Num $CutOrder.PorkChopsPerPackage), $(Sql-Text $CutOrder.ChopThickness), $(Sql-Text $CutOrder.ChopStyle),
  $(Sql-Num $CutOrder.LoinRoastSizeLbs), $(Sql-Bool $CutOrder.NoLoinRoast),
  $(Sql-Text $CutOrder.BaconStyle), $(Sql-Bool $CutOrder.CountryStyleRibs), $(Sql-Text $CutOrder.SpareRibsStyle),
  $(Sql-Text $CutOrder.HamStyle), $(Sql-Num $CutOrder.HamSizeLbs), $(Sql-Bool $CutOrder.HamSliced), $(Sql-Bool $CutOrder.HamWhole), $(Sql-Bool $CutOrder.HamHalved),
  $(Sql-Num $CutOrder.ShoulderRoastSizeLbs), $(Sql-Num $CutOrder.ShoulderSlicesPerPackage), $(Sql-Bool $CutOrder.NoShoulder),
  $(Sql-Bool $CutOrder.GroundPork),
  $(Sql-Bool $CutOrder.SausageRegular), $(Sql-Bool $CutOrder.SausageSweetItalian), $(Sql-Bool $CutOrder.SausageHotItalian),
  $(Sql-Bool $CutOrder.SausageBulk), $(Sql-Bool $CutOrder.SausageBigLinks), $(Sql-Bool $CutOrder.SausageSmallLinks), $(Sql-Bool $CutOrder.SausageQuarterLbPatties),
  $(Sql-Text $CutOrder.SpecialInstructions)
)
ON CONFLICT(OrderId) DO UPDATE SET
  CustomerName=excluded.CustomerName,
  Phone=excluded.Phone,
  HogPortion=excluded.HogPortion,
  HangingWeight=excluded.HangingWeight,

  PorkChopsPerPackage=excluded.PorkChopsPerPackage,
  ChopThickness=excluded.ChopThickness,
  ChopStyle=excluded.ChopStyle,

  LoinRoastSizeLbs=excluded.LoinRoastSizeLbs,
  NoLoinRoast=excluded.NoLoinRoast,

  BaconStyle=excluded.BaconStyle,
  CountryStyleRibs=excluded.CountryStyleRibs,
  SpareRibsStyle=excluded.SpareRibsStyle,

  HamStyle=excluded.HamStyle,
  HamSizeLbs=excluded.HamSizeLbs,
  HamSliced=excluded.HamSliced,
  HamWhole=excluded.HamWhole,
  HamHalved=excluded.HamHalved,

  ShoulderRoastSizeLbs=excluded.ShoulderRoastSizeLbs,
  ShoulderSlicesPerPackage=excluded.ShoulderSlicesPerPackage,
  NoShoulder=excluded.NoShoulder,

  GroundPork=excluded.GroundPork,

  SausageRegular=excluded.SausageRegular,
  SausageSweetItalian=excluded.SausageSweetItalian,
  SausageHotItalian=excluded.SausageHotItalian,
  SausageBulk=excluded.SausageBulk,
  SausageBigLinks=excluded.SausageBigLinks,
  SausageSmallLinks=excluded.SausageSmallLinks,
  SausageQuarterLbPatties=excluded.SausageQuarterLbPatties,

  SpecialInstructions=excluded.SpecialInstructions;
"@

  Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $q | Out-Null
  $orderId
}