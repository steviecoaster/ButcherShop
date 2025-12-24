    $ErrorActionPreference = 'Stop'

    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $root = Split-Path $here -Parent
    # Import ButcherShop module
   
    $psd1 = Join-Path $root -ChildPath 'ButcherShop.psd1'
    $dataDir = Join-Path $root -ChildPath 'data'

    # Import the module under test
    Import-Module $psd1 -Force

    # ---- Paths ----
    $script:TestDbPath = Join-Path $dataDir 'Pester.db'
    $script:SchemaPath = Join-Path $dataDir 'Schema.sql'   # adjust if your schema lives elsewhere
    $script:DatabasePath = $script:TestDbPath
    Write-Host 'PATHS:'
    Write-Host $('Test DB: {0}' -f $script:TestDbPath)
    Write-Host $('Schema: {0}' -f $script:SchemaPath)
    Write-Host $('Compatibility DatabasePath: {0}' -f $script:DatabasePath)

    # Ensure tests start with a clean DB (delete any leftover from previous runs)
    if (Test-Path $script:TestDbPath) { Remove-Item $script:TestDbPath -Force }

    # Find the loaded module instance by ModuleBase and set its internal DatabasePath if available
    $moduleBase = (Split-Path $psd1 -Parent)
    $mod = Get-Module | Where-Object { $_.ModuleBase -and (Get-Item $_.ModuleBase).FullName -eq (Get-Item $moduleBase).FullName }
    if ($mod) {
        $mod.SessionState.PSVariable.Set('DatabasePath', $script:TestDbPath)
        Write-Host "Set module DB path for tests to: $script:TestDbPath"
    }
    else {
        Write-Warning "Could not locate loaded module for $psd1 to set DatabasePath; tests may operate on the module's default DB."
    }


    # ---- Ensure sqlite3 exists ----
    function Assert-Sqlite3Present {
        $cmd = Get-Command sqlite3 -ErrorAction SilentlyContinue
        if (-not $cmd) {
            throw "sqlite3 was not found on PATH. Install sqlite3 or add it to PATH."
        }
    }

    # ---- Minimal PSU-like function for test runtime only ----
    # Returns array of PSCustomObjects for SELECT; returns @() for non-SELECT.

    # ---- Apply schema from schema.sql ----
    Initialize-Database -DatabasePath $script:TestDbPath -SchemaPath $script:SchemaPath

    function Export-TestVariable {
      return $script:TestDbPath
    }