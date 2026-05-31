param(
    [string]$ResourceGroup = "rg-wendev-k8s",
    [string]$Location = "spaincentral",
    [string]$AksName = "aks-wendev-support",
    [string]$AcrName = "acrwendevsupportamine",
    [string]$NodeVmSize = "Standard_B2s_v2",
    [int]$NodeCount = 2
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

function Invoke-Docker {
    docker @args
    if ($LASTEXITCODE -ne 0) {
        throw "Docker command failed: docker $($args -join ' ')"
    }
}

Write-Host "== Verification du compte Azure =="
Invoke-Az account show --output table

Write-Host "== Enregistrement des providers Azure necessaires =="
Invoke-Az provider register --namespace Microsoft.ContainerService
Invoke-Az provider register --namespace Microsoft.ContainerRegistry
Invoke-Az provider register --namespace Microsoft.Compute
Invoke-Az provider register --namespace Microsoft.Network
Invoke-Az provider register --namespace Microsoft.Storage

Write-Host "== Creation du Resource Group =="
Invoke-Az group create `
    --name $ResourceGroup `
    --location $Location `
    --output table

Write-Host "== Creation Azure Container Registry =="
$AcrExists = $true
try {
    Invoke-Az acr show --resource-group $ResourceGroup --name $AcrName --output none
}
catch {
    $AcrExists = $false
}

if ($AcrExists) {
    Write-Host "ACR existe deja: $AcrName"
}
else {
    Invoke-Az acr create `
        --resource-group $ResourceGroup `
        --name $AcrName `
        --sku Basic `
        --admin-enabled false `
        --output table
}

Write-Host "== Login ACR =="
Invoke-Az acr login --name $AcrName

$AcrLoginServer = Invoke-Az acr show `
    --resource-group $ResourceGroup `
    --name $AcrName `
    --query loginServer `
    --output tsv

Write-Host "ACR login server: $AcrLoginServer"

Write-Host "== Build et push image backend =="
Invoke-Docker build -t "$AcrLoginServer/wendev-tickets-backend:v1" app/backend
Invoke-Docker push "$AcrLoginServer/wendev-tickets-backend:v1"

Write-Host "== Build et push image frontend =="
Invoke-Docker build -t "$AcrLoginServer/wendev-tickets-frontend:v1" app/frontend
Invoke-Docker push "$AcrLoginServer/wendev-tickets-frontend:v1"

Write-Host "== Creation du cluster AKS =="
$AksExists = $true
try {
    Invoke-Az aks show --resource-group $ResourceGroup --name $AksName --output none
}
catch {
    $AksExists = $false
}

if ($AksExists) {
    Write-Host "AKS existe deja: $AksName"
}
else {
    Invoke-Az aks create `
        --resource-group $ResourceGroup `
        --name $AksName `
        --node-count $NodeCount `
        --node-vm-size $NodeVmSize `
        --generate-ssh-keys `
        --attach-acr $AcrName `
        --output table
}

Write-Host "== Recuperation du contexte kubectl AKS =="
Invoke-Az aks get-credentials `
    --resource-group $ResourceGroup `
    --name $AksName `
    --overwrite-existing

Write-Host "== Verification des noeuds AKS =="
kubectl get nodes -o wide

Write-Host "Provisionnement termine."
