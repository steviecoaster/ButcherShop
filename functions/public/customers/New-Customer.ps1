function New-Customer {
<#
.SYNOPSIS
Create a new customer record.

.DESCRIPTION
Inserts a customer into the Customers table and returns the generated CustomerId.

.PARAMETER FirstName
Customer first name.

.PARAMETER LastName
Customer last name.

.EXAMPLE
(New-Customer -FirstName 'Jane' -LastName 'Doe' -Phone '555-1234').CustomerId

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $FirstName,

        [Parameter(Mandatory)]
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

    # Try to find existing customer by Email (preferred) or Phone
    $existing = $null
    if ($PSBoundParameters.ContainsKey('Email') -and -not [string]::IsNullOrWhiteSpace($Email)) {
        $existing = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT CustomerId FROM Customers WHERE lower(Email) = lower($(Sql-Text $Email)) LIMIT 1;" | Select-Object -First 1
    }

    if (-not $existing -and $PSBoundParameters.ContainsKey('Phone') -and -not [string]::IsNullOrWhiteSpace($Phone)) {
        $existing = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT CustomerId FROM Customers WHERE Phone = $(Sql-Text $Phone) LIMIT 1;" | Select-Object -First 1
    }

    if ($existing) {
        # Update any provided fields on the existing customer
        $cid = $existing.CustomerId
        $sets = @()
        if ($PSBoundParameters.ContainsKey('FirstName')) { $sets += "FirstName = $(Sql-Text $FirstName)" }
        if ($PSBoundParameters.ContainsKey('LastName'))  { $sets += "LastName  = $(Sql-Text $LastName)" }
        if ($PSBoundParameters.ContainsKey('Phone'))     { $sets += "Phone     = $(Sql-Text $Phone)" }
        if ($PSBoundParameters.ContainsKey('Email'))     { $sets += "Email     = $(Sql-Text $Email)" }
        if ($PSBoundParameters.ContainsKey('Notes'))     { $sets += "Notes     = $(Sql-Text $Notes)" }

        if ($sets.Count -gt 0) {
            $upd = "UPDATE Customers SET " + ($sets -join ', ') + " WHERE CustomerId = $cid;"
            Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $upd | Out-Null
        }

    $row = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT CustomerId, FirstName, LastName, Phone, Email, Notes FROM Customers WHERE CustomerId = $cid;" | Select-Object -First 1
    if ($row) { Add-Member -InputObject $row -NotePropertyName Existing -NotePropertyValue $true -Force }
    return $row
    }

    # Insert new customer
    $q = @"
INSERT INTO Customers (FirstName, LastName, Phone, Email, Notes)
VALUES (
  $(Sql-Text $FirstName),
  $(Sql-Text $LastName),
  $(Sql-Text $Phone),
  $(Sql-Text $Email),
  $(Sql-Text $Notes)
)
RETURNING CustomerId, FirstName, LastName, Phone, Email, Notes;
"@

    $new = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $q | Select-Object -First 1
    if ($new) { Add-Member -InputObject $new -NotePropertyName Existing -NotePropertyValue $false -Force }
    return $new
}