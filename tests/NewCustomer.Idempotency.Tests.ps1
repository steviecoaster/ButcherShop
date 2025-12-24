Describe 'New-Customer idempotency' {
    BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        $null = Export-TestVariable

    }

    It 'creates a new customer when none exists' {
        $c = New-Customer -FirstName 'Ida' -LastName 'New' -Phone '555-9999' -Email 'ida.new@test'
        $c.CustomerId | Should -BeGreaterThan 0
        $c.Existing | Should -BeFalse
    }

    It 'returns existing customer by email and updates fields' {
        $c1 = New-Customer -FirstName 'Mark' -LastName 'Dup' -Email 'mark.dup@test' -Phone '555-1111'
        $c2 = New-Customer -FirstName 'Markus' -LastName 'Dup' -Email 'mark.dup@test' -Phone '555-1111' -Notes 'updated'
        $c2.CustomerId | Should -Be $c1.CustomerId
        $c2.Existing | Should -BeTrue
        $c3 = Get-Customer -CustomerId $c1.CustomerId
        $c3.Notes | Should -Be 'updated'
    }

    It 'matches by phone when email not provided' {
        $c1 = New-Customer -FirstName 'Phone' -LastName 'Match' -Phone '555-2222'
        $c2 = New-Customer -FirstName 'Phone2' -LastName 'Match2' -Phone '555-2222'
        $c2.CustomerId | Should -Be $c1.CustomerId
        $c2.Existing | Should -BeTrue
    }
}
