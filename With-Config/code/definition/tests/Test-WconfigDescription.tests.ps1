Describe "Test-WConfigDescription" {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }
    It "Should return true for a valid description" {
        $Result = Test-WConfigDescription -Description "This is a valid description." -Name "test"
        $Result | Should -BeTrue
    }
    it "Should accept empty descriptions" -TestCases @(
        @{
            Description = ""
            Name = "empty"
        }
        @{
            Description = $null
            Name = "null"
        }
    ) {
        param(
            [String]$Description,
            [String]$Name
        )
        $Result = Test-WConfigDescription -Description $Description -Name $Name
        $Result | Should -BeTrue
    }
    It "Should return false for for description that starts with anything other than Uppercase a-z (test:<name>)" -TestCases @(
        @{
            Description = " this should fail."
            Name = "space in front"
        }
        @{
            Description = "this should fail."
            Name = "lowercase"
        }
    ) {
        param(
            [String]$Description,
            [String]$Name
        )
        $Result = Test-WConfigDescription -Description $Description -Name $Name
        # $Result = Test-WConfigDescription -Description "this is a valid description." -Name "test"
        $Result | Should -BeFalse
    }
    it "Should return false for for description that does not end with a period (test:<name>)" -TestCases @(
        @{
            Description = "this should fail"
            Name = "no period"
        }
        @{
            Description = "this should fail. "
            Name = "period then space"
        }

     )     {
        param(
            [String]$Description,
            [String]$Name
        )
         $Result = Test-WConfigDescription -Description $Description -Name $Name
         $Result | Should -BeFalse
     }
}