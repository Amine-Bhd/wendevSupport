param(
    [string]$ResourceGroup = "rg-wendev-k8s",
    [string]$AcrName = "acrwendevsupportamine",
    [string]$Namespace = "wendev",
    [string]$PgUser = "tickets",
    [string]$PgPassword = "tickets-demo-password"
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

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$AzureK8sDir = Join-Path $RepoRoot "k8s\azure"
$RenderedDir = Join-Path $PSScriptRoot "rendered"

Write-Host "== Lecture du login server ACR =="
$AcrLoginServer = Invoke-Az acr show `
    --resource-group $ResourceGroup `
    --name $AcrName `
    --query loginServer `
    --output tsv

Write-Host "ACR login server: $AcrLoginServer"

Write-Host "== Generation des manifests Azure =="
New-Item -ItemType Directory -Force $RenderedDir | Out-Null

Get-ChildItem $RenderedDir -Filter *.yaml | Remove-Item -Force

Get-ChildItem $AzureK8sDir -Filter *.yaml |
    Where-Object { $_.Name -ne "02-secret.example.yaml" } |
    ForEach-Object {
        $TargetPath = Join-Path $RenderedDir $_.Name
        (Get-Content $_.FullName -Raw).Replace("__ACR_LOGIN_SERVER__", $AcrLoginServer) |
            Set-Content -Encoding UTF8 $TargetPath
    }

Write-Host "== Application du Namespace et de la configuration =="
kubectl apply -f (Join-Path $RenderedDir "00-namespace.yaml")
kubectl apply -f (Join-Path $RenderedDir "01-configmap.yaml")

Write-Host "== Creation du Secret PostgreSQL =="
kubectl create secret generic tickets-secret `
    --namespace $Namespace `
    --from-literal=PGUSER=$PgUser `
    --from-literal=PGPASSWORD=$PgPassword `
    --dry-run=client `
    --output yaml |
    kubectl apply -f -

Write-Host "== Deploiement PostgreSQL, backend et frontend =="
kubectl apply -f (Join-Path $RenderedDir "03-postgres.yaml")
kubectl apply -f (Join-Path $RenderedDir "04-backend.yaml")
kubectl apply -f (Join-Path $RenderedDir "05-frontend-loadbalancer.yaml")

Write-Host "== Attente du rollout frontend/backend =="
kubectl rollout status deployment/backend-api -n $Namespace --timeout=180s
kubectl rollout status deployment/frontend -n $Namespace --timeout=180s

Write-Host "== Etat Kubernetes =="
kubectl get pods -n $Namespace -o wide
kubectl get svc -n $Namespace

Write-Host "Deploiement termine. Attendre que EXTERNAL-IP du Service frontend ne soit plus <pending>."
