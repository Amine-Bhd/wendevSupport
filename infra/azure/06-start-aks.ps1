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

Write-Host "== Demarrage du cluster AKS =="
Invoke-Az aks start `
    --resource-group $ResourceGroup `
    --name $AksName

Write-Host "== Recuperation du contexte kubectl AKS =="
Invoke-Az aks get-credentials `
    --resource-group $ResourceGroup `
    --name $AksName `
    --overwrite-existing

Write-Host "== Verification des nodes =="
kubectl get nodes -o wide
