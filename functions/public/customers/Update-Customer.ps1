function Update-Customer {
<#
.SYNOPSIS
Update an existing customer record.

.DESCRIPTION
Updates contact fields for an existing customer identified by CustomerId.

.PARAMETER CustomerId
Numeric CustomerId to update.

.EXAMPLE
Update-Customer -CustomerId 1 -Phone '555-9999'

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]
        $CustomerId,
        [Parameter()]
        [string]
        $FirstName,
        [Parameter()]
        [string]
        $LastName,
        [Parameter()]
        [string]
        $Phone,
        [Parameter()]
        [string]
        $Email,
        [Parameter()]
        [string]
        $Notes
    )

    $updates = @()

    if ($PSBoundParameters.ContainsKey('FirstName')) { $updates += "FirstName = $(Sql-Text $FirstName)" }
    if ($PSBoundParameters.ContainsKey('LastName'))  { $updates += "LastName  = $(Sql-Text $LastName)" }
    if ($PSBoundParameters.ContainsKey('Phone'))     { $updates += "Phone     = $(Sql-Text $Phone)" }
    if ($PSBoundParameters.ContainsKey('Email'))     { $updates += "Email     = $(Sql-Text $Email)" }
    if ($PSBoundParameters.ContainsKey('Notes'))     { $updates += "Notes     = $(Sql-Text $Notes)" }

    if ($updates.Count -eq 0) { return }

    $sql = "UPDATE Customers SET {0} WHERE CustomerId = {1};" -f ($updates -join ", "), $CustomerId
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql | Out-Null
}