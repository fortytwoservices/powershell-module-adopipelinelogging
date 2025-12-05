BeforeAll {
    Import-Module -Name "$PSScriptRoot\..\" -Force
}

describe Get-PipelineLoggingResource {
    it "throws if not connected" {
        { Get-PipelineLoggingResource -Url "pipelines" } | should -throw
    }
}