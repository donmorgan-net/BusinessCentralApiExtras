<#
    .SYNOPSIS
        This module component contains commands for using APIs exposed using Simple Object Designer from Hougaard.
    .DESCRIPTION
        This module component contains commands for working with REST APIs exposed using Simple Object Designer from Hougaard, extending and building upon the base BusinessCentralApi module.

        Commands are suffixed with "SOD" to distinguish them from the base module.
    .NOTES
        Because each property needs to be manually configured per-tenant and may vary in use case, this module uses an input object (hashtable) instead of parameters.
    .LINK
        https://www.hougaard.com/designer/
#>

#Using a partial splat for specifying common parameters, specficially the API publisher, group, and version
$SODApiSplat = @{
    ApiPublisher = "hougaard"
    ApiGroup = "SOD"
    ApiVersion = "v2.0"
}


function Get-BusinessCentralItemSOD{
    param(
        [string]$Id
    )

    $Endpoint = "/items"

    if($Id){
        $Endpoint += "($Id)"
    }
    
    $Req = InvokeBusinessCentralApi -Mode ThirdPartyApi -Endpoint $Endpoint @SODApiSplat

    if($Id){
        Return $Req
    }
    else{
        Return $Req.value
    }

}
function New-BusinessCentralItemSOD{
    <#
    .SYNOPSIS
        Creates an item with the given properties view the SOD API.
    .NOTES
        Returns the created item.

        NOTE: Master Data Information fields (from the Abakion app) cannot be specified during creation
    .EXAMPLE
        $ItemSplat = @{
            Number = 12345678
            DisplayName = "Doohickey"
        }
        $ItemUpdate = New-BusinessCentralItem @ItemSplat
    .LINK
        https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/api/dynamics_item_update
    #>
    param(
        [Parameter(Mandatory = $true)]
        [object]$Parameters
    )

    #Property/field names in the SOD API must be lowercase by default
    $Attributes = @{}
    $Params = $Parameters
    $Keys = $Parameters.Keys
    foreach ($Key in $Keys){
        $Attributes.Add($Key.ToLower(),$Params.$Key)
    }

    $Body = $Attributes | ConvertTo-Json

    $Endpoint = "/items"

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Post -Body $Body -Mode ThirdPartyApi @SODApiSplat

    Return $Req.content | ConvertFrom-Json
}
function Set-BusinessCentralItemSOD{
    <#
    .SYNOPSIS
        Updates an item with the given properties.
    .NOTES
        Returns the updated item.
    .EXAMPLE
        $ItemUpdateSplat = @{
            Id = 10293845 #Note that this is the GUID
            Number = 12345678
            DisplayName = "Doohickey"
        }
        $ItemUpdate = Set-BusinessCentralItem @ItemUpdateSplat
    .LINK
        https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/api/dynamics_item_update
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true)]
        [object]$Parameters
    )

    $Body = $Parameters | ConvertTo-Json

    $Endpoint = "/items($Id)"

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Patch -Body $Body -Mode ThirdPartyApi @SODApiSplat

    Return $Req.content | ConvertFrom-Json
}
function Remove-BusinessCentralItemSOD{
    <#
    .SYNOPSIS
        Deletes an item from Business Central.
    .EXAMPLE
        Remove-BusinessCentralItem -Id 12345678
    .LINK
        https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/api/dynamics_item_delete
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $Endpoint = "/items($Id)"

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Delete

    if($Req.StatusCode -ne '204'){
        Write-Error "Failed to delete sales quote $Req"
    }
}
function Get-BusinessCentralItemReferenceSOD{
    param(
        [string]$CustomerNumber,
        [string]$Filter
    )

    $Endpoint = "/Item_References"

    if($Filter){
        $Endpoint += $Filter
    }

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Mode ThirdPartyApi @SODApiSplat

    Return $Req.value
}
function Get-BusinessCentralDimensionSOD{

    $Endpoint = "/dimensions"

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Mode ThirdPartyApi @SODApiSplat

    Return $Req.value
}
function Get-BusinessCentralDimensionValueSOD{
    param(
        [string]$DimensionCode,
        [string]$Value

    )

    $Endpoint = "/dimension_Values"

    #Add OData filter if a dimension code is specified
    if($Value){
        $Endpoint += "?`$filter=dimensioncode eq '$DimensionCode' and code eq '$Value'"
    }
    elseif($DimensionCode){
        $Endpoint += "?`$filter=dimensioncode eq '$DimensionCode'"
    }

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Mode ThirdPartyApi @SODApiSplat

    Return $Req.value
}
function Add-BusinessCentralDimensionValueSOD{
    param(
        [Parameter(Mandatory = $true)]
        [string]$DimensionCode,
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $Endpoint = "/dimension_Values"

    $Body = @{
        dimensioncode = $DimensionCode
        code = $Code
        name = $Name
    } | ConvertTo-Json

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Post -Body $Body -Mode ThirdPartyApi @SODApiSplat

    Return ($Req.Content | ConvertFrom-Json).id
}
function Remove-BusinessCentralDimensionValueSOD{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $Endpoint = "/dimension_Values($Id)"

    $Req = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Delete -Mode ThirdPartyApi @SODApiSplat

    if($Req.StatusCode -ne 204){
        Write-Error "Error during delete request - info: $Req"
    }
}


#WIP
<#

function Get-BusinessCentralWarehousePickSOD{
    param(
        [string]$Id
    )

    $Endpoint = "/warehouse_Activity_Headers"

    if($Id){
        $Endpoint += "($Id)"
    }
    
    $Req = InvokeBusinessCentralApi -Mode ThirdPartyApi -Endpoint $Endpoint @SODApiSplat

    if($Id){
        Return $Req
    }
    else{
        Return $Req.value
    }

}

function Get-BusinessCentralWarehouseEmployeeSOD{
    param(
        [string]$Id
    )

    $Endpoint = "/warehouse_Employees"

    if($Id){
        $Endpoint += "($Id)"
    }
    
    $Req = InvokeBusinessCentralApi -Mode ThirdPartyApi -Endpoint $Endpoint @SODApiSplat

    if($Id){
        Return $Req
    }
    else{
        Return $Req.value
    }

}

function Get-BusinessCentralPictureSOD{
    param(
        [string]$Id
    )

    $Endpoint = "/picture_Entitys"

    if($Id){
        $Endpoint += "($Id)"
    }
    
    $Req = InvokeBusinessCentralApi -Mode ThirdPartyApi -Endpoint $Endpoint @SODApiSplat

    if($Id){
        Return $Req
    }
    else{
        Return $Req.value
    }

}

#>