param(
    [string]$ResourceGroup = "rg-wendev-k8s"
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

Write-Host "Cette commande supprime toutes les ressources Azure du Resource Group: $ResourceGroup"
Write-Host "Appuyer sur Ctrl+C pour annuler, ou Entree pour continuer."
Read-Host

Invoke-Az group delete `
    --name $ResourceGroup `
    --yes `
    --no-wait

Write-Host "Suppression demandee. Verifier dans le portail Azure que les ressources disparaissent."
