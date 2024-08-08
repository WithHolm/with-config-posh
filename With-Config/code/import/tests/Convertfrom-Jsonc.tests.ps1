Describe "ConvertFrom-Jsonc" {
    BeforeDiscovery{
        #import all files where first folder is test category, and files have {type}.{name}.jsonc. baseline.jsonc is the baseline file
        $TestData = gci "$psscriptroot\Convertfrom-Jsonc-testdata" -Recurse -File |?{$_.name -notlike 'baseline*'} | ForEach-Object {
            $l = @{
                complexity = $_.Directory.parent.Name
                category = $_.Directory.Name.replace("-"," ")
                type = $_.BaseName.split(".")[0]
                name = $_.BaseName.split(".")[1].replace("-"," ")
                file = $_.FullName
                data = (Get-Content $_.FullName)
            }
            $l.baseline = Get-Content "$psscriptroot\Convertfrom-Jsonc-testdata\$($l.complexity)\baseline.jsonc"
            $l
        }
        $own_line_testdata = $TestData|?{$_.category -eq "own-line"}
    }

    it "removes '<category>' comments on <complexity> jsonc @ <type> - <name>" -TestCases $TestData {
        param(
            [string]$complexity,
            [string]$category,
            [string]$type,
            [string]$name,
            [string]$file,
            [string[]]$data,
            [string[]]$baseline
        )

        $NewData = (ConvertFrom-Jsonc -InputData $data -ToString) -split [System.Environment]::NewLine
        for ($i = 0; $i -lt $NewData.Count; $i++) {
            $d = $NewData[$i] -replace "\s",""
            $b = $baseline[$i] -replace "\s",""
            $d |Should -Be $b -Because "line $i should be the same"
        }
    }

    it "can convert to json with '<category>' comments on '<complexity>' jsonc @ '<type>' '<name>'" -TestCases $TestData {
        param(
            [string]$complexity,
            [string]$category,
            [string]$type,
            [string]$name,
            [string]$file,
            [string[]]$data,
            [string[]]$baseline
        )
        {ConvertFrom-Jsonc -InputData $data} | Should -Not -Throw
    }

    it "can convert to object with '<category>' comments on '<complexity>' jsonc @ '<type>' '<name>'" -TestCases $TestData {
        param(
            [string]$complexity,
            [string]$category,
            [string]$type,
            [string]$name,
            [string]$file,
            [string[]]$data,
            [string[]]$baseline
        )
        $src = ConvertFrom-Jsonc -InputData $data 
        $baselineData = $baseline | ConvertFrom-Json
        $baselineData.psobject.properties.name | ForEach-Object {
            $n = $_
            $src.$n | Should -Be $baselineData.$n -Because "property $n should be the same"
        }
    }

    # #skipping on PS5.1 as it does not support -AsHashtable
    it "can convert to hashtable with '<category>' comments on '<complexity>' jsonc @ '<type>' '<name>'" -TestCases $TestData -Skip:($PSVersionTable.PSVersion.Major -lt 6) {
        param(
            [string]$complexity,
            [string]$category,
            [string]$type,
            [string]$name,
            [string]$file,
            [string[]]$data,
            [string[]]$baseline
        )
        ConvertFrom-Jsonc -InputData $data -AsHashtable | Should -BeOfType [hashtable]
    }
}