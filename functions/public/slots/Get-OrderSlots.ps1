function Get-OrderSlots {
<##
.SYNOPSIS
Convenience wrapper around Get-AvailableSlot that normalizes inputs and optionally returns UI-friendly select options.

.DESCRIPTION
Get-OrderSlots accepts the same concepts as Get-AvailableSlot but provides shorter parameter names, portion shortcuts ('w','h'), and an option to return an array of @{ Name = 'label'; Value = value } objects suitable for binding to New-UDSelect/Select input.

.PARAMETER Date
Single date to query.

.PARAMETER YearOnly
Year to query for entire year.

.PARAMETER Month
Month name when querying by month.

.PARAMETER Year
Year when querying by month.

.PARAMETER Type
Species (Beef/Hog/All)

.PARAMETER Shop
Shop (Don/McConnell/All)

.PARAMETER Portion
Portion (Whole/Half). Shortcuts 'w' and 'h' are accepted.

.PARAMETER OnlyAvailable
Switch to filter only available rows.

.PARAMETER ForUI
When present returns PSCustomObjects with Name/Value fields for UI selects.

.EXAMPLE
Get-OrderSlots -YearOnly 2025 -Type Beef -OnlyAvailable

.EXAMPLE
Get-OrderSlots -Date (Get-Date '2025-12-25') -Type Beef -Shop Don -Portion w -OnlyAvailable -ForUI

#>
    [CmdletBinding()]
    param(
        [DateTime]$Date,
        [int]$YearOnly,
        [string]$Month,
        [int]$Year,
        [string]$Type = 'All',
        [string]$Shop = 'All',
        [string]$Portion,
        [switch]$OnlyAvailable,
        [switch]$ForUI
    )

    # normalize portion shortcuts
    if ($Portion) {
        switch ($Portion.ToLower()) {
            'w' { $Portion = 'Whole' }
            'h' { $Portion = 'Half' }
            default { $Portion = ($Portion.Substring(0,1).ToUpper() + $Portion.Substring(1).ToLower()) }
        }
    }

    # Choose which underlying call based on parameters
    if ($PSBoundParameters.ContainsKey('Date')) {
        $rows = Get-AvailableSlot -Date $Date -Type $Type -Shop $Shop -Portion $Portion -OnlyAvailable:$OnlyAvailable
    }
    elseif ($PSBoundParameters.ContainsKey('YearOnly')) {
        $rows = Get-AvailableSlot -YearOnly $YearOnly -Type $Type -Shop $Shop -Portion $Portion -OnlyAvailable:$OnlyAvailable
    }
    else {
        if (-not $Month) { $Month = (Get-Date).ToString('MMMM') }
        if (-not $Year)  { $Year  = (Get-Date).Year }
        $rows = Get-AvailableSlot -Month $Month -Year $Year -Type $Type -Shop $Shop -Portion $Portion -OnlyAvailable:$OnlyAvailable
    }

    if ($ForUI) {
        # Convert to Name/Value objects suitable for New-UDSelect
        return $rows | ForEach-Object {
            $slotDate = $_.SlotDate
            $label = "{0} — {1} portions ({2} animals) available — {3}" -f ((Get-Date $slotDate).ToLongDateString()), $_.AvailablePortionUnits, $_.AvailableAnimals, $_.Shop
            [PSCustomObject]@{ Name = $label; Value = $slotDate }
        }
    }

    return $rows
}
