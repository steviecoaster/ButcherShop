function New-McConnellBeefCutOrder {
<#
.SYNOPSIS
Create an in-memory McConnell beef cut order object.

.DESCRIPTION
Constructs a PSCustomObject for McConnell-style beef cut sheets. Use Save-DonBeefCutOrder to persist (shares the same storage schema).

.PARAMETER OrderId
OrderId (required).

.EXAMPLE
$cut = New-McConnellBeefCutOrder -OrderId 100

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,

        [Parameter()][string]$CutFor,
        [Parameter()][string]$Phone,
        [Parameter()][string]$BeefFrom,

    [Parameter()][Nullable[decimal]]$RibSteakThicknessIn,
    [Parameter()][Nullable[int]]$RibSteakPerPackage,
    [Parameter()][Nullable[decimal]]$RibEyeThicknessIn,
    [Parameter()][Nullable[int]]$RibEyePerPackage,
        [Parameter()][ValidateSet('Yes','No')][string]$RibRoastChoice,
    [Parameter()][Nullable[decimal]]$RibRoastLbsPerRoast,

    [Parameter()][Nullable[decimal]]$ChuckRoastLbsPerRoast,
    [Parameter()][Nullable[decimal]]$ArmEnglishRoastLbsPerRoast,

        [Parameter()][ValidateSet('None','Some')][string]$BeefShortRibsChoice,
    [Parameter()][Nullable[decimal]]$BeefShortRibsLbsPerPackage,
    [Parameter()][Nullable[int]]$BeefShortRibsPackagesWanted,

    [Parameter()][Nullable[decimal]]$TBoneThicknessIn,
    [Parameter()][Nullable[int]]$TBonePerPackage,
    [Parameter()][Nullable[decimal]]$PorterhouseThicknessIn,
    [Parameter()][Nullable[int]]$PorterhousePerPackage,
    [Parameter()][Nullable[decimal]]$SirloinThicknessIn,
    [Parameter()][Nullable[int]]$SirloinPerPackage,

        [Parameter()][ValidateSet('Roast','Steaks','Both','None')][string]$RoundTipChoice,
    [Parameter()][Nullable[decimal]]$RoundTipRoastLbsEach,
    [Parameter()][Nullable[decimal]]$RoundTipSteakThicknessIn,
    [Parameter()][Nullable[int]]$RoundTipSteakPerPackage,

        [Parameter()][ValidateSet('AllPlain','HalfPlainHalfCubed','AllCubed')][string]$RoundSteakChoice,
    [Parameter()][Nullable[decimal]]$RoundSteakThicknessIn,
    [Parameter()][Nullable[int]]$PlainRoundSteakWholePerPackage,
    [Parameter()][Nullable[int]]$PlainRoundSteakHalfPerPackage,
    [Parameter()][Nullable[int]]$CubedSteakServingSizePerPackage,

    [Parameter()][Nullable[decimal]]$TopRoundLbsPerRoast,
    [Parameter()][Nullable[decimal]]$BottomRoundLbsPerRoast,
    [Parameter()][Nullable[decimal]]$EyeOfRoundLbsPerRoast,

        [Parameter()][ValidateSet('Yes','None')][string]$RumpRoastChoice,
    [Parameter()][Nullable[decimal]]$RumpRoastLbsPerRoast,

        [Parameter()][ValidateSet('Yes','None')][string]$PotRoastChoice,
    [Parameter()][Nullable[decimal]]$PotRoastLbsPerRoast,

        [Parameter()][ValidateSet('No','Yes')][string]$StewMeatChoice,
    [Parameter()][Nullable[decimal]]$StewMeatLbsPerPackage,
    [Parameter()][Nullable[int]]$StewMeatTotalPackages,

        [Parameter()][ValidateSet('No','Yes')][string]$SoupBoilingBonesChoice,
    [Parameter()][Nullable[int]]$SoupBoilingBonesTotalPackages,

        [Parameter()][ValidateSet('No','Yes')][string]$PlateBoilChoice,
    [Parameter()][Nullable[int]]$PlateBoilTotalPackages,

        [Parameter()][ValidateSet('No','Yes')][string]$ShankCrossCutChoice,
    [Parameter()][Nullable[int]]$ShankCrossCutTotalPackages,

    [Parameter()][string]$CircleChoice,

    [Parameter()][Nullable[decimal]]$GroundBeefLbsPerPackage,
    [Parameter()][Nullable[int]]$PattiesPerPackage,
    [Parameter()][Nullable[decimal]]$HowMuchMadeInPattiesLbs,

        [Parameter()][string]$SpecialInstructions
    )

    [ordered]@{
        Schema  = 'DonBeefCutSheet.v1'
        OrderId = $OrderId

        CutFor  = $CutFor
        Phone   = $Phone
        BeefFrom= $BeefFrom

        RibSteakThicknessIn = $RibSteakThicknessIn
        RibSteakPerPackage  = $RibSteakPerPackage
        RibEyeThicknessIn   = $RibEyeThicknessIn
        RibEyePerPackage    = $RibEyePerPackage
        RibRoastChoice      = $RibRoastChoice
        RibRoastLbsPerRoast = $RibRoastLbsPerRoast

        ChuckRoastLbsPerRoast = $ChuckRoastLbsPerRoast
        ArmEnglishRoastLbsPerRoast = $ArmEnglishRoastLbsPerRoast

        BeefShortRibsChoice = $BeefShortRibsChoice
        BeefShortRibsLbsPerPackage = $BeefShortRibsLbsPerPackage
        BeefShortRibsPackagesWanted = $BeefShortRibsPackagesWanted

        TBoneThicknessIn = $TBoneThicknessIn
        TBonePerPackage  = $TBonePerPackage
        PorterhouseThicknessIn = $PorterhouseThicknessIn
        PorterhousePerPackage  = $PorterhousePerPackage
        SirloinThicknessIn = $SirloinThicknessIn
        SirloinPerPackage  = $SirloinPerPackage

        RoundTipChoice           = $RoundTipChoice
        RoundTipRoastLbsEach     = $RoundTipRoastLbsEach
        RoundTipSteakThicknessIn = $RoundTipSteakThicknessIn
        RoundTipSteakPerPackage  = $RoundTipSteakPerPackage

        RoundSteakChoice = $RoundSteakChoice
        RoundSteakThicknessIn = $RoundSteakThicknessIn
        PlainRoundSteakWholePerPackage = $PlainRoundSteakWholePerPackage
        PlainRoundSteakHalfPerPackage  = $PlainRoundSteakHalfPerPackage
        CubedSteakServingSizePerPackage = $CubedSteakServingSizePerPackage

        TopRoundLbsPerRoast    = $TopRoundLbsPerRoast
        BottomRoundLbsPerRoast = $BottomRoundLbsPerRoast
        EyeOfRoundLbsPerRoast  = $EyeOfRoundLbsPerRoast

        RumpRoastChoice      = $RumpRoastChoice
        RumpRoastLbsPerRoast = $RumpRoastLbsPerRoast
        PotRoastChoice       = $PotRoastChoice
        PotRoastLbsPerRoast  = $PotRoastLbsPerRoast

        StewMeatChoice = $StewMeatChoice
        StewMeatLbsPerPackage = $StewMeatLbsPerPackage
        StewMeatTotalPackages = $StewMeatTotalPackages

        SoupBoilingBonesChoice = $SoupBoilingBonesChoice
        SoupBoilingBonesTotalPackages = $SoupBoilingBonesTotalPackages

        PlateBoilChoice = $PlateBoilChoice
        PlateBoilTotalPackages = $PlateBoilTotalPackages

        ShankCrossCutChoice = $ShankCrossCutChoice
        ShankCrossCutTotalPackages = $ShankCrossCutTotalPackages

        CircleChoice = $CircleChoice

        GroundBeefLbsPerPackage = $GroundBeefLbsPerPackage
        PattiesPerPackage = $PattiesPerPackage
        HowMuchMadeInPattiesLbs = $HowMuchMadeInPattiesLbs

        SpecialInstructions = $SpecialInstructions
    }
}
function New-McConnellBeefCutOrder {
<#
.SYNOPSIS
Create an in-memory McConnell beef cut order object.

.DESCRIPTION
Constructs a PSCustomObject that mirrors the McConnell beef cut sheet schema. Use the returned object with Save-McConnellBeefCutOrder to persist to the database.

.PARAMETER OrderId
Numeric OrderId from the Orders table (required).

.EXAMPLE
$cut = New-McConnellBeefCutOrder -OrderId 42 -CustomerName 'Acme'

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,

        [string]$CustomerName,
        [string]$Phone,
        [bool]$CallWhenReady,

        [ValidateSet('Whole','Half','FrontQuarter','HindQuarter')]
        [string]$BeefPortion,

        [double]$HangingWeight,

        [int]$SteaksPerPackage,
        [string]$SteakThickness,

        [double]$ArmRoastSizeLbs,
        [double]$ChuckRoastSizeLbs,
        [double]$RumpRoastSizeLbs,
        [double]$TipRoastSizeLbs,

        [int]$RoundSteaksPerPackage,
        [bool]$RoundSteakTenderized,
        [bool]$RoundSteakPlain,

        [bool]$ShortRibs,
        [bool]$StewMeat,

        [double]$BulkGroundPkgSizeLbs,
        [bool]$Patties,
        [ValidateSet('1/4','1/2')]
        [string]$PattySize,

        [bool]$Liver,
        [bool]$Heart,
        [bool]$Tongue,
        [bool]$SoupBones,

        [string]$SpecialInstructions
    )

    [pscustomobject]@{
        OrderId = $OrderId
        CustomerName = $CustomerName
        Phone = $Phone
        CallWhenReady = [int]$CallWhenReady
        BeefPortion = $BeefPortion
        HangingWeight = $HangingWeight

        SteaksPerPackage = $SteaksPerPackage
        SteakThickness = $SteakThickness

        ArmRoastSizeLbs = $ArmRoastSizeLbs
        ChuckRoastSizeLbs = $ChuckRoastSizeLbs
        RumpRoastSizeLbs = $RumpRoastSizeLbs
        TipRoastSizeLbs = $TipRoastSizeLbs

        RoundSteaksPerPackage = $RoundSteaksPerPackage
        RoundSteakTenderized = [int]$RoundSteakTenderized
        RoundSteakPlain = [int]$RoundSteakPlain

        ShortRibs = [int]$ShortRibs
        StewMeat = [int]$StewMeat

        BulkGroundPkgSizeLbs = $BulkGroundPkgSizeLbs
        Patties = [int]$Patties
        PattySize = $PattySize

        Liver = [int]$Liver
        Heart = [int]$Heart
        Tongue = [int]$Tongue
        SoupBones = [int]$SoupBones

        SpecialInstructions = $SpecialInstructions
    }
}
