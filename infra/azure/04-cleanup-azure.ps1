param(
    [string]$ResourceGroup = "rg-wendev-k8s"
)

$ErrorActionPreference = "Stop"

Write-Host "Cette commande supprime toutes les ressources Azure du Resource Group: $ResourceGroup"
Write-Host "Appuyer sur Ctrl+C pour annuler, ou Entree pour continuer."
Read-Host

az group delete `
    --name $ResourceGroup `
    --yes `
    --no-wait

Write-Host "Suppression demandee. Verifier dans le portail Azure que les ressources disparaissent."
