function Remove-Customer {
<#
.SYNOPSIS
Remove a customer and (via cascade) their orders and related data.

.DESCRIPTION
Deletes a customer row from the Customers table. The database schema uses
ON DELETE CASCADE for Orders -> Customers and related tables, so deleting a
customer will also remove their Orders, CutSheets and CutItems.

This cmdlet supports ShouldProcess so it works with -WhatIf and -Confirm.

.PARAMETER CustomerId
Numeric CustomerId to delete.

.PARAMETER Backup
Optional switch to create a timestamped backup copy of the database file
before performing the deletion.

.PARAMETER Force
If specified, suppresses interactive confirmation prompts and proceeds.

.EXAMPLE
Remove-Customer -CustomerId 12 -Backup

Will prompt (or respect -WhatIf/-Confirm) and create a DB backup before deleting.
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [int]$CustomerId,

        [Parameter()]
        [switch]$Backup,

        [Parameter()]
        [switch]$Force
    )

    # Lookup customer for friendly message
    $cust = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT CustomerId, FirstName, LastName FROM Customers WHERE CustomerId = $CustomerId;" | Select-Object -First 1
    if (-not $cust) {
        Write-Verbose "CustomerId $CustomerId not found."
        return $false
    }

    $display = "$($cust.FirstName) $($cust.LastName) (ID $CustomerId)"

    # If -Force provided, temporarily suppress confirmation prompts (still respects -WhatIf)
    $confirmChanged = $false
    if ($Force.IsPresent) {
        try {
            $oldConfirm = $ConfirmPreference
            $ConfirmPreference = 'None'
            $confirmChanged = $true
        }
        catch {
            $confirmChanged = $false
        }
    }

    try {
        if (-not $PSCmdlet.ShouldProcess($display, 'Delete')) {
            Write-Verbose "Deletion not performed for $display."
            return $false
        }

        try {
            if ($Backup.IsPresent) {
                # attempt a lightweight backup of the sqlite file
                try {
                    $ts = (Get-Date).ToString('yyyyMMddHHmmss')
                    $dest = "${script:DatabasePath}.bak.$ts"
                    Copy-Item -Path $script:DatabasePath -Destination $dest -ErrorAction Stop
                    Write-Verbose "Database backed up to $dest"
                }
                catch {
                    Write-Warning "Backup failed: $($_.Exception.Message) — proceeding with deletion unless -WhatIf was used."
                }
            }

            $sql = "DELETE FROM Customers WHERE CustomerId = $CustomerId;"
            Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql | Out-Null

            Write-Verbose "Customer $display deleted."
            return $true
        }
        catch {
            Write-Error "Failed to delete customer $($display): $($_.Exception.Message)"
            return $false
        }
    }
    finally {
        if ($confirmChanged) {
            try { $ConfirmPreference = $oldConfirm } catch { }
        }
    }
}