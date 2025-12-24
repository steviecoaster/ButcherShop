[CmdletBinding()]
Param()

Describe "Core workflow integration (no mocks)" {
    BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        $null = Export-TestVariable

    }

    It "can create a customer and fetch it back" {
        $id = (New-Customer -FirstName "Don" -LastName "Tester" -Phone "555-0000" -Email "don@test.local" -Notes "Pester").CustomerId
        $id | Should -BeGreaterThan 0

        $c = Get-Customer -CustomerId $id
        $c.FirstName | Should -Be "Don"
        $c.LastName  | Should -Be "Tester"
    }

    It "can add slots, then book and unbook an order slot" {
        # Customer + order
        $customerId = (New-Customer -FirstName "Slot" -LastName "Customer").CustomerId
        $orderId = (New-Order -CustomerId $customerId -Species Beef -Portion Half -DropOffDate (Get-Date '2025-12-20')).OrderId

        # Add capacity for slot day
        Add-AvailableSlot -Date (Get-Date '2025-12-22') -Type Beef -SlotCount 3 -Mode Set

        # Book the order
        Register-OrderSlot -OrderId $orderId -SlotDate (Get-Date '2025-12-22')

        $slotRow = Get-AvailableSlot -Month December -Type Beef
        
        $slotRow.TotalSlots    | Should -Be 3
        $slotRow.ReservedSlots | Should -Be 1

        $orderRow = Get-Order -OrderId $orderId

        $orderRow.SlotDate | Should -Be '2025-12-22'

        # Unbook
        Unregister-OrderSlot -OrderId $orderId

        $slotRow2 = Get-AvailableSlot -Month December -Type Beef

        $slotRow2.ReservedSlots | Should -Be 0

        $orderRow2 = Get-Order -OrderId $orderId

        $orderRow2.SlotDate | Should -BeNullOrEmpty
    }

    It "Get-AvailableSlot returns month-filtered rows" {
        Add-AvailableSlot -Date (Get-Date '2025-12-05') -Type Hog -SlotCount 2 -Mode Set
        Add-AvailableSlot -Date (Get-Date '2025-12-20') -Type Hog -SlotCount 1 -Mode Set

        $rows = Get-AvailableSlot -Month December -Year 2025 -Type Hog
        @($rows).Count | Should -BeGreaterThan 0

        ($rows | Select-Object -First 1).Species | Should -Be 'Hog'
    }
}
