function Get-McConnellHogCutOrder {
<#
.SYNOPSIS
Retrieve a McConnell hog cut order from the database.

.DESCRIPTION
Returns an ordered hashtable representing the McConnell hog cut sheet for the specified OrderId, or $null if not found.

.PARAMETER OrderId
The numeric order identifier.

.EXAMPLE
Get-McConnellHogCutOrder -OrderId 43

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]
        $OrderId
    )

    $row = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM McConnellHogCutSheets WHERE OrderId = $OrderId;" |
        Select-Object -First 1

    if (-not $row) { return $null }

    # Rehydrate booleans that are stored as 0/1
    $boolCols = @(
        'NoLoinRoast','CountryStyleRibs','HamSliced','HamWhole','HamHalved','NoShoulder','GroundPork',
        'SausageRegular','SausageSweetItalian','SausageHotItalian','SausageBulk','SausageBigLinks','SausageSmallLinks','SausageQuarterLbPatties'
    )

    $h = [ordered]@{ Schema = 'McConnellHogCutSheet.v1'; OrderId = [int]$row.OrderId }

    foreach ($p in $row.PSObject.Properties) {
        if ($p.Name -in @('OrderId','CreatedAt')) { continue }

        if ($boolCols -contains $p.Name) {
            $h[$p.Name] = [bool]([int]$p.Value)
        }
        else {
            $h[$p.Name] = $p.Value
        }
    }

    $h
}