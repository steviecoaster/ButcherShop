function Escape-SqliteString {
    [CmdletBinding()]
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) { return $null }
    ($Value -replace "'", "''")
}