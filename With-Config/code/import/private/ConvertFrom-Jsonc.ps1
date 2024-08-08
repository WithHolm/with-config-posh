function ConvertFrom-Jsonc {
    [CmdletBinding()]
    param (
        [parameter(
            ValueFromPipeline
        )]
        [string[]]$InputData,
        [switch]$ToString,
        [switch]$AsHashtable,
        [ValidateRange(1, 99)]
        [int]$Depth = 32
    )
    begin{
        $Str = [System.Collections.Generic.List[string]]::new()
        $InComment = $false
    }
    process {
        ($InputData -split [System.Environment]::NewLine) | ForEach-Object {
            $line = $_

            #replace '//comment' with ""
            $Line = $line -replace "^\s*\/\/.*$", ""

            #region /**/ comments
            #replace '/*comment*/' with ""
            $Line = $line -replace "\/\*.*\*\/", ""

            if($Line -match "\/\*" -and -not $InComment){
                $InComment = $true
            }

            #if comment is closed, remove the closing comment
            #in: {whatever}*/"data":"true"
            #out: "data":"true"
            if($Line -match "\*\/" -and $InComment){
                $Line = $Line -replace "\*\/", ""
                $InComment = $false
            }

            #if comment is still open, remove the line
            if($InComment){
                continue
            }
            #endregion /**/ comments

            #remove empty lines
            if([string]::IsNullOrWhiteSpace($line)){
                continue
            }
            $Str.Add($line)
        }
    }
    end {
        $OutStr = $str -join [System.Environment]::NewLine
        if ($ToString) {
            return $OutStr
        } else {
            $param = @{
                Depth     = $Depth
            }
            # not supported in PS5.1 so its optional
            if($AsHashtable){
                $param.AsHashtable = $true
            }
            $OutStr | ConvertFrom-Json @param
        }
    }
}