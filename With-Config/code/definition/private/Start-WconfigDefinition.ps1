function Start-WconfigDefinition {
    [CmdletBinding()]
    param (
        [String]$Resource,
        [scriptblock]$Scriptblock,
        [ValidateSet("hashtable", "bool")]
        [string[]]$AcceptedOutput
    )
    
    try {
        $Out = & $Scriptblock
        $FilteredOut = Switch ($AcceptedOutput) {
            "hashtable" {
                $Out | Where-Object { $_ -is [hashtable] }
            }
            "bool" {
                $Out | Where-Object { $_ -is [bool] }
            }
        }
        if(@($FilteredOut).count -gt @($Out).count){
            Write-Bolt "The output of the scriptblock is not the expected type. Please check the config definition. i will only return $AcceptedOutput" -Severity warning
        }
        return $FilteredOut
    } catch {
        $_|Write-Bolt -Severity error -Resource $resource
        Write-Bolt "Stacktrace..." -Severity Warning -Resource $resource
        Get-PSCallStack|%{"$($_.ScriptName):$($_.ScriptLineNumber)"}| Write-Bolt -Severity warning -Resource $resource -ConcatPipelineInput
        # $_.ScriptStackTrace.Split([Environment]::NewLine) | ? { $_ } | Write-Bolt -Severity Warning -Resource $resource
        throw $_
    }
}