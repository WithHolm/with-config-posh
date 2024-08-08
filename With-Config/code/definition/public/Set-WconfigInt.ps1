function Set-WconfigInt {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        $Default,
        $Min,
        $Max,
        [string]$Description,
        [Switch]$Required
    )
    $boltparam = @{
        resource = "Config:$Name`:int"
    }
    if(($name|Test-WConfigName) -eq $false){
        Throw "The name $($Name) is not valid. Please see the error message to understand why."
    }

    Write-Bolt "Generate config int $Name" -Severity trace @boltparam
    $Out = @{
        _name       = $Name
        _required   = $Required.IsPresent
        type        = "int"
        default     = $Default
    }
    if(![String]::IsNullOrEmpty($Description)){
        Write-Bolt "Add description $Description" -Severity trace @boltparam
        $Out.add('description', $Description)
    }
    try{
        if(![String]::IsNullOrEmpty($Min)){
            Write-Bolt "Add minimum $Min" -Severity trace @boltparam
            $Out.add('minimum', [int]::Parse($Min))
        }
    }
    catch{
        Write-Bolt "min value error: $_"-Severity error @boltparam
    }
    try{
        if(![String]::IsNullOrEmpty($Max)){
            Write-Bolt "Add maximum $Max" -Severity trace @boltparam
            $Out.add('maximum', [int]::Parse($Max))
        }
    }
    catch{
        Write-Bolt "min value error: $_" -Severity error @boltparam
    }
    return $Out
}