Describe "Import-DotEnv" {
    BeforeDiscovery {
        $testcases = @(
            @{
                name    = "normal"
                content = @(
                    "Pester_FOO=bar",
                    "Pester_BAR=baz",
                    "Pester_BAZ=qux",
                    "Pester_QUX=quux"
                )
                keys    = @("Pester_FOO", "Pester_BAR", "Pester_BAZ", "Pester_QUX")
            }
            @{
                name    = "commented"
                content = @(
                    "Pester_FOO=bar",
                    "#Pester_BAR=baz",
                    "Pester_BAZ=qux",
                    "Pester_QUX=quux"
                    "#OtherComment"
                )
                keys    = @("Pester_FOO", "Pester_BAZ", "Pester_QUX")
                nonkey  = @("Pester_BAR")
            }
        )
    }
    BeforeEach {
        Set-PwshOtelTraceOptions -IgnoreLogs Enabled -OutputToConsole Disabled
    }

    AfterEach{
        gci env:pester_*|ForEach-Object{
            [System.Environment]::SetEnvironmentVariable($_.Name, "", [System.EnvironmentVariableTarget]::Process)
        }
    }

    context "param file" {

        It "should import <name> .env file" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
            $Path = join-path $testdrive ".env"
            Set-Content $Path -Value ($content -join [System.Environment]::NewLine)
            { Import-DotEnv -File $Path } | Should -Not -Throw
            $keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }
            $nonkey | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -BeNullOrEmpty
            }
            Remove-EnvKeys:Pester $keys
        }

        It "should import .env.<name> file" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
            $Path = join-path $testdrive ".env.$name"
            Set-Content $Path -Value ($content -join [System.Environment]::NewLine)
            { Import-DotEnv -File $Path } | Should -Not -Throw
            $keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }

            #extra check for commented dotenv files
            $nonkey | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -BeNullOrEmpty
            }
        }

        it "should throw on invalid file name (<name>.env)" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
            $Path = join-path $testdrive "$name.env"
            Set-Content $Path -Value ($EnvFile_normal.content -join [System.Environment]::NewLine)
            { Import-DotEnv -File $Path } | Should -Throw
        }

        it "should import .env files from pipeline (as string object)" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
            $Path = join-path $testdrive ".env"
            Set-Content $Path -Value ($content -join [System.Environment]::NewLine)
            { $Path | Import-DotEnv } | Should -Not -Throw
            $keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }
            $nonkey | ForEach-Object {
                $k = $_
                [System.Environment]::GetEnvironmentVariable($k) | Should -BeNullOrEmpty -Because "key '$k' should not be set"
            }
        }

        it "should import .env files from pipeline (as file object)" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
            $Path = join-path $testdrive ".env"
            Set-Content $Path -Value ($content -join [System.Environment]::NewLine)
            { $Path | get-item | Import-DotEnv } | Should -Not -Throw
            $keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }
            $nonkey | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -BeNullOrEmpty
            }
        }
    }

    context "param data"{
        It "should import <name> .env content string" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
    
            { Import-DotEnv -Data $EnvFile_normal.content } | Should -Not -Throw
    
            $EnvFile_normal.keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }
            $nonkey | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -BeNullOrEmpty
            }
        }
        It "should import <name> .env content string from pipeline" -TestCases $testcases {
            param(
                $name,
                $content,
                $keys,
                $nonkey
            )
    
            { $EnvFile_normal.content|Import-DotEnv} | Should -Not -Throw
    
            $EnvFile_normal.keys | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -not -BeNullOrEmpty
            }
            $nonkey | ForEach-Object {
                [System.Environment]::GetEnvironmentVariable($_) | Should -BeNullOrEmpty
            }
        }

    }
}