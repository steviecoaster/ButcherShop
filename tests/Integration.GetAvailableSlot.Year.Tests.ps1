Describe 'Get-AvailableSlot - Year scope' {
    BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        $null = Export-TestVariable

        # Seed DailySlots with some rows across 2025 and outside of it
        $slots = @(
            @{ SlotDate = '2025-01-15'; Species = 'Beef'; TotalSlots = 10; ReservedSlots = 2 },
            @{ SlotDate = '2025-06-30'; Species = 'Hog'; TotalSlots = 5; ReservedSlots = 5 },
            @{ SlotDate = '2025-12-31'; Species = 'Beef'; TotalSlots = 8; ReservedSlots = 0 },
            @{ SlotDate = '2024-12-31'; Species = 'Beef'; TotalSlots = 7; ReservedSlots = 1 },
            @{ SlotDate = '2026-01-01'; Species = 'Hog'; TotalSlots = 6; ReservedSlots = 0 }
        )

        foreach ($s in $slots) {
            $q = @"
INSERT OR REPLACE INTO DailySlots (SlotDate, Species, TotalSlots, ReservedSlots)
VALUES ('$($s.SlotDate)', '$($s.Species)', $($s.TotalSlots), $($s.ReservedSlots));
"@
            Invoke-UniversalSQLiteQuery -Path $script:TestDbPath -Query $q | Out-Null
        }
    }

    It 'returns all slots for the year when YearOnly is specified' {
        $results = Get-AvailableSlot -YearOnly 2025 | Sort-Object SlotDate, Species
        $results.Count | Should -Be 3
        $results | Where-Object { $_.SlotDate -eq '2025-01-15' -and $_.Species -eq 'Beef' } | Should -Not -BeNullOrEmpty
        $results | Where-Object { $_.SlotDate -eq '2025-06-30' -and $_.Species -eq 'Hog' } | Should -Not -BeNullOrEmpty
        $results | Where-Object { $_.SlotDate -eq '2025-12-31' -and $_.Species -eq 'Beef' } | Should -Not -BeNullOrEmpty
    }

    It 'respects -OnlyAvailable filter' {
        $available = Get-AvailableSlot -YearOnly 2025 -OnlyAvailable
        # The 2025-06-30 Hog has Total 5 Reserved 5 -> Available 0, so should be excluded
        $available.Count | Should -Be 2
        $available | Where-Object { $_.Species -eq 'Hog' } | Should -BeNullOrEmpty
    }

    It 'respects -Type filter' {
        $beef = Get-AvailableSlot -YearOnly 2025 -Type Beef
        $beef.Count | Should -Be 2
        $beef | ForEach-Object { $_.Species | Should -Be 'Beef' }
    }

    AfterAll {
        # clean up the test DB
        if (Test-Path $script:TestDbPath) { Remove-Item $script:TestDbPath -Force }
    }
}
