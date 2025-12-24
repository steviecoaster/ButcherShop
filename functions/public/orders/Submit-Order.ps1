function Submit-Order {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Context
    )

    end {
        
        $first = $Context.firstName
        $last = $Context.lastName
        $phone = $Context.phone
        $email = $Context.email
        $notes = $Context.notes
        $animal = $Context.animal
        $portion = $Context.portion
        $shop = $Context.shop
        $slotDate = $Context.'chosen-slot'
        
        $cust = New-Customer -FirstName $first -LastName $last -Phone $phone -Email $email
        $order = New-Order -CustomerId $cust.CustomerId -Species $animal -Portion $portion -DropOffDate $slotDate -Notes $notes
        $null = Register-OrderSlot -OrderId $order.OrderId -SlotDate $slotDate -Shop $shop -ErrorAction Stop
    }
}