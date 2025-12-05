function Get-PipelineLoggingPipelineRun {
    [CmdletBinding(DefaultParameterSetName = "pipeline")]

    Param(
        [Parameter(Mandatory = $true)]
        [string] $PipelineId,
        
        [Parameter(Mandatory = $true, ParameterSetName = "run")]
        [string] $RunId
    )

    Process {
        if ($PSCmdlet.ParameterSetName -eq "pipeline") {
            Get-PipelineLoggingResource "pipelines/$PipelineId/runs"
        }
        else {
            Get-PipelineLoggingResource "pipelines/$PipelineId/runs/$RunId" -Single
        }
    }
}