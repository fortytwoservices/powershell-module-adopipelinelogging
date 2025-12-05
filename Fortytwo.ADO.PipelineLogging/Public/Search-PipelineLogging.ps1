function Search-PipelineLogging {
    [CmdletBinding(DefaultParameterSetName = "text")]

    Param(
        [Parameter(Mandatory = $true)]
        [string] $PipelineId,

        [Parameter(Mandatory = $true, ParameterSetName = "text")]
        [string] $Text,

        [Parameter(Mandatory = $true, ParameterSetName = "like")]
        [string] $Like,

        [Parameter(Mandatory = $true, ParameterSetName = "match")]
        [string] $Match,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Latest = [int]::MaxValue ,

        [Parameter(Mandatory = $false)]
        [DateTime] $Since = [datetime]::MinValue 
    )

    Process {
        Write-Verbose "Getting runs for pipeline $PipelineId"
        $runs = Get-PipelineLoggingPipelineRun -PipelineId $PipelineId | 
        Where-Object finishedDate | 
        Sort-Object finishedDate -Descending | 
        Where-Object { $_.finishedDate -ge $Since } |
        Select-Object -First $Latest

        $runs |
        ForEach-Object {
            $run = $_ # $run = $runs | get-random -count 1
            Write-Verbose "Getting run log for run $($run.id) (PipelineId $PipelineId)"
            $runlogs = Get-PipelineLoggingPipelineRunLog -PipelineId $PipelineId -RunId $run.id

            $runlogs | ForEach-Object {
                $runlog = $_ # $runlog = $runlogs | get-random -count 1
                Write-Verbose "Getting log content for log $($runlog.id) (RunId $($run.id) PipelineId $PipelineId)"
                $content = $runlog | Get-PipelineLoggingPipelineRunLogContent

                $line = 0
                $content.Split("`n") | ForEach-Object {
                    $line += 1

                    if (
                        ($PSCmdlet.ParameterSetName -eq "text" -and $_.Contains($Text)) -or
                        ($PSCmdlet.ParameterSetName -eq "like" -and $_ -like "$Like") -or
                        ($PSCmdlet.ParameterSetName -eq "match" -and $_ -match $Match)
                    ) {
                        [PSCustomObject] @{
                            url         = "https://dev.azure.com/$($Script:Organization)/$($Script:Project)/_build/results?buildId=$($run.id)&view=results"
                            pipelineId  = $PipelineId
                            runId       = $run.id
                            runlogId    = $runlog.id
                            lineNumber  = $line
                            lineContent = $_
                        }
                    }
                }
            }
        }
    }
}