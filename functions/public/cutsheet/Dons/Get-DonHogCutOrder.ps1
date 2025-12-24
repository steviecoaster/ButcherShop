function Get-DonHogCutOrder {
<#
.SYNOPSIS
Retrieve a Don pork cut order.

.DESCRIPTION
Returns the Don pork cut order for the provided OrderId or $null if not found.

.PARAMETER OrderId
The numeric order identifier.

.EXAMPLE
Get-DonPorkCutOrder -OrderId 101

#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$OrderId)

    $row = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM DonPorkCutSheets WHERE OrderId = $OrderId;" | Select-Object -First 1
    if (-not $row) { return $null }

    $h = [ordered]@{ Schema='DonPorkCutSheet.v1'; OrderId=$row.OrderId }
    foreach ($p in $row.PSObject.Properties) {
        if ($p.Name -in @('DonPorkCutSheetId','OrderId','CreatedAt','PutHamHocksIntoSausage','SausageBulk','SausageRegularCased','SausageSmallLink')) { continue }
        $h[$p.Name] = $p.Value
    }

    # Re-hydrate booleans stored as 0/1
    $h['PutHamHocksIntoSausage'] = [bool]$row.PutHamHocksIntoSausage
    $h['SausageBulk']           = [bool]$row.SausageBulk
    $h['SausageRegularCased']   = [bool]$row.SausageRegularCased
    $h['SausageSmallLink']      = [bool]$row.SausageSmallLink

    $h
}