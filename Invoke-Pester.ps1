[CmdletBinding()]
Param()

process {
   
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path

    $testPath = Join-Path $here -ChildPath 'tests'
    $files = (Get-ChildItem $testPath -Recurse -Filter *.ps1).Fullname
    Write-Host "Configuring Pester to complete verification tests"
    
    $containers = $files | Foreach-Object { New-PesterContainer -Path $_ }
    $configuration = [PesterConfiguration]@{
        Run        = @{
            Container = $Containers
            Passthru  = $false
        }
        Output     = @{
            Verbosity = 'Detailed'
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = 'NUnitXml'
            OutputPath   = (Join-Path $here -ChildPath 'Test.Results.xml')
        }
    }

    Invoke-Pester -Configuration $configuration

}