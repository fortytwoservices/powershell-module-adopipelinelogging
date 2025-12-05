function Get-PipelineLoggingPipeline {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $false)]
        [string] $PipelineId
    )

    Process {
        if ($PipelineId) {
            Get-PipelineLoggingResource -Url "pipelines/$PipelineId" -Single
        }
        else {
            Get-PipelineLoggingResource -Url "pipelines"
        }
    }
}