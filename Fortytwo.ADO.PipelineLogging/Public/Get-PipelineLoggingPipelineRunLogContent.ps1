function Get-PipelineLoggingPipelineRunLogContent {
    [CmdletBinding(DefaultParameterSetName = "default")]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $SignedContent
    )

    Process {
        if (!$SignedContent.url) {
            throw "SignedContent object does not contain a URL."
        }

        if (!$SignedContent.signatureExpires) {
            throw "SignedContent object does not contain a signature expiry."
        }

        if ((Get-Date).ToUniversalTime() -gt (Get-Date $SignedContent.signatureExpires)) {
            throw "The signed URL has expired."
        }

        Invoke-RestMethod -Uri $SignedContent.url
    }
}