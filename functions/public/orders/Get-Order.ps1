function Get-Order {
  <#
.SYNOPSIS
Gets orders from the database.

.DESCRIPTION
When called with -OrderId returns the single order object. When called without parameters, returns all orders.

.PARAMETER OrderId
The numeric identifier of the order to return. If omitted, all orders are returned.

.EXAMPLE
Get-Order -OrderId 42

.EXAMPLE
Get-Order

Retrieves all orders.
#>
  [CmdletBinding()]
  param(
    [Parameter()]
    [int]
    $OrderId
  )

  if ($PSBoundParameters.ContainsKey('OrderId')) {
    # Single-order path (backwards-compatible)
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query @"
SELECT
  o.*,
  c.FirstName,
  c.LastName,
  c.Phone AS CustomerPhone,
  c.Email AS CustomerEmail
FROM Orders o
JOIN Customers c ON c.CustomerId = o.CustomerId
WHERE o.OrderId = $OrderId;
"@ | Select-Object -First 1
  }
  else {
    # No OrderId provided => return all orders
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query @"
SELECT
  o.*,
  c.FirstName,
  c.LastName,
  c.Phone AS CustomerPhone,
  c.Email AS CustomerEmail
FROM Orders o
JOIN Customers c ON c.CustomerId = o.CustomerId
ORDER BY o.OrderId;
"@
  }
}