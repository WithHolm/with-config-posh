function Format-WConfigItem {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [parameter(
            ValueFromPipeline = $true
        )]
        [hashtable]$Object
    )
    process{
        $Keys = $Object.Keys|?{$_ -like "_*"}
        $Keys|foreach-object {
            $Object.Remove($_)
        }
        # return $Object
    }
}