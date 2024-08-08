Describe "Set-WconfigBool" {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }

    It "Should return a hashtable with minimum configuration" {
        $Conf = Set-WconfigBool -Name "Test"
        $conf | should -Not -BeNullOrEmpty
        $conf | should -BeOfType [hashtable]
        $Conf._name | Should -not -BeNullOrEmpty
        $Conf._required | Should -Not -BeNullOrEmpty
    }
    
    it "Should throw if name is empty" {
        { Set-WconfigBool -Name "" } | Should -Throw
    }

    It "should return bool as type" {
        $Conf = Set-WconfigBool -Name "Test"
        $Conf.type | Should -Be "bool"
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
        $Conf = Set-WconfigBool -Name "Test" @param
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
        $Conf = Set-WconfigBool -Name "Test" @param
        if ($param.description) {
            $Conf.description | Should -Be "Test"
        } else {
            $Conf.description | Should -BeNullOrEmpty
        }
    }
    Context "Default" {
        It "should add a default only when it is not empty (test:<test>)" -TestCases @(
            @{
                test  = "Defined true"
                param = @{
                    Default = $true
                }
            }
            @{
                test  = "Defined false"
                param = @{
                    Default = $false
                }
            }
            @{
                test  = "Empty"
                param = @{}
            }
        ) {
            param($test, $param)
            $Conf = Set-WconfigBool -Name "Test" @param
            if ($param.default) {
                $Conf.default | Should -Be $true
            }
        }
    }
}