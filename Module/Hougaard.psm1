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

#Using a partial splat for specifying common parameters
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

    $Request = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Post -Body $Body -Mode ThirdPartyApi @SODApiSplat

    Return $Request.content | ConvertFrom-Json
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
        [object]$Parameters
    )

    #Dynamically create a hashtable with whatever attributes were specified. Have to do this since you can't have a null key value in hashtables and you may not use all params when creating a new object
    $Attributes = @{}
    $Params = $Parameters
    $Keys = $Parameters.Keys
    foreach ($Key in $Keys){
        $Attributes.Add($Key.ToLower(),$Params.$Key)
    }
    #Remove Id since it's not needed in the body
    $Attributes.Remove("Id")

    $Body = $Attributes | ConvertTo-Json

    $Endpoint = "/items($Id)"

    $Request = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Patch -Body $Body -Mode ThirdPartyApi @SODApiSplat

    Return $Request.content | ConvertFrom-Json
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

    $Request = InvokeBusinessCentralApi -Endpoint $Endpoint -Method Delete

    if($Request.StatusCode -ne '204'){
        Write-Error "Failed to delete sales quote $Request"
    }
}

#WIP
function Copy-BusinessCentralItemSOD{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true)]
        [object]$Parameters
    )

    #Remove system properties like Id and read-only timestamp properties
    $ExcludedProperties  = @(
        'id',
        '@odata.context',
        '@odata.etag',
        'lastdatetimemodified',
        'lastdatemodified',
        'lasttimemodified',
        'systemid',
        'systemcreatedat',
        'systemcreatedby',
        'systemmodifiedat',
        'systemmodifiedby',
        'assemblybom',
        'costisadjusted',
        'no_'
    )

    $ItemToCopy = Get-BusinessCentralItemSOD -Id $Id | Select-Object -ExcludeProperty $ExcludedProperties

    $Body = $ItemToCopy | ConvertTo-Json

    $Endpoint = "/items"

    #$Req = 
    InvokeBusinessCentralApi -Body $Body -Method Post -Mode ThirdPartyApi -Endpoint $Endpoint @SODApiSplat

    Return $Req
}

