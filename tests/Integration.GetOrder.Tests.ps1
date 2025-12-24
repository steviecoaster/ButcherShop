BeforeAll {
    . "$PSScriptRoot\Test.Bootstrap.ps1"
    $null = Export-TestVariable

}

Describe "Get-Order behavior" {
    It "returns a single order when -OrderId is provided" {
        $customerId = (New-Customer -FirstName "GetOrder" -LastName "Single" -Phone "555-4000").CustomerId
        $orderId = (New-Order -CustomerId $customerId -Species Beef -Portion Half -DropOffDate (Get-Date '2025-12-25')).OrderId

        $order = Get-Order -OrderId $orderId
        $order | Should -Not -BeNullOrEmpty
        $order.OrderId | Should -Be $orderId
    }

    It "returns multiple orders when no OrderId is provided" {
        # Create two orders
        $customerId = (New-Customer -FirstName "GetOrder" -LastName "Multi" -Phone "555-5000").CustomerId
        $order1 = (New-Order -CustomerId $customerId -Species Hog -Portion Whole -DropOffDate (Get-Date '2025-12-26')).OrderId
        $order2 = (New-Order -CustomerId $customerId -Species Beef -Portion Whole -DropOffDate (Get-Date '2025-12-27')).OrderId

        $all = Get-Order
        $all | Should -Not -BeNullOrEmpty
        # Ensure we get at least the two orders we just created
        ($all | Where-Object { $_.OrderId -in @($order1, $order2) }).Count | Should -Be 2
    }
}
