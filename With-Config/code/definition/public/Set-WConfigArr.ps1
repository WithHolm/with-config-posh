function Set-WConfigArr {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(
            Position = 1
        )]
        [scriptblock]$Items,

        [string]$Description,
        $MinItems,
        $MaxItems,
        [switch]$Required
    )
    
    begin {

        if([String]::IsNullOrEmpty($Name)){
            Throw "Name of item is required"
        }
    
        $out = @{
            _name                = $Name
            type                 = "array"
            items                = @()
            _addresses           = @()
            _required = $Required.IsPresent
        }
        $boltparam = @{
            Resource = "Array:$Name"
        }
        if(($name|Test-WConfigName) -eq $false){
            Throw "The name $($Name) is not valid. Please see the error message to understand why."
        }

        if ($Description -and !(Test-WConfigDescription -Description $Description -Name $Name)) {

            $out.description = $Description
        }

        if(!$Items){
            $Items = {}
        }
    }
    process{
        if ($MinItems) {
            try {
                Write-Bolt "Setting minItems to $MinItems" -Severity trace @boltparam
                $out.minItems = [int]::Parse($MinItems)
            } catch {
                throw "Invalid MinItems value '$MinItems'"
            }
        }
        if ($MaxItems) {
            try {
                Write-Bolt "Setting maxItems to $MaxItems" -Severity trace @boltparam
                $out.maxItems = [int]::Parse($MaxItems)
            } catch {
                throw "Invalid MaxItems value '$MaxItems'"
            }
        }


        try {
            $DefinedItems = & $Items | Where-Object { $_ -is [hashtable] }|Where-Object{$_}
            New-PwshOtelLog -Body "Scriptblock returned $(@($DefinedItems).count) items" -Severity verbose
            if(@($DefinedItems).count -gt 1){
                for ($i = 0; $i -lt $DefinedItems.Count; $i++) {
                    $Prop = $DefinedItems[$i]
                    $Out.items += $Prop
                    $Out._addresses += "$Name.*.$propname"
                }
                $DefinedItems|Format-WConfigItem
            }
            elseif(@($DefinedItems).count -eq 1){
                $out.items = $DefinedItems
                $out.items|Format-WConfigItem
            }
        } catch {
            $_.ScriptStackTrace.Split([Environment]::NewLine) | ? { $_ } | Write-Bolt -Severity warning -Resource "Array:$Name stacktrace"
            throw $_
        }

        return $out
    }


}