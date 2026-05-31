param(
    [string]$ResourceGroup = "rg-wendev-k8s",
    [string]$AksName = "aks-wendev-support"
)

$ErrorActionPreference = "Stop"

$AzCli = (Get-Command az -ErrorAction SilentlyContinue).Source
if (-not $AzCli) {
    $AzCli = "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd"
}

function Invoke-Az {
    & $AzCli @args
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: az $($args -join ' ')"
    }
}

Write-Host "== Arret du cluster AKS pour reduire les couts compute =="
Invoke-Az aks stop `
    --resource-group $ResourceGroup `
    --name $AksName

Write-Host "Cluster AKS arrete. Les objets Kubernetes sont conserves, mais les nodes ne consomment plus de compute."
