function Sql-Num {
    param([AllowNull()]$Value)
    if ($null -eq $Value -or "$Value" -eq "") { "NULL" } else { "$Value" }
}