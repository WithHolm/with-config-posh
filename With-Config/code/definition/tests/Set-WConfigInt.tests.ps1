Describe "Set-WconfigInt" {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }
    It "Should return a hashtable with minimum configuration" {
        $Conf = Set-WconfigInt -Name "Test"
        $conf | should -Not -BeNullOrEmpty
        $conf | should -BeOfType [hashtable]
        $Conf._name | Should -not -BeNullOrEmpty
        $Conf._required | Should -Not -BeNullOrEmpty
        $Conf.minimum | Should -BeNullOrEmpty
        $Conf.maximum | Should -BeNullOrEmpty
    }
    It "should return int as type" {
        $Conf = Set-WconfigInt -Name "Test"
        $Conf.type | Should -Be "int"
    }
    It "should return _required value if -required set to <test>" -TestCases @(
        @{
            test  = "True"
            param = @{
                Required = $true
            }
        }
        @{
            test  = "False"
            param = @{
                Required = $false
            }
        }
    ) {
        param($test, $param)
        $Conf = Set-WconfigInt -Name "Test" @param
        $Conf._required | Should -Be $test
    }
    It "should add a description only when it is not empty (test:<test>)" -TestCases @(
        @{
            test  = "Defined"
            param = @{
                Description = "Test"
            }
        }
        @{
            test  = "Empty"
            param = @{}
        }
    ) {
        param($test, $param)
        $Conf = Set-WconfigInt -Name "Test" @param
        if ($param.description) {
            $Conf.description | Should -Be "Test"
        } else {
            $Conf.description | Should -BeNullOrEmpty
        }
    }
    it "should add a minimum only when it is not empty (test:<test>)" -TestCases @(
        @{
            test  = "Defined"
            param = @{
                Min = "1"
            }
        }
        @{
            test  = "Empty"
            param = @{}
        }
    ) {
        param($test, $param)
        $Conf = Set-WconfigInt -Name "Test" @param
        if ($param.min) {
            $Conf.minimum | Should -Be 1
        } else {
            $Conf.minimum | Should -BeNullOrEmpty
        }
    }
    It "should add a maximum only when it is not empty (test:<test>)" -TestCases @(
        @{
            test  = "Defined"
            param = @{
                Max = "1"
            }
        }
        @{
            test  = "Empty"
            param = @{}
        }
    ) {
        param($test, $param)
        $Conf = Set-WconfigInt -Name "Test" @param
        if ($param.max) {
            $Conf.maximum | Should -Be 1
        } else {
            $Conf.maximum | Should -BeNullOrEmpty
        }
    }
}