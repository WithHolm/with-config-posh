function Import-DotEnv {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline
        )]
        $InputItem,
        [System.IO.FileInfo]$File,
        [string[]]$Data
    )
    begin {
        $DataArr = [System.Collections.Generic.List[string]]::new()
    }
    process {
        if($InputItem -is [System.IO.FileInfo]){
            #set path if imput is a file
            $File = $InputItem
        }
        elseif($InputItem -is [string] -and (test-path $InputItem)){
            $File = Get-Item $InputItem
        }
        elseIf($InputItem -is [string]){
            $DataArr.Add($InputItem)
        }
        elseif(![string]::IsNullOrEmpty($InputItem)){
            throw "Unknown input type $($InputItem.GetType())"
        }

        if($File){
            if($File.name -eq ".env.vault"){
                Throw "dotenv vault is not supported, yet.."
            }
            elseif($File.name -eq ".env" -or $File.name -like ".env.*"){
                $Data = [System.IO.File]::ReadAllText($File.FullName)
            }
            else{
                Throw "dotenv file '$($File.name)' must be named .env or .env.{whatever}"
            }


            $Data = [System.IO.File]::ReadAllText($File.FullName)
        }

        if ($Data){
            $Data|%{
                $DataArr.Add($_)
            }
        }
    }
    end {
        $DataArr|ForEach-Object{$_ -split [System.Environment]::NewLine}|Where-Object{$_ -notmatch "^\s*#.*$"}|Where-Object{$_}|ForEach-Object{
            $VarLine = $_.Split("=",2)
            $varName = $VarLine[0].Trim()
            $varValue = $VarLine[1].Trim()
            [System.Environment]::SetEnvironmentVariable($varName, $varValue, [System.EnvironmentVariableTarget]::Process)
            New-PwshOtelLog -Body "Set env '$Varname'"
        }
    }
}