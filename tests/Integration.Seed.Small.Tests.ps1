Describe 'Seed large dataset (small scale) smoke' {
    BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        Export-TestVariable | Out-Null
        # seed a small dataset (Scale=1)
        . "$PSScriptRoot\..\tools\Invoke-SeedLargeDataset.ps1" -Scale 1 -DatabasePath $script:TestDbPath
    }

    It 'has customers inserted' {
        $rows = Invoke-UniversalSQLiteQuery -Path $script:TestDbPath -Query "SELECT COUNT(*) as C FROM Customers;"
        $rows.C | Should -BeGreaterThan 0
    }

    It 'has daily slots for the year' {
        $rows = Invoke-UniversalSQLiteQuery -Path $script:TestDbPath -Query "SELECT COUNT(*) as C FROM DailySlots WHERE SlotDate >= '2025-01-01' AND SlotDate < '2026-01-01';"
        $rows.C | Should -BeGreaterThan 0
    }

    AfterAll {
        if (Test-Path $script:TestDbPath) { Remove-Item $script:TestDbPath -Force }
    }
}
