function Get-DonBeefCutOrder {
<#
.SYNOPSIS
Retrieve a Don beef cut order.

.DESCRIPTION
Returns the Don beef cut order for the provided OrderId or $null if not found.

.PARAMETER OrderId
The numeric order identifier.

.EXAMPLE
Get-DonBeefCutOrder -OrderId 100

#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$OrderId)

    $row = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM DonBeefCutSheets WHERE OrderId = $OrderId;" | Select-Object -First 1
    if (-not $row) { return $null }

    $h = [ordered]@{ Schema='DonBeefCutSheet.v1'; OrderId=$row.OrderId }
    foreach ($p in $row.PSObject.Properties) {
        if ($p.Name -in @('DonBeefCutSheetId','OrderId','CreatedAt')) { continue }
        $h[$p.Name] = $p.Value
    }
    $h
}