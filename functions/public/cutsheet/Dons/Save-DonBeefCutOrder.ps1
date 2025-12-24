function Save-DonBeefCutOrder {
  <#
.SYNOPSIS
Persist a Don beef cut order to the database.

.DESCRIPTION
Inserts or updates a Don beef cut sheet row. Accepts the object produced by New-DonBeefCutOrder.

.PARAMETER CutOrder
The cut order object to save.

.EXAMPLE
$cut = New-DonBeefCutOrder -OrderId 100
Save-DonBeefCutOrder -CutOrder $cut

#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [hashtable]
    $CutOrder)

  if (-not $CutOrder.OrderId) { throw "Save-DonBeefCutOrder: CutOrder.OrderId is required." }
  $orderId = [int]$CutOrder.OrderId

  $q = @"
INSERT INTO DonBeefCutSheets (
  OrderId,
  CutFor, Phone, BeefFrom,
  RibSteakThicknessIn, RibSteakPerPackage,
  RibEyeThicknessIn, RibEyePerPackage,
  RibRoastChoice, RibRoastLbsPerRoast,
  ChuckRoastLbsPerRoast, ArmEnglishRoastLbsPerRoast,
  BeefShortRibsChoice, BeefShortRibsLbsPerPackage, BeefShortRibsPackagesWanted,
  TBoneThicknessIn, TBonePerPackage,
  PorterhouseThicknessIn, PorterhousePerPackage,
  SirloinThicknessIn, SirloinPerPackage,
  RoundTipChoice, RoundTipRoastLbsEach, RoundTipSteakThicknessIn, RoundTipSteakPerPackage,
  RoundSteakChoice, RoundSteakThicknessIn, PlainRoundSteakWholePerPackage, PlainRoundSteakHalfPerPackage, CubedSteakServingSizePerPackage,
  TopRoundLbsPerRoast, BottomRoundLbsPerRoast, EyeOfRoundLbsPerRoast,
  RumpRoastChoice, RumpRoastLbsPerRoast,
  PotRoastChoice, PotRoastLbsPerRoast,
  StewMeatChoice, StewMeatLbsPerPackage, StewMeatTotalPackages,
  SoupBoilingBonesChoice, SoupBoilingBonesTotalPackages,
  PlateBoilChoice, PlateBoilTotalPackages,
  ShankCrossCutChoice, ShankCrossCutTotalPackages,
  CircleChoice,
  GroundBeefLbsPerPackage, PattiesPerPackage, HowMuchMadeInPattiesLbs,
  SpecialInstructions
)
VALUES (
  $orderId,
  $(Sql-Text $CutOrder.CutFor), $(Sql-Text $CutOrder.Phone), $(Sql-Text $CutOrder.BeefFrom),
  $(Sql-Num $CutOrder.RibSteakThicknessIn), $(Sql-Num $CutOrder.RibSteakPerPackage),
  $(Sql-Num $CutOrder.RibEyeThicknessIn), $(Sql-Num $CutOrder.RibEyePerPackage),
  $(Sql-Text $CutOrder.RibRoastChoice), $(Sql-Num $CutOrder.RibRoastLbsPerRoast),
  $(Sql-Num $CutOrder.ChuckRoastLbsPerRoast), $(Sql-Num $CutOrder.ArmEnglishRoastLbsPerRoast),
  $(Sql-Text $CutOrder.BeefShortRibsChoice), $(Sql-Num $CutOrder.BeefShortRibsLbsPerPackage), $(Sql-Num $CutOrder.BeefShortRibsPackagesWanted),
  $(Sql-Num $CutOrder.TBoneThicknessIn), $(Sql-Num $CutOrder.TBonePerPackage),
  $(Sql-Num $CutOrder.PorterhouseThicknessIn), $(Sql-Num $CutOrder.PorterhousePerPackage),
  $(Sql-Num $CutOrder.SirloinThicknessIn), $(Sql-Num $CutOrder.SirloinPerPackage),
  $(Sql-Text $CutOrder.RoundTipChoice), $(Sql-Num $CutOrder.RoundTipRoastLbsEach), $(Sql-Num $CutOrder.RoundTipSteakThicknessIn), $(Sql-Num $CutOrder.RoundTipSteakPerPackage),
  $(Sql-Text $CutOrder.RoundSteakChoice), $(Sql-Num $CutOrder.RoundSteakThicknessIn), $(Sql-Num $CutOrder.PlainRoundSteakWholePerPackage), $(Sql-Num $CutOrder.PlainRoundSteakHalfPerPackage), $(Sql-Num $CutOrder.CubedSteakServingSizePerPackage),
  $(Sql-Num $CutOrder.TopRoundLbsPerRoast), $(Sql-Num $CutOrder.BottomRoundLbsPerRoast), $(Sql-Num $CutOrder.EyeOfRoundLbsPerRoast),
  $(Sql-Text $CutOrder.RumpRoastChoice), $(Sql-Num $CutOrder.RumpRoastLbsPerRoast),
  $(Sql-Text $CutOrder.PotRoastChoice), $(Sql-Num $CutOrder.PotRoastLbsPerRoast),
  $(Sql-Text $CutOrder.StewMeatChoice), $(Sql-Num $CutOrder.StewMeatLbsPerPackage), $(Sql-Num $CutOrder.StewMeatTotalPackages),
  $(Sql-Text $CutOrder.SoupBoilingBonesChoice), $(Sql-Num $CutOrder.SoupBoilingBonesTotalPackages),
  $(Sql-Text $CutOrder.PlateBoilChoice), $(Sql-Num $CutOrder.PlateBoilTotalPackages),
  $(Sql-Text $CutOrder.ShankCrossCutChoice), $(Sql-Num $CutOrder.ShankCrossCutTotalPackages),
  $(Sql-Text $CutOrder.CircleChoice),
  $(Sql-Num $CutOrder.GroundBeefLbsPerPackage), $(Sql-Num $CutOrder.PattiesPerPackage), $(Sql-Num $CutOrder.HowMuchMadeInPattiesLbs),
  $(Sql-Text $CutOrder.SpecialInstructions)
)
ON CONFLICT(OrderId) DO UPDATE SET
  CutFor=excluded.CutFor,
  Phone=excluded.Phone,
  BeefFrom=excluded.BeefFrom,
  RibSteakThicknessIn=excluded.RibSteakThicknessIn,
  RibSteakPerPackage=excluded.RibSteakPerPackage,
  RibEyeThicknessIn=excluded.RibEyeThicknessIn,
  RibEyePerPackage=excluded.RibEyePerPackage,
  RibRoastChoice=excluded.RibRoastChoice,
  RibRoastLbsPerRoast=excluded.RibRoastLbsPerRoast,
  ChuckRoastLbsPerRoast=excluded.ChuckRoastLbsPerRoast,
  ArmEnglishRoastLbsPerRoast=excluded.ArmEnglishRoastLbsPerRoast,
  BeefShortRibsChoice=excluded.BeefShortRibsChoice,
  BeefShortRibsLbsPerPackage=excluded.BeefShortRibsLbsPerPackage,
  BeefShortRibsPackagesWanted=excluded.BeefShortRibsPackagesWanted,
  TBoneThicknessIn=excluded.TBoneThicknessIn,
  TBonePerPackage=excluded.TBonePerPackage,
  PorterhouseThicknessIn=excluded.PorterhouseThicknessIn,
  PorterhousePerPackage=excluded.PorterhousePerPackage,
  SirloinThicknessIn=excluded.SirloinThicknessIn,
  SirloinPerPackage=excluded.SirloinPerPackage,
  RoundTipChoice=excluded.RoundTipChoice,
  RoundTipRoastLbsEach=excluded.RoundTipRoastLbsEach,
  RoundTipSteakThicknessIn=excluded.RoundTipSteakThicknessIn,
  RoundTipSteakPerPackage=excluded.RoundTipSteakPerPackage,
  RoundSteakChoice=excluded.RoundSteakChoice,
  RoundSteakThicknessIn=excluded.RoundSteakThicknessIn,
  PlainRoundSteakWholePerPackage=excluded.PlainRoundSteakWholePerPackage,
  PlainRoundSteakHalfPerPackage=excluded.PlainRoundSteakHalfPerPackage,
  CubedSteakServingSizePerPackage=excluded.CubedSteakServingSizePerPackage,
  TopRoundLbsPerRoast=excluded.TopRoundLbsPerRoast,
  BottomRoundLbsPerRoast=excluded.BottomRoundLbsPerRoast,
  EyeOfRoundLbsPerRoast=excluded.EyeOfRoundLbsPerRoast,
  RumpRoastChoice=excluded.RumpRoastChoice,
  RumpRoastLbsPerRoast=excluded.RumpRoastLbsPerRoast,
  PotRoastChoice=excluded.PotRoastChoice,
  PotRoastLbsPerRoast=excluded.PotRoastLbsPerRoast,
  StewMeatChoice=excluded.StewMeatChoice,
  StewMeatLbsPerPackage=excluded.StewMeatLbsPerPackage,
  StewMeatTotalPackages=excluded.StewMeatTotalPackages,
  SoupBoilingBonesChoice=excluded.SoupBoilingBonesChoice,
  SoupBoilingBonesTotalPackages=excluded.SoupBoilingBonesTotalPackages,
  PlateBoilChoice=excluded.PlateBoilChoice,
  PlateBoilTotalPackages=excluded.PlateBoilTotalPackages,
  ShankCrossCutChoice=excluded.ShankCrossCutChoice,
  ShankCrossCutTotalPackages=excluded.ShankCrossCutTotalPackages,
  CircleChoice=excluded.CircleChoice,
  GroundBeefLbsPerPackage=excluded.GroundBeefLbsPerPackage,
  PattiesPerPackage=excluded.PattiesPerPackage,
  HowMuchMadeInPattiesLbs=excluded.HowMuchMadeInPattiesLbs,
  SpecialInstructions=excluded.SpecialInstructions;
"@

  Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $q | Out-Null
  $orderId
}