Import-Module ./Fortytwo.ADO.PipelineLogging -Force -Verbose
$PAT ??= Read-Host -AsSecureString "Enter your Azure DevOps Personal Access Token"
Connect-PipelineLogging -PAT $PAT -Organization "ORG" -Project "PROJECT"

$pipelines = Get-PipelineLoggingPipeline | Where-Object name -like "PROD - Additional account*"

$date = (Get-Date).AddDays(-7)
$lastruns = 5

$logcontent = $pipelines | ForEach-Object {
    $pipeline = $_ # $pipeline = $pipelines | get-random -count 1
    
    Get-PipelineLoggingPipelineRun -PipelineId $pipeline.id | 
    Where-Object finishedDate -gt $date |
    Select-Object -First $lastruns |
    ForEach-Object {
        $run = $_
        # read-host -Prompt "Pipeline: $($pipeline.name) RunId: $($run.id) Finished: $($run.finishedDate) - Press Enter to get logs"
        $runlogs = Get-PipelineLoggingPipelineRunLog -PipelineId $pipeline.id -RunId $run.id -Verbose

        $runlogs | ForEach-Object {
            $runlog = $_
            
            # read-host "Pipeline: $($pipeline.name) RunId: $($run.id) LogId: $($runlog.id) CreatedOn: $($runlog.createdOn) - Press Enter to get log content"
            $content = $runlog | Get-PipelineLoggingPipelineRunLogContent

            [PSCustomObject] @{
                pipelineId      = $pipeline.id
                pipelineName    = $pipeline.name
                pipelineFolder  = $pipeline.folder
                runId           = $run.id
                runName         = $run.name
                runResult       = $run.result
                runState        = $run.state
                runCreatedDate  = $run.createdDate
                runFinishedDate = $run.finishedDate
                runlogId        = $runlog.id
                runlogLineCount = $runlog.lineCount
                runlogCreatedOn = $runlog.createdOn
                content         = $content
            }
        }
    }
}


$logentries = $logcontent | ForEach-Object {
    $item = $_ # $item = $logcontent | get-random -count 1
    if ($item.content) {
        $item.content.Split("`n") | Where-Object { $_ -match "^[0-9]{4}-[0-9]{2}-[0-9]{2}" } | ForEach-Object {
            $split = $_.Split(" ", 2)
            [PSCustomObject] @{
                timestamp    = [datetime]$split[0]
                pipelineId   = $item.pipelineId
                pipelineName = $item.pipelineName
                runId        = $item.runId
                runName      = $item.runName
                runLogId     = $item.runlogId
                logLine      = $split[1]?.Trim()
            }
        }
    }
}