function Get-McConnellBeefCutOrder {
<#
.SYNOPSIS
Retrieve a McConnell beef cut order from the database.

.DESCRIPTION
Returns a PSCustomObject representing the McConnell beef cut sheet for the specified OrderId, or $null if not found.

.PARAMETER OrderId
The numeric order identifier.

.EXAMPLE
Get-McConnellBeefCutOrder -OrderId 42

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]
        $OrderId
    )

    $row = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query @"
SELECT *
FROM McConnellBeefCutSheets
WHERE OrderId = $OrderId;
"@ | Select-Object -First 1

    if (-not $row) {
        return $null
    }

    # Columns stored as 0/1 but exposed as booleans
    $boolColumns = @(
        'CallWhenReady',
        'RoundSteakTenderized',
        'RoundSteakPlain',
        'ShortRibs',
        'StewMeat',
        'Patties',
        'Liver',
        'Heart',
        'Tongue',
        'SoupBones'
    )

    $cutOrder = [ordered]@{
        Schema  = 'McConnellBeefCutSheet.v1'
        OrderId = [int]$row.OrderId
    }

    foreach ($prop in $row.PSObject.Properties) {
        if ($prop.Name -in @('OrderId','CreatedAt')) {
            continue
        }

        if ($boolColumns -contains $prop.Name) {
            $cutOrder[$prop.Name] = [bool]([int]$prop.Value)
        }
        else {
            $cutOrder[$prop.Name] = $prop.Value
        }
    }

    $cutOrder
}
