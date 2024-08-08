<#
.SYNOPSIS
Creates a jsonSchema object

.DESCRIPTION
Creates a jsonSchema object. This is used to to be able to validate a incoming configuratin agains a a schema.

.PARAMETER Name
Name of the object. if the parent item is an object, then the name is the property name.

.PARAMETER Properties
Properties of the object. This is a scriptblock that should return a hashtable.

.PARAMETER AdditionalProperties
AdditionalProperties of the object. This is a scriptblock that should return a bool or a hashtable.

.PARAMETER OneOf
(Not compatible with Properties or any other *of defintion) OneOf of the object. if you want the user to use atleast one of the defined configurations.

.PARAMETER AnyOf
(Not compatible with Properties or any other *of defintion) AnyOf of the object. if you want the user to use any of the defined configurations.

.PARAMETER AllOf
(Not compatible with Properties or any other *of defintion) AllOf of the object. if you want the user to use all of the defined configurations.

.PARAMETER Description
Description of the object. This is used to generate the description of the object.

.PARAMETER Required
If the object is required. This is used to set the object as required.

.PARAMETER Root
This is used to remove all metadate properties from the object and return a "clean" jsonschema.

#>
function Set-WConfigObj {
    [CmdletBinding(
        DefaultParameterSetName = "Default"
    )]
    [OutputType([Hashtable])]
    param (
        [Parameter(
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [Parameter(
            Position = 1,
            ParameterSetName = "Default"
        )]
        [scriptblock]$Properties,
        [Parameter(
            ParameterSetName = "Default"
        )]
        [scriptblock]$AdditionalProperties,
        [Parameter(
            ParameterSetName = "OneOf"
        )]
        [scriptblock]$OneOf,
        [Parameter(
            ParameterSetName = "AnyOf"
        )]
        [scriptblock]$AnyOf,
        [Parameter(
            ParameterSetName = "AllOf"
        )]
        [scriptblock]$AllOf,
        [string]$Description,
        [switch]$Required,
        [switch]$Root
    )
    Write-Bolt "Generate Config Object $Name" -Severity trace
    $Out = @{
        _name                = $Name
        _required            = $Required.IsPresent
        type                 = "object"
        required             = @()
        _addresses           = @()
    }

    if (($name | Test-WConfigName) -eq $false) {
        Throw "The name $($Name) is not valid. Please see the error message to understand why."
    }

    if($Description -and (Test-WConfigDescription -Description $Description)){
        $Out.description = $Description
    }

    #Properties
    if($Properties){
        $out.properties = @{}
        $param = @{
            Resource = "Object:$Name properties"
            Scriptblock = $Properties
            AcceptedOutput = "hashtable"
        }
        $Props = Start-WconfigDefinition @param -ErrorAction Stop

        $Props | % {
            $Out.Properties.Add($_._name, $_)
            if($_._required){
                $Out.required += $_._name
            }
            $_|Format-WConfigItem
        }

    }

    #additionalProperties
    if ($additionalProperties) {
        $param = @{
            Resource = "Object:$Name additionalProperties"
            Scriptblock = $additionalProperties
            AcceptedOutput = "bool", "hashtable"
        }
        $AddProperties = Start-WconfigDefinition @param
        $BoolAddProperties = $AddProperties | Where-Object { $_ -is [bool] }
        $HashAddProperties = $AddProperties | Where-Object { $_ -is [hashtable] }

        if (@($CorrectAddProperties).Count -eq 0 ) {
            #if no objects are returned, then we set the additionalProperties to false
            $Out.additionalProperties = $false
        } elseif ($HashAddProperties) {
            #if we have hashtables, we format them and add them
            $HashAddProperties | Format-WConfigItem
            $Out.additionalProperties = $HashAddProperties
        } else {
            #if we have bools, we select the first one
            $Out.additionalProperties = $BoolAddProperties| Select-Object -first 1
        }
    }
    else{
        $Out.additionalProperties = $false
    }

    if($oneOf -or $AnyOf -or $AllOf){
        $type = $PSCmdlet.ParameterSetName
        $param = @{
            Resource = "Object:$Name $type"
            Scriptblock = Get-Variable -Name $type -ValueOnly
            AcceptedOutput = "hashtable"
        }
        $multiJson = Start-WconfigDefinition @param
        $multiJson|Format-WConfigItem
        $Out.$type = @($multiJson)
    }

    if ($Root) {
        $out|Format-WConfigItem
    }

    return $Out
}