function New-DonHogCutOrder {
<#
.SYNOPSIS
Create an in-memory Don hog cut order object using pork-named parameters only.

.DESCRIPTION
This constructor only accepts parameters that reflect the pork cutsheet fields. It returns an
ordered PSCustomObject shaped exactly like the object `Save-DonHogCutOrder` expects (pork-named keys).
No aliases or legacy beef-named parameters are accepted.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,

        [Parameter()][string]$CutFor,
        [Parameter()][string]$Phone,
        [Parameter()][string]$PorkFrom,
        [Parameter()][string]$CircleChoice,

        # Pork chops / loin
        [Parameter()][Nullable[decimal]]$PorkChopsThicknessIn,
        [Parameter()][Nullable[int]]$PorkChopsPerPackage,
        [Parameter()][Nullable[decimal]]$PorkLoinRoastLbsPerRoast,

        # Shoulder
        [Parameter()][string]$ShoulderChoice,
        [Parameter()][Nullable[decimal]]$ShoulderRoastsLbsPerRoast,
        [Parameter()][Nullable[decimal]]$ShoulderSteaksThicknessIn,
        [Parameter()][Nullable[int]]$ShoulderSteaksPerPackage,
        [Parameter()][string]$PicnicHamWholeHalfSliced,

        # Spare ribs
        [Parameter()][string]$SpareRibsChoice,
        [Parameter()][Nullable[decimal]]$SpareRibsLbsPerCut,
        [Parameter()][Nullable[int]]$SpareRibsPiecesPerPackage,
        [Parameter()][Nullable[int]]$SpareRibsWholeSlabPerPackage,

        # Hams
        [Parameter()][string]$HamChoice,
        [Parameter()][string]$CuredHamPortion,
        [Parameter()][string]$CuredHamSliceStyle,
        [Parameter()][Nullable[int]]$CuredHamSlicesPerPackage,

        # Fresh leg
        [Parameter()][string]$FreshLegPortion,
        [Parameter()][Nullable[decimal]]$FreshLegCutIntoRoastsLbs,
        [Parameter()][string]$FreshLegProcessStyle,
        [Parameter()][Nullable[int]]$FreshLegSlicesOrSteaksPerPackage,

        # Bacon
        [Parameter()][string]$BaconChoice,
        [Parameter()][Nullable[decimal]]$BaconLbsPerPackage,
        [Parameter()][string]$BaconSliceThickness,

        # Ham hocks
        [Parameter()][string]$HamHocksChoice,
        [Parameter()][bool]$PutHamHocksIntoSausage = $false,

        # Sausage
        [Parameter()][string]$SausageSeasoning,
        [Parameter()][bool]$SausageBulk = $false,
        [Parameter()][Nullable[decimal]]$SausageBulkLbsPerPackage,
        [Parameter()][bool]$SausageRegularCased = $false,
        [Parameter()][Nullable[decimal]]$SausageRegularCasedLbsPerPackage,
        [Parameter()][bool]$SausageSmallLink = $false,
        [Parameter()][Nullable[decimal]]$SausageSmallLinkLbsPerPackage,
        [Parameter()][string]$SausageNotes,

        # Offal
        [Parameter()][string]$LiverChoice,
        [Parameter()][string]$HeartChoice,
        [Parameter()][string]$TongueChoice,

        [Parameter()][string]$SpecialInstructions
    )

    [ordered]@{
        Schema  = 'DonPorkCutSheet.v1'
        OrderId = $OrderId

        CutFor  = $CutFor
        Phone   = $Phone
        PorkFrom= $PorkFrom
        HogChoice = $CircleChoice

        PorkChopsThicknessIn = $PorkChopsThicknessIn
        PorkChopsPerPackage  = $PorkChopsPerPackage
        PorkLoinRoastLbsPerRoast = $PorkLoinRoastLbsPerRoast

        ShoulderChoice = $ShoulderChoice
        ShoulderRoastsLbsPerRoast = $ShoulderRoastsLbsPerRoast
        ShoulderSteaksThicknessIn = $ShoulderSteaksThicknessIn
        ShoulderSteaksPerPackage = $ShoulderSteaksPerPackage
        PicnicHamWholeHalfSliced = $PicnicHamWholeHalfSliced

        SpareRibsChoice = $SpareRibsChoice
        SpareRibsLbsPerCut = $SpareRibsLbsPerCut
        SpareRibsPiecesPerPackage = $SpareRibsPiecesPerPackage
        SpareRibsWholeSlabPerPackage = $SpareRibsWholeSlabPerPackage

        HamChoice = $HamChoice
        CuredHamPortion = $CuredHamPortion
        CuredHamSliceStyle = $CuredHamSliceStyle
        CuredHamSlicesPerPackage = $CuredHamSlicesPerPackage

        FreshLegPortion = $FreshLegPortion
        FreshLegCutIntoRoastsLbs = $FreshLegCutIntoRoastsLbs
        FreshLegProcessStyle = $FreshLegProcessStyle
        FreshLegSlicesOrSteaksPerPackage = $FreshLegSlicesOrSteaksPerPackage

        BaconChoice = $BaconChoice
        BaconLbsPerPackage = $BaconLbsPerPackage
        BaconSliceThickness = $BaconSliceThickness

        HamHocksChoice = $HamHocksChoice
        PutHamHocksIntoSausage = $PutHamHocksIntoSausage

        SausageSeasoning = $SausageSeasoning
        SausageBulk = $SausageBulk
        SausageBulkLbsPerPackage = $SausageBulkLbsPerPackage
        SausageRegularCased = $SausageRegularCased
        SausageRegularCasedLbsPerPackage = $SausageRegularCasedLbsPerPackage
        SausageSmallLink = $SausageSmallLink
        SausageSmallLinkLbsPerPackage = $SausageSmallLinkLbsPerPackage
        SausageNotes = $SausageNotes

        LiverChoice = $LiverChoice
        HeartChoice = $HeartChoice
        TongueChoice = $TongueChoice

        SpecialInstructions = $SpecialInstructions
    }
}
