<#
.SYNOPSIS
General item that can define multiple types.

.DESCRIPTION
Long description

.PARAMETER Type
Parameter description

.PARAMETER Name
Parameter description

.PARAMETER Description
Parameter description

.PARAMETER Required
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-WConfigItem {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [ValidateSet("object", "string", "integer", "boolean", "array")]
        [string[]]$Type,
        $Name,
        [string]$Description,
        [switch]$Required
    )
    
    if($($Type).count -lt 2){
        Write-Warning "Set-WconfigItem should be used to define multiple types. if you have only one type, use set-wconfig{type} instead as this allows extra options"
    }

    $Out = @{
        type = $Type
        _name = $Name
        _required = $Required.isPresent
    }
    if($Description -and (Test-WConfigDescription -Description $Description)){
        $Out.description = $Description
    }
    return $Out
}