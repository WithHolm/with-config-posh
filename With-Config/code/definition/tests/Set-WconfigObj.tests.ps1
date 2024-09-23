describe 'Set-WConfigObj' {
    BeforeAll {
        Set-PwshOtelTraceOptions -OutputToConsole Disabled
    }

    it 'should return a hashtable' {
        $out = Set-WConfigObj -Name 'test'
        $out.type | Should -Be 'object'
        $out | Should -BeOfType [hashtable]
    }

    it "should throw if the name is invalid" {
        {Set-WConfigObj -Name 'test.test'}| Should -Throw
    }
    
    it "should set allowed other properties if provided (test:<name>)" -testcases @(
        @{
            name = 'enabled'
            param = @{
                AllowOtherProperties = $true
            }
        }
        @{
            name = 'disabled'
            param = @{
                AllowOtherProperties = $false
            }
        }
    ) {
        param ($name, $param)

        $out = Set-WConfigObj -Name 'test' @param
        $out.additionalProperties | Should -Be $param.AllowOtherProperties
    }
}