function Unregister-OrderSlot {
<#
.SYNOPSIS
Remove an order's registration from a booking slot.

.DESCRIPTION
Increments the available slots and clears the SlotDate on the Orders row as part of a transaction.

.PARAMETER OrderId
Numeric OrderId to unregister.

.EXAMPLE
Unregister-OrderSlot -OrderId 42

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId
    )

    $order = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT Species, SlotDate, SlotShop, Portion FROM Orders WHERE OrderId = $OrderId;" | Select-Object -First 1
    if (-not $order) { throw "Unregister-OrderSlot: OrderId $OrderId not found." }
    if (-not $order.SlotDate) { return }

        $species = $order.Species
        $oldDate = $order.SlotDate
        $shop = $order.SlotShop
        if (-not $shop -or $shop -eq '') { $shop = 'Don' }

        function Convert-PortionToUnits([string]$p) {
            switch ($p) {
                'Whole'   { return 4 }
                'Half'    { return 2 }
                default   { return 0 }
            }
        }

        $units = Convert-PortionToUnits $order.Portion

        $tx = @(
                "BEGIN TRANSACTION;",
                "UPDATE Orders SET SlotDate = NULL, SlotShop = NULL, UpdatedAt = CURRENT_TIMESTAMP WHERE OrderId = $OrderId;",
                "UPDATE DailySlots SET ReservedSlots = CASE WHEN ReservedSlots > 0 THEN ReservedSlots - 1 ELSE 0 END, ReservedPortionUnits = CASE WHEN ReservedPortionUnits >= $units THEN ReservedPortionUnits - $units ELSE 0 END WHERE SlotDate = '$oldDate' AND Species = '$species' AND Shop = '$shop';",
                "COMMIT;"
            )

    try {
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query ($tx -join "`n") | Out-Null
    }
    catch {
        try { Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "ROLLBACK;" | Out-Null } catch {}
        throw "Unregister-OrderSlot failed: $($_.Exception.Message)"
    }
}