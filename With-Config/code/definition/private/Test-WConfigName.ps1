function Test-WConfigName {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [parameter(
            ValueFromPipeline
        )]
        [string]$Name
    )
    
    begin {
        
    }
    
    process {
        if($Name -match "\W"){
            New-PwshOtelLog -Body "The name '$name' should not contain whitespaces" -Severity error
            return $false
        }
        return $true
    }
    
    end {
        
    }
}