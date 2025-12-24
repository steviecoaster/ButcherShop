function Add-AvailableSlot {
<#
.SYNOPSIS
Add or update available booking slots for a given date and species.

.DESCRIPTION
Creates or updates the DailySlots row for the specified species and date, adjusting TotalSlots and ReservedSlots as appropriate.

.PARAMETER Date
The date for which to set availability.

.PARAMETER Species
Species name (e.g., Beef, Hog).

.PARAMETER TotalSlots
Total number of slots available for the date/species.

.EXAMPLE
Add-AvailableSlot -Date (Get-Date) -Species Beef -TotalSlots 10

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][DateTime]$Date,
        [Parameter(Mandatory)][ValidateSet('Beef','Hog')][string]$Type,
        [Parameter()][ValidateSet('Don','McConnell')][string]$Shop = 'Don',
        [Parameter()][int]$SlotCount = 1,
        [Parameter()][ValidateSet('Set','Add')][string]$Mode = 'Set'
    )

    $d = $Date.ToString('yyyy-MM-dd')
    $setExpr = if ($Mode -eq 'Set') { "$SlotCount" } else { "TotalSlots + $SlotCount" }

        $query = @"
INSERT INTO DailySlots (SlotDate, Species, Shop, TotalSlots, ReservedSlots)
VALUES ('$d', '$Type', '$Shop', $SlotCount, 0)
ON CONFLICT(SlotDate, Species, Shop) DO UPDATE SET
    TotalSlots = $setExpr;
"@

    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query | Out-Null
}