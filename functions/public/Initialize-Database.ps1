function Initialize-Database {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $DatabasePath = $script:DatabasePath,

        [Parameter()]
        [String]
        $SchemaPath
    )

    end {

        $schema = Get-Content $schemaPath -Raw

        # Ensure the database file exists so sqlite can open it (creates empty file if necessary)
        $dbDir = Split-Path $DatabasePath -Parent
        if (-not (Test-Path $dbDir)) { New-Item -Path $dbDir -ItemType Directory -Force | Out-Null }
        if (-not (Test-Path $DatabasePath)) { New-Item -Path $DatabasePath -ItemType File -Force | Out-Null }

        # Execute the full schema in a single call so BEGIN/COMMIT are preserved
        Write-Verbose "Applying schema $schemaPath to $DatabasePath"
        try {
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $schema -ErrorAction Stop
            Write-Verbose "Schema applied successfully to $DatabasePath"
        }
        catch {
            throw "Failed to initialize database using schema at $($schemaPath): $($_.Exception.Message)"
        }

        # Ensure WAL and sensible concurrency/durability settings
        try {
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA journal_mode = WAL;"
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA synchronous = 2;"
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA wal_autocheckpoint = 1000;"
            Write-Verbose "Initialization: set PRAGMA journal_mode=WAL, synchronous=2, wal_autocheckpoint=1000"
        }
        catch {
            Write-Warning "Failed to set PRAGMA during initialization: $_"
        }
    }
}