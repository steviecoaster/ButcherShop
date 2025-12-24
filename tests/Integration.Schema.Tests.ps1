BeforeAll {
    . "$PSScriptRoot\Test.Bootstrap.ps1"
    $null = Export-TestVariable
}

Describe "Schema integration" {

    It "creates required core tables" {
        $tables = Invoke-UniversalSQLiteQuery -Path $script:TestDbPath -Query @"
SELECT name
FROM sqlite_master
WHERE type='table'
ORDER BY name;
"@

        $names = $tables.name

        $names | Should -Contain 'Customers'
        $names | Should -Contain 'Orders'
        $names | Should -Contain 'DailySlots'
        $names | Should -Contain 'DonBeefCutSheets'
        $names | Should -Contain 'DonPorkCutSheets'
    }

    It "creates Daily availability view" {
        $views = Invoke-UniversalSQLiteQuery -Path $script:TestDbPath -Query @"
SELECT name
FROM sqlite_master
WHERE type='view'
ORDER BY name;
"@
        $views.name | Should -Contain 'v_DailyAvailability'
    }
}
