<#
    .SYNOPSIS
        This module component contains commands for Abakion apps.
    .DESCRIPTION
        This module component contains commands for working with REST APIs for Abakion's Business Central apps, extending and building upon the base BusinessCentralApi module.
    .LINK
        https://bcapps.api.abakion.com/
#>

#Using a partial splat for specifying common parameters
$AbakionApiSplat = @{
    ApiPublisher = "abakion"
    ApiGroup = "bi"
    ApiVersion = "v2.0"
}


function Get-BusinessCentralAbakionCustomer{
    <#
    .SYNOPSIS
        Gets Business Central customers via abakion API.
    .EXAMPLE
        #Get all items    
        Get-BusinessCentralAbakionCustomer

        #Get specific item by Id
        Get-BusinessCentralAbakionCustomer -Id 12345678
    .LINK
        https://bcapps.api.abakion.com/#8fc73a8c-9f7e-40ed-ae4b-dc451c297b69
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]$Id
    )

    If($Id){
        $Endpoint = "/abiCustomers($Id)"
    }
    else{
        $Endpoint = "/abiCustomers"
    }

    $Request = InvokeBusinessCentralApi -Endpoint $Endpoint -Mode ThirdPartyApi @AbakionApiSplat

    if($Id){
        Return $Request    
    }
    else{
        Return $Request.value
    }   
}


