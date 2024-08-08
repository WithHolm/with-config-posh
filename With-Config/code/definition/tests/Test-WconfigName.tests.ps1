Describe "Test-WconfigName" {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }
    it "should disallow name with spaces"{
        "name with space"|Test-WConfigName|should -be $false
    }
}