function Set-WConfigBol {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$Description,
        [Switch]$Required,
        [bool]$Default
    )

    $out = @{
        _name     = $Name
        type      = "bool"
        _required = $Required.IsPresent
    }
    $BoltParam = @{
        Resource = "Config:$Name`:bool"
    }

    if(($name|Test-WConfigName) -eq $false){
        Throw "The name $($Name) is not valid. Please see the error message to understand why."
    }
    
    if (![String]::IsNullOrEmpty($Description)) {
        Write-Bolt "Add description $Description" -Severity trace @BoltParam
        $out.add('description', $Description)
    }
    if ($Default) {
        Write-Bolt "Add default '$Default'" -Severity trace @BoltParam
        $out.add('default', $Default)
    }
    return $out
}