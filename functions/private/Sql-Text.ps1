function Sql-Text {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { "NULL" } else { "'" + (Escape-SqliteString $Value) + "'" }
}