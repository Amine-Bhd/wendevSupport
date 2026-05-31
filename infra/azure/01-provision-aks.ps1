param(
    [string]$ResourceGroup = "rg-wendev-k8s",
    [string]$Location = "westeurope",
    [string]$AksName = "aks-wendev-support",
    [string]$AcrName = "acrwendevsupportamine",
    [string]$NodeVmSize = "Standard_B2s",
    [int]$NodeCount = 2
)

$ErrorActionPreference = "Stop"

Write-Host "== Verification du compte Azure =="
az account show --output table

Write-Host "== Creation du Resource Group =="
az group create `
    --name $ResourceGroup `
    --location $Location `
    --output table

Write-Host "== Creation Azure Container Registry =="
az acr create `
    --resource-group $ResourceGroup `
    --name $AcrName `
    --sku Basic `
    --admin-enabled false `
    --output table

Write-Host "== Build image backend dans ACR =="
az acr build `
    --registry $AcrName `
    --image wendev-tickets-backend:v1 `
    app/backend

Write-Host "== Build image frontend dans ACR =="
az acr build `
    --registry $AcrName `
    --image wendev-tickets-frontend:v1 `
    app/frontend

Write-Host "== Creation du cluster AKS =="
az aks create `
    --resource-group $ResourceGroup `
    --name $AksName `
    --node-count $NodeCount `
    --node-vm-size $NodeVmSize `
    --generate-ssh-keys `
    --attach-acr $AcrName `
    --output table

Write-Host "== Recuperation du contexte kubectl AKS =="
az aks get-credentials `
    --resource-group $ResourceGroup `
    --name $AksName `
    --overwrite-existing

Write-Host "== Verification des noeuds AKS =="
kubectl get nodes -o wide

Write-Host "Provisionnement termine."
