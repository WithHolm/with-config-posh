<#
.SYNOPSIS
Find and import config files

.DESCRIPTION
Find and import config files. if several types are specified it will import and merge them. the -types input is ordered and the last value will take precedence. 
If dotenv is enabled, it will import this to env before env is processed.

.PARAMETER Types
What types of config files to import.
json = .json and .jsonc
yaml = .yaml and .yml
psd1 = .psd1
env = system environment variables. the naming schema is ".env.<filter>" where filter is the filter input. if no filter is defined
dotenv = .dotenv -> Will be imported before env, if enabled

.PARAMETER Filter
Filter to apply to the files. uses * by default. for env vairables it will search for variables that start with filter.

.PARAMETER Path
Path to look for config files. defaults to current directory

.EXAMPLE
Import-Wconfig -Types "json","yaml" -Path "c:\temp\config" -filter "myconfig"
#>
function Import-Wconfig {
    [CmdletBinding()]
    param (
        [ValidateSet("psd1", "json", "yaml", "env", "dotenv")]
        [Parameter(Mandatory)]
        [string[]]$Types,

        [string]$Filter,

        [string]$Path = $PWD

        # [hashtable]$Schema
    )


    $PathItem = Get-Item $Path
    $FoundConfig = @()
    #if defined path is a file, import it
    if ($PathItem.PSIsContainer) {
        #add filter after init of param hash because its not always defined
        $gciParam = @{
            Path        = $Path
            Recurse     = $true
            File        = $true
            ErrorAction = "SilentlyContinue"
        }

        if ($Filter) {
            $gciParam.Filter = $Filter
        }

        #find all files in the path using the filter
        $FoundConfig = Get-ChildItem @gciParam
    } else {
        $FoundConfig += $PathItem
    }

    # Write-verbose "Found $($FoundConfig.Count) config files"
    New-PwshOtelLog "Found $($FoundConfig.Count) config files" -Severity verbose

    # Write-host $types
    $Configs = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($type in $types) {
        $ConfigBase = @{
            type = $type
            path = ""
            contents = ""
            data = @{}
        }
        New-PwshOtelLog "Importing config of type $type" -Severity verbose
        switch($type) {
            "json" {
                foreach($ConfigFile in $FoundConfig|?{$_.Extension -in @(".json", ".jsonc")}) {
                    $conf = $ConfigBase.Clone()
                    $conf.path = $ConfigFile.FullName
                    $conf.contents = [System.IO.File]::ReadAllText($ConfigFile.FullName)

                    #convert to json string if jsonc
                    if($ConfigFile.Extension -eq ".jsonc") {
                        $conf.contents = $conf.data | ConvertFrom-Jsonc -ToString -ErrorAction Stop
                    }
                    $conf.data = $conf.contents | ConvertFrom-Json

                    $Configs.Add($conf)
                }
            }
            "yaml" {
                $Config = Get-Content $ConfigFile.FullName | ConvertFrom-Yaml
            }
            "env" {
                $Config = Get
            }
            "dotenv" {
                $Config = Get-Content $ConfigFile.FullName | ConvertFrom-DotEnv
            }
        }

    }
}