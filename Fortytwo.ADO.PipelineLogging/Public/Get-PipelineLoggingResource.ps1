function Get-PipelineLoggingResource {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Url,

        [Parameter(Mandatory = $false)]
        [Switch] $Single
    )

    Process {
        if(!$Script:Headers) {
            throw "Please connect first"
        }
        
        if ($Url -notlike "*api-version*") {
            if ($Url.Contains("?")) {
                $Url += "&api-version=7.2-preview.1"
            }
            else {
                $Url += "?api-version=7.2-preview.1"
            }
            Write-Verbose "Appended api-version to URL: $Url"
        }

        if ($Url -notlike "http*") {
            $Url = "https://dev.azure.com/$($Script:Organization)/$($Script:Project)/_apis/$($Url.TrimStart("/"))"
            Write-Verbose "Constructed full URL: $Url"
        }


        if($Single.IsPresent) {
            Write-Verbose "Getting single resource from $Url"
            Invoke-RestMethod -Uri $Url -Headers $Script:Headers
        }

        while($Url) {
            Write-Verbose "Getting resources from $Url"
            $response = Invoke-RestMethod -Uri $Url -Headers $Script:Headers
            $response.value            
            $Url = $response.ContinuationToken
        }        
    }
}