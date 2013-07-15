[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string] $ProcessName
)

$activeProcess = Get-Process -N $ProcessName -ErrorAction SilentlyContinue
if ($activeProcess -eq $null)
{
    Write-Host "$ProcessName was not running"
}
else
{
    Stop-Process $activeProcess.Id
    Write-Host "Killed $ProcessName"
}