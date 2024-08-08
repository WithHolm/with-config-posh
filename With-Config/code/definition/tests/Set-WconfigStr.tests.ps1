Describe "Set-WconfigStr" {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }

    It "Should return a hashtable with minimum configuration" {
        $Conf = Set-WconfigStr -Name "Test"
        $conf | should -Not -BeNullOrEmpty
        $conf | should -BeOfType [hashtable]
        $Conf._name | Should -not -BeNullOrEmpty
        $Conf._required | Should -Not -BeNullOrEmpty
        $Conf.minimum | Should -BeNullOrEmpty
        $Conf.maximum | Should -BeNullOrEmpty
    }

    it "Should throw if name is empty" {
        { Set-WconfigStr -Name "" } | Should -Throw
    }

    It "should return string as type" {
        $Conf = Set-WconfigStr -Name "Test"
        $Conf.type | Should -Be "string"
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
        $Conf = Set-WconfigStr -Name "Test" @param
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
        $Conf = Set-WconfigStr -Name "Test" @param
        if ($param.description) {
            $Conf.description | Should -Be "Test"
        } else {
            $Conf.description | Should -BeNullOrEmpty
        }
    }
    context "Enum" {
        It "should add a enum only when it is not empty (test:<test>)" -TestCases @(
            @{
                test  = "Defined"
                param = @{
                    Enum = @("Test")
                }
            }
            @{
                test  = "Empty"
                param = @{}
            }
        ) {
            param($test, $param)
            $Conf = Set-WconfigStr -Name "Test" @param
            if ($param.enum) {
                $Conf.enum | Should -Be @("Test")
            } else {
                $Conf.enum | Should -BeNullOrEmpty
            }
        }

        it "Enum should be a string list if given <test>"-TestCases @(
            @{
                test  = "Normal"
                param = @{
                    Enum = @("Test")
                }
            }
            @{
                test  = "Int"
                param = @{
                    Enum = @(1)
                }
            }
            @{
                test  = "Object"
                param = @{
                    Enum = @(New-Object psobject)
                }
            }
            @{
                test  = "Bool"
                param = @{
                    Enum = $true
                }
            }
        ) {
            param($test, $param)
            $Conf = Set-WconfigStr -Name "Test" @param
            $Conf.enum -is [System.Collections.Generic.List[string]] | Should -BeTrue
        }
    }
    Context "Default" {
        It "should add a default only when it is not empty (test:<test>)" -TestCases @(
            @{
                test  = "Defined"
                param = @{
                    Default = "Test"
                }
            }
            @{
                test  = "Empty"
                param = @{}
            }
        ) {
            param($test, $param)
            $Conf = Set-WconfigStr -Name "Test" @param
            if ($param.default) {
                $Conf.default | Should -Be "Test"
            }
        }
        It "should emit default as string given <test>" -TestCases @(
            @{
                test  = "String"
                param = @{
                    Default = "Test"
                }
            }
            @{
                test  = "Int"
                param = @{
                    Default = 1
                }
            }
            @{
                test  = "Bool"
                param = @{
                    Default = $true
                }
            }
            @{
                test  = "Object"
                param = @{
                    Default = [pscustomobject]@{
                        key = "value"
                    }
                }
            }
            @{
                test  = "str Array"
                param = @{
                    Default = @("Test")
                }
            }
            @{
                test  = "Hashtable"
                param = @{
                    Default = @{
                        key = "value"
                    }
                }
            }
        ) {
            param($test, $param)
            $Conf = Set-WconfigStr -Name "Test" @param
            $Conf.default | Should -BeOfType [string]
        }
        # it "Should throw if default is not a allowed type <test>" -TestCases @(
        #     @{
        #         test  = "Array"
        #         param = @{
        #             Default = @(1)
        #         }
        #     }
        #     @{
        #         test  = "Hashtable"
        #         param = @{
        #             Default = @{
        #                 key = "value"
        #             }
        #         }
        #     }
        #     @{
        #         test  = "Object"
        #         param = @{
        #             Default = [pscustomobject]@{
        #                 key = "value"
        #             }
        #         }
        #     }
        # ) {
        #     param($test, $param)
        #     {
        #         Set-WconfigStr -Name "Test" @param
        #     } | Should -Throw
        # }
    }
}