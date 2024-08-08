Describe "Format-WconfigItem"{
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }
    it "should remove all items that starts with underscore"{
        $k = @{
            key = "val"
            key2 = "val2"
            _key = "val"
        }
        Format-WConfigItem -Object $k
        $k.count |Should -be 2
        $k._key |should -BeNullOrEmpty
    }
}