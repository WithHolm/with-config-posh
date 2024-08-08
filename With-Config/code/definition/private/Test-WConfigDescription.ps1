function Test-WConfigDescription {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [String]$Description,
        [String]$Name
    )
    #there is no description to validate
    if([String]::IsNullOrEmpty($Description)){
        return $true
    }
    
    if ($Description -cnotmatch "^[A-Z]")
    {
        New-PwshOtelLog -Body "Description must start with a capital letter" -Severity error -Resource "$Name.description"
        return $false
    }
    if($Description -notmatch ".*\.$")
    {
        New-PwshOtelLog -Body "Description must end with a period" -Severity error -Resource "$Name.description"
        return $false
    }
    return $true
}