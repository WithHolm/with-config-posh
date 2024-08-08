Describe "Set-WconfigArr"{
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }
    It "Should return a hashtable with minimum configuration"{
        $Conf = Set-WConfigArr "test" -Items {}
        $Conf|should -Not -BeNullOrEmpty
        $conf | should -BeOfType [hashtable]
        $Conf._name | Should -not -BeNullOrEmpty
        $Conf._required | Should -Not -BeNullOrEmpty
    }

    context "items"{
        it "all provided items should be of type hashtable"{
            $Conf = Set-WConfigArr -name "pester" -Items {
                Set-WConfigBol "test"
                Set-WConfigStr "test"
                $true
                "hey"
            }
            $conf.items.count|should -be 2
            $conf.items|%{
                $_ |should -BeOfType [hashtable]
            }
        }

        it "should return property as object if one item is provided"{
            $conf = Set-WConfigArr -name "test" -Items {
                Set-WConfigBol -Name "test"
            }
            $Conf.items|should -BeOfType [hashtable]
        }
    }

    # It "Should accept null scriptblock"{
    #     Set-WConfigArr "Test ing" -Items {}
    # }
}