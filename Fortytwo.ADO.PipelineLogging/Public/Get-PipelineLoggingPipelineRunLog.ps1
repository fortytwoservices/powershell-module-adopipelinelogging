function Get-PipelineLoggingPipelineRunLog {
    [CmdletBinding(DefaultParameterSetName = "default")]

    Param(
        [Parameter(Mandatory = $true)]
        [string] $PipelineId,
        
        [Parameter(Mandatory = $true)]
        [string] $RunId
    )

    Process {
        Get-PipelineLoggingResource "pipelines/$PipelineId/runs/$RunId/logs?`$expand=signedContent" -Single | Select-Object -ExpandProperty logs
    }
}