function Convert-SlotToCalendarEvent {
<#
.SYNOPSIS
Convert a DailySlots row into a UI calendar event object.

.DESCRIPTION
Transforms a database DailySlots record into a lightweight object used by the UI/calendar pages.

.PARAMETER Slot
The DailySlots record to convert.

.EXAMPLE
Convert-SlotToCalendarEvent -Slot $slot

#>
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Slots)

    foreach ($s in @($Slots)) {
        # Hide empty scaffold days (0/0); comment out if you want them shown
        if ((($s.TotalSlots -as [int]) -eq 0) -and (($s.ReservedPortionUnits -as [int]) -eq 0)) { continue }

        $date = [DateTime]$s.SlotDate
        $shop = if ($s.Shop) { $s.Shop } else { 'Don' }

        $availablePortions = [int]$s.AvailablePortionUnits
        $availableAnimals = [int]$s.AvailableAnimals
        $title = "{0} ({1}): {2} portions ({3} animals) of {4} total animals" -f $s.Species, $shop, $availablePortions, $availableAnimals, $s.TotalSlots

        @{
            id     = "$($s.Species)-$($shop)-$($date.ToString('yyyy-MM-dd'))"
            title  = $title
            start  = $date.ToString('yyyy-MM-dd')
            allDay = $true
            extendedProps = @{
                SlotDate             = $date.ToString('yyyy-MM-dd')
                Species              = $s.Species
                Shop                 = $shop
                TotalSlots           = [int]$s.TotalSlots
                ReservedPortionUnits = [int]$s.ReservedPortionUnits
                AvailablePortionUnits = [int]$s.AvailablePortionUnits
                AvailableAnimals     = [int]$s.AvailableAnimals
            }
        }
    }
}
