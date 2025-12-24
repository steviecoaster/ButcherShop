function Save-DonHogCutOrder {
  <#
.SYNOPSIS
Persist a Don pork cut order to the database.

.DESCRIPTION
Inserts or updates a Don pork cut sheet row. Accepts the object produced by New-DonPorkCutOrder.

.PARAMETER CutOrder
The cut order object to save.

.EXAMPLE
$cut = New-DonPorkCutOrder -OrderId 101
Save-DonPorkCutOrder -CutOrder $cut

#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [hashtable]
    $CutOrder
  )

  if (-not $CutOrder.OrderId) { throw "Save-DonPorkCutOrder: CutOrder.OrderId is required." }
  $orderId = [int]$CutOrder.OrderId

  $q = @"
INSERT INTO DonPorkCutSheets (
  OrderId,
  CutFor, Phone, PorkFrom, HogChoice,
  PorkChopsThicknessIn, PorkChopsPerPackage,
  PorkLoinRoastLbsPerRoast,
  ShoulderChoice, ShoulderRoastsLbsPerRoast, ShoulderSteaksThicknessIn, ShoulderSteaksPerPackage,
  PicnicHamWholeHalfSliced,
  SpareRibsChoice, SpareRibsLbsPerCut, SpareRibsPiecesPerPackage, SpareRibsWholeSlabPerPackage,
  HamChoice,
  CuredHamPortion, CuredHamSliceStyle, CuredHamSlicesPerPackage,
  FreshLegPortion, FreshLegCutIntoRoastsLbs, FreshLegProcessStyle, FreshLegSlicesOrSteaksPerPackage,
  BaconChoice, BaconLbsPerPackage, BaconSliceThickness,
  HamHocksChoice, PutHamHocksIntoSausage,
  SausageSeasoning, SausageBulk, SausageBulkLbsPerPackage,
  SausageRegularCased, SausageRegularCasedLbsPerPackage,
  SausageSmallLink, SausageSmallLinkLbsPerPackage,
  SausageNotes,
  LiverChoice, HeartChoice, TongueChoice,
  SpecialInstructions
)
VALUES (
  $orderId,
  $(Sql-Text $CutOrder.CutFor), $(Sql-Text $CutOrder.Phone), $(Sql-Text $CutOrder.PorkFrom), $(Sql-Text $CutOrder.HogChoice),
  $(Sql-Num $CutOrder.PorkChopsThicknessIn), $(Sql-Num $CutOrder.PorkChopsPerPackage),
  $(Sql-Num $CutOrder.PorkLoinRoastLbsPerRoast),
  $(Sql-Text $CutOrder.ShoulderChoice), $(Sql-Num $CutOrder.ShoulderRoastsLbsPerRoast), $(Sql-Num $CutOrder.ShoulderSteaksThicknessIn), $(Sql-Num $CutOrder.ShoulderSteaksPerPackage),
  $(Sql-Text $CutOrder.PicnicHamWholeHalfSliced),
  $(Sql-Text $CutOrder.SpareRibsChoice), $(Sql-Num $CutOrder.SpareRibsLbsPerCut), $(Sql-Num $CutOrder.SpareRibsPiecesPerPackage), $(Sql-Num $CutOrder.SpareRibsWholeSlabPerPackage),
  $(Sql-Text $CutOrder.HamChoice),
  $(Sql-Text $CutOrder.CuredHamPortion), $(Sql-Text $CutOrder.CuredHamSliceStyle), $(Sql-Num $CutOrder.CuredHamSlicesPerPackage),
  $(Sql-Text $CutOrder.FreshLegPortion), $(Sql-Num $CutOrder.FreshLegCutIntoRoastsLbs), $(Sql-Text $CutOrder.FreshLegProcessStyle), $(Sql-Num $CutOrder.FreshLegSlicesOrSteaksPerPackage),
  $(Sql-Text $CutOrder.BaconChoice), $(Sql-Num $CutOrder.BaconLbsPerPackage), $(Sql-Text $CutOrder.BaconSliceThickness),
  $(Sql-Text $CutOrder.HamHocksChoice), $(Sql-Bool $CutOrder.PutHamHocksIntoSausage),
  $(Sql-Text $CutOrder.SausageSeasoning), $(Sql-Bool $CutOrder.SausageBulk), $(Sql-Num $CutOrder.SausageBulkLbsPerPackage),
  $(Sql-Bool $CutOrder.SausageRegularCased), $(Sql-Num $CutOrder.SausageRegularCasedLbsPerPackage),
  $(Sql-Bool $CutOrder.SausageSmallLink), $(Sql-Num $CutOrder.SausageSmallLinkLbsPerPackage),
  $(Sql-Text $CutOrder.SausageNotes),
  $(Sql-Text $CutOrder.LiverChoice), $(Sql-Text $CutOrder.HeartChoice), $(Sql-Text $CutOrder.TongueChoice),
  $(Sql-Text $CutOrder.SpecialInstructions)
)
ON CONFLICT(OrderId) DO UPDATE SET
  CutFor=excluded.CutFor,
  Phone=excluded.Phone,
  PorkFrom=excluded.PorkFrom,
  HogChoice=excluded.HogChoice,
  PorkChopsThicknessIn=excluded.PorkChopsThicknessIn,
  PorkChopsPerPackage=excluded.PorkChopsPerPackage,
  PorkLoinRoastLbsPerRoast=excluded.PorkLoinRoastLbsPerRoast,
  ShoulderChoice=excluded.ShoulderChoice,
  ShoulderRoastsLbsPerRoast=excluded.ShoulderRoastsLbsPerRoast,
  ShoulderSteaksThicknessIn=excluded.ShoulderSteaksThicknessIn,
  ShoulderSteaksPerPackage=excluded.ShoulderSteaksPerPackage,
  PicnicHamWholeHalfSliced=excluded.PicnicHamWholeHalfSliced,
  SpareRibsChoice=excluded.SpareRibsChoice,
  SpareRibsLbsPerCut=excluded.SpareRibsLbsPerCut,
  SpareRibsPiecesPerPackage=excluded.SpareRibsPiecesPerPackage,
  SpareRibsWholeSlabPerPackage=excluded.SpareRibsWholeSlabPerPackage,
  HamChoice=excluded.HamChoice,
  CuredHamPortion=excluded.CuredHamPortion,
  CuredHamSliceStyle=excluded.CuredHamSliceStyle,
  CuredHamSlicesPerPackage=excluded.CuredHamSlicesPerPackage,
  FreshLegPortion=excluded.FreshLegPortion,
  FreshLegCutIntoRoastsLbs=excluded.FreshLegCutIntoRoastsLbs,
  FreshLegProcessStyle=excluded.FreshLegProcessStyle,
  FreshLegSlicesOrSteaksPerPackage=excluded.FreshLegSlicesOrSteaksPerPackage,
  BaconChoice=excluded.BaconChoice,
  BaconLbsPerPackage=excluded.BaconLbsPerPackage,
  BaconSliceThickness=excluded.BaconSliceThickness,
  HamHocksChoice=excluded.HamHocksChoice,
  PutHamHocksIntoSausage=excluded.PutHamHocksIntoSausage,
  SausageSeasoning=excluded.SausageSeasoning,
  SausageBulk=excluded.SausageBulk,
  SausageBulkLbsPerPackage=excluded.SausageBulkLbsPerPackage,
  SausageRegularCased=excluded.SausageRegularCased,
  SausageRegularCasedLbsPerPackage=excluded.SausageRegularCasedLbsPerPackage,
  SausageSmallLink=excluded.SausageSmallLink,
  SausageSmallLinkLbsPerPackage=excluded.SausageSmallLinkLbsPerPackage,
  SausageNotes=excluded.SausageNotes,
  LiverChoice=excluded.LiverChoice,
  HeartChoice=excluded.HeartChoice,
  TongueChoice=excluded.TongueChoice,
  SpecialInstructions=excluded.SpecialInstructions;
"@

  Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $q | Out-Null
  $orderId
}