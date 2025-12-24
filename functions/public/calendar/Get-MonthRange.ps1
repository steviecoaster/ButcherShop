function Get-MonthRange {
<#
.SYNOPSIS
Return start and end dates for a given month/year.

.DESCRIPTION
Calculates the first and last date for a month/year pair.

.PARAMETER Month
Month number (1-12).

.PARAMETER Year
Year number.

.EXAMPLE
Get-MonthRange -Month 12 -Year 2025

#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [DateTime]$Month
    )

    $start = Get-Date -Year $Month.Year -Month $Month.Month -Day 1
    $end   = $start.AddMonths(1)

    [pscustomobject]@{
        Start    = $start
        End      = $end
        StartStr = $start.ToString('yyyy-MM-dd')
        EndStr   = $end.ToString('yyyy-MM-dd')
    }
}
