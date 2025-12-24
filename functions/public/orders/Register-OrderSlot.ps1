function Register-OrderSlot {
<#
.SYNOPSIS
Register an order into a booking slot.

.DESCRIPTION
Performs a transaction to reserve a slot for an order by decrementing available slots and updating the Orders row.

.PARAMETER OrderId
Numeric OrderId to register.

.EXAMPLE
Register-OrderSlot -OrderId 42

#>
    <#
      Books an order onto a DailySlots day:
        - sets Orders.SlotDate
        - increments DailySlots.ReservedSlots
      If the DailySlots row doesn't exist yet, it will be created with TotalSlots=0
      and the increment will fail the CHECK (ReservedSlots <= TotalSlots).
      So: ensure you created slots first (Add-AvailableSlot), or set TotalSlots > 0.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,
        [Parameter(Mandatory)][DateTime]$SlotDate,
        [Parameter()][ValidateScript({ $_ -eq $null -or $_ -eq '' -or @('Don','McConnell') -contains $_ })][string]$Shop
    )

    $order = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT Species, SlotDate, SlotShop, Portion FROM Orders WHERE OrderId = $OrderId;" | Select-Object -First 1
    if (-not $order) { throw "Register-OrderSlot: OrderId $OrderId not found." }

    $species = $order.Species
    $newDate = $SlotDate.ToString('yyyy-MM-dd')
    if (-not $Shop -or $Shop -eq '') { $Shop = $order.SlotShop }
    if (-not $Shop -or $Shop -eq '') { $Shop = 'Don' }

    # If already booked, we adjust portion-unit counts (decrement old, increment new)
    $oldDate = $order.SlotDate
    $portion = $order.Portion
    function Convert-PortionToUnits([string]$p) {
        switch ($p) {
            'Whole'   { return 4 }
            'Half'    { return 2 }
            default   { return 0 }
        }
    }

    $units = Convert-PortionToUnits $portion

    $tx = @("BEGIN TRANSACTION;")

    if ($oldDate) {
        $oldShop = $order.SlotShop
        if (-not $oldShop -or $oldShop -eq '') { $oldShop = 'Don' }
        # Decrement both the animal reservation count and the portion units
        $tx += "UPDATE DailySlots SET ReservedSlots = CASE WHEN ReservedSlots > 0 THEN ReservedSlots - 1 ELSE 0 END, ReservedPortionUnits = CASE WHEN ReservedPortionUnits >= $units THEN ReservedPortionUnits - $units ELSE 0 END WHERE SlotDate = '$oldDate' AND Species = '$species' AND Shop = '$oldShop';"
    }

    $tx += "UPDATE Orders SET SlotDate = '$newDate', SlotShop = '$Shop', UpdatedAt = CURRENT_TIMESTAMP WHERE OrderId = $OrderId;"
    $tx += "UPDATE DailySlots SET ReservedSlots = ReservedSlots + 1, ReservedPortionUnits = ReservedPortionUnits + $units WHERE SlotDate = '$newDate' AND Species = '$species' AND Shop = '$Shop';"
    $tx += "COMMIT;"

    try {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query ($tx -join "`n") | Out-Null
        return $true
    }
    catch {
        # Attempt rollback if COMMIT didn't happen
        try { Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "ROLLBACK;" | Out-Null } catch {}
        throw "Register-OrderSlot failed: $($_.Exception.Message)"
    }
}
