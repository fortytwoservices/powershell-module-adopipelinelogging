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

        [Parameter(Mandatory = $true, ParameterSetName = "default")]
        [string] $Organization,

        [Parameter(Mandatory = $true, ParameterSetName = "default")]
        [string] $Project,

        [Parameter(Mandatory = $true, ParameterSetName = "url")]
        [string] $Url
    )
    
    Process {
        if ($PSCmdlet.ParameterSetName -eq "url") {
            $uri = [System.Uri]$Url
            if ($uri.Host -ne "dev.azure.com") {
                throw "Invalid Azure DevOps URL: $Url"
            }

            $segments = $uri.Segments | ForEach-Object { $_.TrimEnd('/') }
            
            if ($segments[2] -eq "_git") {
                if ($segments.Length -lt 4) {
                    throw "Invalid Azure DevOps URL (must include project): $Url"
                }

                $Organization = $segments[1]?.TrimEnd('/')
                $Project = $segments[3]?.TrimEnd('/')
            }
            else {
                $Organization = $segments[1]?.TrimEnd('/')
                $Project = $segments[2]?.TrimEnd('/')

                if ($segments.Length -lt 3) {
                    throw "Invalid Azure DevOps URL (must include project): $Url"
                }
            }
        }
        $Script:Headers = @{
            Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PAT)))")))"
        }
        $Script:Organization = $Organization
        $Script:Project = $Project
        $Script:ProjectResource = Get-PipelineLoggingResource -Url "https://dev.azure.com/$($Organization)/_apis/projects/$($Project)" -Single

        if (!$Script:ProjectResource) {
            throw "Unable to get project '$Project' in organization '$Organization'"
        }
        else {
            Write-Verbose "Connected to project '$Project' ($($Script:ProjectResource.id)) in organization '$Organization'"
        }
    }
}
