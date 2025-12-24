function Get-OrdersByMonth {
<#
.SYNOPSIS
Return Orders (joined with customer) for a given month and shop.

.PARAMETER Year
The numeric year.

.PARAMETER Month
The numeric month (1-12).

.PARAMETER Shop
Optional shop filter (Don or McConnell). If omitted, returns orders for all shops.

.EXAMPLE
Get-OrdersByMonth -Year 2025 -Month 12 -Shop Don
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$Year,
        [Parameter(Mandatory)][int]$Month,
        [string]$Shop
    )

    $start = Get-Date -Year $Year -Month $Month -Day 1
    $end = $start.AddMonths(1)
    $startStr = $start.ToString('yyyy-MM-dd')
    $endStr   = $end.ToString('yyyy-MM-dd')

    $shopFilter = if ($Shop) { "AND o.SlotShop = '$Shop'" } else { "" }

    $query = @"
SELECT
  o.*,
  c.FirstName,
  c.LastName,
  c.Phone AS CustomerPhone,
  c.Email AS CustomerEmail
FROM Orders o
JOIN Customers c ON c.CustomerId = o.CustomerId
WHERE o.SlotDate >= '$startStr'
  AND o.SlotDate <  '$endStr'
  $shopFilter
ORDER BY o.SlotDate;
"@

    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}
