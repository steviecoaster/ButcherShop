# ============================
# File: tests/Integration.McConnellCutSheets.Tests.ps1
# Pester 5 integration tests (no mocks)
# Requires:
#   - tests/Test.Bootstrap.ps1 (your harness that creates Pester.db, applies schema.sql, imports functions)
#   - schema.sql includes McConnellBeefCutSheets + McConnellHogCutSheets
# ============================

BeforeAll {
    . "$PSScriptRoot\Test.Bootstrap.ps1"
    $null = Export-TestVariable
}

Describe "McConnell Cut Sheets integration (no mocks)" {

    Context "McConnell Beef" {

        It "can save and load a McConnell beef cut order" {
            $customerId = (New-Customer -FirstName "McConnell" -LastName "BeefTester" -Phone "555-1000").CustomerId
            $orderId = (New-Order -CustomerId $customerId -Species Beef -Portion Half -DropOffDate (Get-Date '2025-12-20')).OrderId

            $newMcConnellBeefCutOrderSplat = @{
                OrderId               = $orderId
                CustomerName          = "McConnell Beef Tester"
                Phone                 = "555-1000"
                CallWhenReady         = $true
                BeefPortion           = 'Half'
                HangingWeight         = 650
                SteaksPerPackage      = 2
                SteakThickness        = "1 inch"
                ChuckRoastSizeLbs     = 3
                RoundSteaksPerPackage = 2
                RoundSteakTenderized  = $true
                ShortRibs             = $true
                StewMeat              = $false
                BulkGroundPkgSizeLbs  = 1
                Patties               = $true
                PattySize             = '1/4'
                Liver                 = $true
                Heart                 = $false
                Tongue                = $true
                SoupBones             = $true
                SpecialInstructions   = "No soup bones if short on trim"
            }

            $cut = New-McConnellBeefCutOrder @newMcConnellBeefCutOrderSplat

            Save-McConnellBeefCutOrder -CutOrder $cut | Should -Be $orderId

            $loaded = Get-McConnellBeefCutOrder -OrderId $orderId
            $loaded | Should -Not -BeNullOrEmpty

            $loaded.OrderId | Should -Be $orderId
            $loaded.CustomerName | Should -Be "McConnell Beef Tester"
            $loaded.CallWhenReady | Should -BeTrue
            $loaded.BeefPortion | Should -Be 'Half'

            $loaded.SteaksPerPackage | Should -Be 2
            $loaded.SteakThickness | Should -Be "1 inch"

            $loaded.RoundSteakTenderized | Should -BeTrue
            $loaded.ShortRibs | Should -BeTrue
            $loaded.StewMeat | Should -BeFalse

            $loaded.Patties | Should -BeTrue
            $loaded.PattySize | Should -Be '1/4'

            $loaded.Liver | Should -BeTrue
            $loaded.Heart | Should -BeFalse
            $loaded.Tongue | Should -BeTrue
            $loaded.SoupBones | Should -BeTrue

            $loaded.SpecialInstructions | Should -Be "No soup bones if short on trim"
        }

        It "updates an existing McConnell beef row via ON CONFLICT(OrderId)" {
            $customerId = (New-Customer -FirstName "McConnell" -LastName "BeefUpdater").CustomerId
            $orderId = (New-Order -CustomerId $customerId -Species Beef -Portion Whole -DropOffDate (Get-Date '2025-12-21')).OrderId

            $cut1 = New-McConnellBeefCutOrder -OrderId $orderId -CustomerName "Initial" -Phone "555-1111" -CallWhenReady $false -BeefPortion Whole -SpecialInstructions "Initial notes"
            Save-McConnellBeefCutOrder -CutOrder $cut1 | Out-Null

            $cut2 = New-McConnellBeefCutOrder -OrderId $orderId -CustomerName "Updated" -Phone "555-2222" -CallWhenReady $true -BeefPortion Whole -SpecialInstructions "Updated notes"
            Save-McConnellBeefCutOrder -CutOrder $cut2 | Out-Null

            $loaded = Get-McConnellBeefCutOrder -OrderId $orderId
            $loaded.CustomerName | Should -Be "Updated"
            $loaded.Phone | Should -Be "555-2222"
            $loaded.CallWhenReady | Should -BeTrue
            $loaded.SpecialInstructions | Should -Be "Updated notes"
        }
    }

    Context "McConnell Hog" {

        It "can save and load a McConnell hog cut order" {
            $customerId = (New-Customer -FirstName "McConnell" -LastName "HogTester" -Phone "555-2000").CustomerId
            $orderId = (New-Order -CustomerId $customerId -Species Hog -Portion Whole -DropOffDate (Get-Date '2025-12-20')).OrderId

            $newMcConnellHogCutOrderSplat = @{
                OrderId                  = $orderId
                Phone                    = "555-2000"
                HogPortion               = 'Whole'
                HangingWeight            = 290
                PorkChopsPerPackage      = 2
                ChopThickness            = "3/4 inch"
                ChopStyle                = 'Fresh'
                LoinRoastSizeLbs         = 3
                NoLoinRoast              = $false
                BaconStyle               = 'CuredSmoked'
                CountryStyleRibs         = $true
                SpareRibsStyle           = 'Slab'
                HamStyle                 = 'CuredSmoked'
                HamSizeLbs               = 10
                HamSliced                = $true
                HamWhole                 = $false
                HamHalved                = $false
                ShoulderRoastSizeLbs     = 4
                ShoulderSlicesPerPackage = 2
                NoShoulder               = $false
                GroundPork               = $true
                SausageRegular           = $true
                SausageSweetItalian      = $false
                SausageHotItalian        = $true
                SausageBulk              = $true
                SausageBigLinks          = $false
                SausageSmallLinks        = $true
                SausageQuarterLbPatties  = $false
                SpecialInstructions      = "Keep belly thick cut"
                CustomerName             = "McConnell Hog Tester"
            }

            $cut = New-McConnellHogCutOrder @newMcConnellHogCutOrderSplat 

            Save-McConnellHogCutOrder -CutOrder $cut | Should -Be $orderId

            $loaded = Get-McConnellHogCutOrder -OrderId $orderId
            $loaded | Should -Not -BeNullOrEmpty

            $loaded.OrderId | Should -Be $orderId
            $loaded.CustomerName | Should -Be "McConnell Hog Tester"
            $loaded.HogPortion | Should -Be 'Whole'
            $loaded.PorkChopsPerPackage | Should -Be 2
            $loaded.ChopStyle | Should -Be 'Fresh'

            $loaded.CountryStyleRibs | Should -BeTrue
            $loaded.SausageRegular | Should -BeTrue
            $loaded.SausageHotItalian | Should -BeTrue
            $loaded.SausageBulk | Should -BeTrue
            $loaded.SausageSmallLinks | Should -BeTrue

            $loaded.SpecialInstructions | Should -Be "Keep belly thick cut"
        }

        It "updates an existing McConnell hog row via ON CONFLICT(OrderId)" {
            $customerId = (New-Customer -FirstName "McConnell" -LastName "HogUpdater").CustomerId
            $orderId = (New-Order -CustomerId $customerId -Species Hog -Portion Half -DropOffDate (Get-Date '2025-12-22')).OrderId

            $cut1 = New-McConnellHogCutOrder -OrderId $orderId -CustomerName "Initial Hog" -Phone "555-3000" -HogPortion Half -SausageBulk $false -SpecialInstructions "Initial"
            Save-McConnellHogCutOrder -CutOrder $cut1 | Out-Null

            $cut2 = New-McConnellHogCutOrder -OrderId $orderId -CustomerName "Updated Hog" -Phone "555-3333" -HogPortion Half -SausageBulk $true -SpecialInstructions "Updated"
            Save-McConnellHogCutOrder -CutOrder $cut2 | Out-Null

            $loaded = Get-McConnellHogCutOrder -OrderId $orderId
            $loaded.CustomerName | Should -Be "Updated Hog"
            $loaded.Phone | Should -Be "555-3333"
            $loaded.SausageBulk | Should -BeTrue
            $loaded.SpecialInstructions | Should -Be "Updated"
        }
    }
}
