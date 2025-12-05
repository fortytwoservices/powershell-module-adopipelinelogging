<#
.SYNOPSIS
Connects to Azure DevOps Pipeline Logging module.

.EXAMPLE
Connect-PipelineLogging
#>
function Connect-PipelineLogging {
    [CmdletBinding(DefaultParameterSetName = "default")]

    Param
    (
        [Parameter(Mandatory = $true)]
        [SecureString] $PAT,

        [Parameter(Mandatory = $true)]
        [string] $Organization,

        [Parameter(Mandatory = $true)]
        [string] $Project
    )
    
    Process {
        $Script:Headers = @{
            Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PAT)))")))"
        }
        $Script:Organization = $Organization
        $Script:Project = $Project
        $Script:ProjectResource = Get-PipelineLoggingResource -Url "https://dev.azure.com/$($Organization)/_apis/projects/$($Project)" -Single

        if(!$Script:ProjectResource) {
            throw "Unable to get project '$Project' in organization '$Organization'"
        } else {
            Write-Verbose "Connected to project '$Project' ($($Script:ProjectResource.id)) in organization '$Organization'"
        }
    }
}
