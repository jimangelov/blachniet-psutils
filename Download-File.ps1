[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string] $Source,
    
    [Parameter(Mandatory=$True)]
    [string] $Destination
)

$wc = New-Object System.Net.WebClient

Write-Host "Downloading $Source, saving to $Destination..."
$wc.DownloadFile($Source, $Destination)
Write-Host "Download complete."