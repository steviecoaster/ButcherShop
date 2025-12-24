function New-McConnellHogCutOrder {
<#
.SYNOPSIS
Create an in-memory McConnell hog cut order object.

.DESCRIPTION
Constructs a PSCustomObject for McConnell-style hog/pork cut sheets. Use Save-DonBeefCutOrder to persist (shares the same storage schema).

.PARAMETER OrderId
OrderId (required).

.EXAMPLE
$cut = New-McConnellHogCutOrder -OrderId 100

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
function New-McConnellHogCutOrder {
<#
.SYNOPSIS
Create an in-memory McConnell hog cut order object.

.DESCRIPTION
Constructs an ordered hashtable that mirrors the McConnell hog cut sheet schema. Use Save-McConnellHogCutOrder to persist.

.PARAMETER OrderId
Numeric OrderId from the Orders table (required).

.EXAMPLE
$cut = New-McConnellHogCutOrder -OrderId 43 -CustomerName 'Acme Hog'

#>
    <#
      Creates an in-memory object matching the McConnell hog cut sheet table.
      This is modeled to save 1:1 into McConnellHogCutSheets.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,

        [Parameter()][string]$CustomerName,
        [Parameter()][string]$Phone,

        [Parameter(Mandatory)]
        [ValidateSet('Whole','Half')]
        [string]$HogPortion,

        [Parameter()][double]$HangingWeight,

        # Chops / loin
        [Parameter()][int]$PorkChopsPerPackage,
        [Parameter()][string]$ChopThickness,
        [Parameter()][ValidateSet('Fresh','CuredSmoked')]
        [string]$ChopStyle,

        [Parameter()][double]$LoinRoastSizeLbs,
        [Parameter()][bool]$NoLoinRoast,

        # Bacon / ribs / ham
        [Parameter()][ValidateSet('CuredSmoked','FreshSide')]
        [string]$BaconStyle,

        [Parameter()][bool]$CountryStyleRibs,

        [Parameter()][ValidateSet('Slab','Quartered')]
        [string]$SpareRibsStyle,

        [Parameter()][ValidateSet('CuredSmoked','Fresh')]
        [string]$HamStyle,

        [Parameter()][double]$HamSizeLbs,
        [Parameter()][bool]$HamSliced,
        [Parameter()][bool]$HamWhole,
        [Parameter()][bool]$HamHalved,

        # Shoulder
        [Parameter()][double]$ShoulderRoastSizeLbs,
        [Parameter()][int]$ShoulderSlicesPerPackage,
        [Parameter()][bool]$NoShoulder,

        # Grind / sausage
        [Parameter()][bool]$GroundPork,

        [Parameter()][bool]$SausageRegular,
        [Parameter()][bool]$SausageSweetItalian,
        [Parameter()][bool]$SausageHotItalian,

        [Parameter()][bool]$SausageBulk,
        [Parameter()][bool]$SausageBigLinks,
        [Parameter()][bool]$SausageSmallLinks,
        [Parameter()][bool]$SausageQuarterLbPatties,

        [Parameter()][string]$SpecialInstructions
    )

    [ordered]@{
        Schema = 'McConnellHogCutSheet.v1'
        OrderId = $OrderId

        CustomerName = $CustomerName
        Phone        = $Phone

        HogPortion     = $HogPortion
        HangingWeight  = $HangingWeight

        PorkChopsPerPackage = $PorkChopsPerPackage
        ChopThickness       = $ChopThickness
        ChopStyle           = $ChopStyle

        LoinRoastSizeLbs = $LoinRoastSizeLbs
        NoLoinRoast      = $NoLoinRoast

        BaconStyle        = $BaconStyle
        CountryStyleRibs  = $CountryStyleRibs
        SpareRibsStyle    = $SpareRibsStyle

        HamStyle   = $HamStyle
        HamSizeLbs = $HamSizeLbs
        HamSliced  = $HamSliced
        HamWhole   = $HamWhole
        HamHalved  = $HamHalved

        ShoulderRoastSizeLbs      = $ShoulderRoastSizeLbs
        ShoulderSlicesPerPackage  = $ShoulderSlicesPerPackage
        NoShoulder                = $NoShoulder

        GroundPork = $GroundPork

        SausageRegular      = $SausageRegular
        SausageSweetItalian = $SausageSweetItalian
        SausageHotItalian   = $SausageHotItalian

        SausageBulk            = $SausageBulk
        SausageBigLinks        = $SausageBigLinks
        SausageSmallLinks      = $SausageSmallLinks
        SausageQuarterLbPatties = $SausageQuarterLbPatties

        SpecialInstructions = $SpecialInstructions
    }
}