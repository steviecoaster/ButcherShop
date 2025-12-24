function Search-Customer {
<#
.SYNOPSIS
Search customers by name or phone.

.DESCRIPTION
Performs a simple search against the Customers table and returns matching rows.

.PARAMETER Query
Search text to match against first/last name or phone.

.EXAMPLE
Search-Customer -Query 'McConnell'

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Query,
        [Parameter()][int]$Max = 50
    )

    $q = Escape-SqliteString $Query
    $like = "'%$q%'"

    $sql = @"
SELECT *
FROM Customers
WHERE
  FirstName LIKE $like
  OR LastName LIKE $like
  OR Phone LIKE $like
  OR Email LIKE $like
ORDER BY LastName, FirstName
LIMIT $Max;
"@

    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql
}