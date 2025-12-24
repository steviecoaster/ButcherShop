function Get-Customer {
<#
    .SYNOPSIS
Retrieve customer records.

.DESCRIPTION
When -CustomerId is provided returns the customer row as an object or $null if not found.
When no -CustomerId is provided returns all customers (useful for listing).

.PARAMETER CustomerId
Optional numeric identifier of the customer. When omitted, all customers are returned.

.EXAMPLE
Get-Customer
.EXAMPLE
Get-Customer -CustomerId 1

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]
        $CustomerId
    )

    if ($PSBoundParameters.ContainsKey('CustomerId')) {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM Customers WHERE CustomerId = $CustomerId;" | Select-Object -First 1
    }
    else {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM Customers ORDER BY LastName, FirstName;"
    }
}