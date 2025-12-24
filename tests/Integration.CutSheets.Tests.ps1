BeforeAll {
        . "$PSScriptRoot\Test.Bootstrap.ps1"
        $null = Export-TestVariable
}

Describe "Cut sheet integration (Don beef + Don pork)" {

    It "can save and load a Don beef cut order" {
        $customerId = (New-Customer -FirstName "Beef" -LastName "Tester").CustomerId
        $orderId = (New-Order -CustomerId $customerId -Species Beef -Portion Half -DropOffDate (Get-Date '2025-12-20')).OrderId

        $newDonBeefCutOrderSplat = @{
            OrderId = $orderId
            CutFor = "Beef Tester"
            Phone = "555-1111"
            BeefFrom = "Test Farm"
            RibEyeThicknessIn = 1.25
            RibEyePerPackage = 2
            GroundBeefLbsPerPackage = 1
            PattiesPerPackage = 4
            HowMuchMadeInPattiesLbs = 10
            SpecialInstructions = "No soup bones"
        }

        $co = New-DonBeefCutOrder @newDonBeefCutOrderSplat

        $savedId = Save-DonBeefCutOrder -CutOrder $co
        $savedId | Should -Be $orderId

        $loaded = Get-DonBeefCutOrder -OrderId $orderId
        $loaded | Should -Not -BeNullOrEmpty
        $loaded.RibEyeThicknessIn | Should -Be 1.25
        $loaded.RibEyePerPackage  | Should -Be 2
        $loaded.SpecialInstructions | Should -Be "No soup bones"
    }

    It "can save and load a Don pork cut order" {
        $customerId = (New-Customer -FirstName "Pork" -LastName "Tester").CustomerId
        $orderId = (New-Order -CustomerId $customerId -Species Hog -Portion Whole -DropOffDate (Get-Date '2025-12-20')).OrderId

        $newDonPorkCutOrderSplat = @{
            OrderId = $orderId
            CutFor = "Pork Tester"
            Phone = "555-2222"
            PorkFrom = "Test Hog Farm"
            HogChoice = 'Whole'
            PorkChopsThicknessIn = 0.75
            PorkChopsPerPackage = 2
            BaconChoice = 'CuredSmoked'
            BaconLbsPerPackage = 1
            BaconSliceThickness = 'Thick'
            HamChoice = 'CuredSmoked'
            CuredHamPortion = 'Half'
            CuredHamSliceStyle = 'AllSliced'
            CuredHamSlicesPerPackage = 6
            SausageSeasoning = 'CountryMild'
            SausageBulk = $true
            SausageBulkLbsPerPackage = 1.0
            LiverChoice = 'YesSliced'
            HeartChoice = 'Yes'
            TongueChoice = 'No'
            SpecialInstructions = "Leave hocks on"
        }

        $co = New-DonPorkCutOrder @newDonPorkCutOrderSplat

        $savedId = Save-DonPorkCutOrder -CutOrder $co
        $savedId | Should -Be $orderId

        $loaded = Get-DonPorkCutOrder -OrderId $orderId
        $loaded | Should -Not -BeNullOrEmpty
        $loaded.PorkChopsPerPackage | Should -Be 2
        $loaded.BaconSliceThickness | Should -Be 'Thick'
        $loaded.SausageBulk | Should -BeTrue
        $loaded.SpecialInstructions | Should -Be "Leave hocks on"
    }
}
