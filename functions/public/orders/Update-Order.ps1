function Update-Order {
<#
.SYNOPSIS
Update fields on an existing order.

.DESCRIPTION
Performs an UPDATE on the Orders table for the specified OrderId. Only parameters supplied are applied; unspecified fields are left unchanged. The function is idempotent for missing parameters (it returns immediately if no update fields are provided).

.PARAMETER OrderId
The numeric identifier of the order to update (required).

.PARAMETER Species
Optional. Species value (Beef or Hog).

.PARAMETER Portion
Optional. Portion value (Whole, Half, Quarter).

.PARAMETER DropOffDate
Optional. The requested drop-off date for the order.

.PARAMETER SlotDate
Optional. The booked slot date for the order; use Register-OrderSlot/Unregister-OrderSlot for slot management where appropriate.

Optional. Portion value (Whole, Half).
Optional. Estimated hanging weight (numeric).

.PARAMETER Status
Optional. Textual status of the order (e.g., 'Received', 'Processing').

.PARAMETER DueDate
Optional. The estimated completion/due date for the order.

.EXAMPLE
Update-Order -OrderId 42 -Status 'Processing' -EstimatedWeight 650

.EXAMPLE
Update-Order -OrderId 42 -SlotDate (Get-Date '2025-12-25')

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$OrderId,

        [Parameter()][ValidateSet('Beef', 'Hog')][string]$Species,
    [Parameter()][ValidateSet('Whole', 'Half')][string]$Portion,

        [Parameter()][DateTime]$DropOffDate,
        [Parameter()][DateTime]$SlotDate,
        [Parameter()][double]$EstimatedWeight,

        [Parameter()][string]$Status,
        [Parameter()][DateTime]$DueDate
    )

    $updates = @()

    if ($PSBoundParameters.ContainsKey('Species')) { $updates += "Species = '$Species'" }
    if ($PSBoundParameters.ContainsKey('Portion')) { $updates += "Portion = '$Portion'" }

    if ($PSBoundParameters.ContainsKey('DropOffDate')) { $updates += "DropOffDate = '$($DropOffDate.ToString('yyyy-MM-dd'))'" }
    if ($PSBoundParameters.ContainsKey('SlotDate')) { $updates += "SlotDate = '$($SlotDate.ToString('yyyy-MM-dd'))'" }
    if ($PSBoundParameters.ContainsKey('EstimatedWeight')) { $updates += "EstimatedWeight = $EstimatedWeight" }

    if ($PSBoundParameters.ContainsKey('Status')) { $updates += "Status = $(Sql-Text $Status)" }
    if ($PSBoundParameters.ContainsKey('DueDate')) { $updates += "DueDate = '$($DueDate.ToString('yyyy-MM-dd'))'" }

    if ($updates.Count -eq 0) { return }

    $updates += "UpdatedAt = CURRENT_TIMESTAMP"

    $sql = "UPDATE Orders SET {0} WHERE OrderId = {1};" -f ($updates -join ", "), $OrderId
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql | Out-Null
}