function New-Order {
<#
.SYNOPSIS
Create a new order record.

.DESCRIPTION
Inserts a new order into the Orders table and returns the generated OrderId.

.PARAMETER CustomerId
Numeric CustomerId for the order.

.PARAMETER Species
Species (Beef or Hog).

.PARAMETER Portion
Portion of the animal (e.g., Whole, Half).

.EXAMPLE
(New-Order -CustomerId 1 -Species Beef -Portion Half -DropOffDate (Get-Date)).OrderId

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$CustomerId,

        [Parameter(Mandatory)]
        [ValidateSet('Beef', 'Hog')]
        [string]$Species,

  [Parameter(Mandatory)]
  [ValidateSet('Whole', 'Half')]
  [string]$Portion,

        [Parameter(Mandatory)]
        [DateTime]$DropOffDate,

        [Parameter()]
        [DateTime]$SlotDate,

        [Parameter()]
        [double]$EstimatedWeight,

  [Parameter()]
  [string]$Notes,

        [Parameter()]
        [string]$Status = 'Received',

        [Parameter()]
        [DateTime]$DueDate
    )

    $drop = $DropOffDate.ToString('yyyy-MM-dd')
    $slot = if ($PSBoundParameters.ContainsKey('SlotDate')) { "'" + $SlotDate.ToString('yyyy-MM-dd') + "'" } else { "NULL" }
    $due = if ($PSBoundParameters.ContainsKey('DueDate')) { "'" + $DueDate.ToString('yyyy-MM-dd') + "'" } else { "NULL" }
    $wt = if ($PSBoundParameters.ContainsKey('EstimatedWeight')) { "$EstimatedWeight" } else { "NULL" }

    $sql = @"
INSERT INTO Orders (
  CustomerId, Species, Portion,
  DropOffDate, SlotDate, EstimatedWeight,
  Status, DueDate, Notes
)
VALUES (
  $CustomerId, '$Species', '$Portion',
  '$drop', $slot, $wt,
  $(Sql-Text $Status), $due
  , $(Sql-Text $Notes)
)
RETURNING OrderId;
"@

    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql
}