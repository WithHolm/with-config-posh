function Set-WConfigStr {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param (
        [Parameter(
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [string[]]$Enum,
        [string]$Description,
        $Default,
        [Switch]$Required
    )

    $Out = @{
        _name     = $Name
        type      = "string"
        _required = $Required.IsPresent
    }
    $BoltParam = @{
        Resource = "Config:$Name`:string"
    }

    if(($name|Test-WConfigName) -eq $false){
        Throw "The name $($Name) is not valid. Please see the error message to understand why."
    }

    if (![String]::IsNullOrEmpty($Description)) {
        if($Default){
            $Description ="(Default: $Default) $Description"
        }
        if($Required){
            $Description = "(Required) $Description"
        }
        Write-Bolt "Add description $Description" -Severity trace @BoltParam
        $Out.add('description', $Description)
    }
    if ($Enum.Count -gt 0) {
        Write-Bolt "Add enum $($Enum -join ',')" -Severity trace @BoltParam
        $E = [System.Collections.Generic.List[string]]::new()
        foreach ($item in $Enum) {
            $E.Add($item)
        }
        $Out.add('enum', $E)
    }
    $Default = [String]$Default
    if (![String]::IsNullOrEmpty($Default)) {
        Write-Bolt "Add default '$Default'" -Severity trace @BoltParam
        $Out.add('default', $Default)
    }
    return $Out
}