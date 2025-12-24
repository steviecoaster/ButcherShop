Describe 'Portion availability semantics' {
    BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        $null = Export-TestVariable

        # Create a daily slot: 1 TotalSlots (4 portion-units) for Beef
        Add-AvailableSlot -Date (Get-Date -Date '2025-12-25') -Type 'Beef' -SlotCount 1 -Shop 'Don'
    }

    It 'Whole consumes 4 units and makes slot unavailable for another Whole' {
        # Create a customer and order
        $cust = New-Customer -FirstName 'Test' -LastName 'Whole' -Phone '555-0001' -Email 'whole@test'
        $order = New-Order -CustomerId $cust.CustomerId -Species 'Beef' -Portion 'Whole' -DropOffDate (Get-Date '2025-12-20')

        # Register the order into the slot
        $slotDate = (Get-Date -Date '2025-12-25').ToString('yyyy-MM-dd')
        Register-OrderSlot -OrderId $order.OrderId -SlotDate $slotDate -Shop 'Don' | Should -BeTrue

        # Query availability for Whole
        $avail = Get-AvailableSlot -Date (Get-Date -Date '2025-12-25') -Type 'Beef' -Shop 'Don' -OnlyAvailable -Portion 'Whole'
        # Expect no results because the Whole consumed all 4 units
        $avail | Should -BeNullOrEmpty

    # Quarter is not supported; only Whole/Half are used. Confirm Whole produced no availability above.
    }

    It 'Two Halves each consume 2 units and prevent an extra Half' {
        # Reset DB row for a new date
        Add-AvailableSlot -Date (Get-Date -Date '2025-12-26') -Type 'Beef' -SlotCount 1 -Shop 'Don'

        # First half
        $c1 = New-Customer -FirstName 'Half' -LastName 'One' -Phone '555-0002' -Email 'half1@test'
        $o1 = New-Order -CustomerId $c1.CustomerId -Species 'Beef' -Portion 'Half' -DropOffDate (Get-Date '2025-12-20')
        Register-OrderSlot -OrderId $o1.OrderId -SlotDate (Get-Date -Date '2025-12-26').ToString('yyyy-MM-dd') -Shop 'Don' | Should -BeTrue

        # Second half
        $c2 = New-Customer -FirstName 'Half' -LastName 'Two' -Phone '555-0003' -Email 'half2@test'
        $o2 = New-Order -CustomerId $c2.CustomerId -Species 'Beef' -Portion 'Half' -DropOffDate (Get-Date '2025-12-20')
        Register-OrderSlot -OrderId $o2.OrderId -SlotDate (Get-Date -Date '2025-12-26').ToString('yyyy-MM-dd') -Shop 'Don' | Should -BeTrue

        # Now a third half should not be allowed by OnlyAvailable filter
        $availHalf = Get-AvailableSlot -Date (Get-Date -Date '2025-12-26') -Type 'Beef' -Shop 'Don' -OnlyAvailable -Portion 'Half'
        $availHalf | Should -BeNullOrEmpty
    }

    AfterAll {
        if ($script:TestDb -and (Test-Path $script:TestDb)) { Remove-Item $script:TestDb -Force }
    }
}
