function Sql-Bool {
    param([AllowNull()][bool]$Value)
    if ($null -eq $Value) { "NULL" } else { if ($Value) { "1" } else { "0" } }
}
