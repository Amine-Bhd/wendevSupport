param(
    [string]$Namespace = "wendev"
)

$ErrorActionPreference = "Stop"

Write-Host "== Noeuds AKS =="
kubectl get nodes -o wide

Write-Host "== Pods applicatifs =="
kubectl get pods -n $Namespace -o wide

Write-Host "== Services =="
kubectl get svc -n $Namespace

$ExternalIp = kubectl get svc frontend -n $Namespace -o jsonpath="{.status.loadBalancer.ingress[0].ip}"

if ([string]::IsNullOrWhiteSpace($ExternalIp)) {
    Write-Host "EXTERNAL-IP pas encore disponible. Reessayer dans quelques minutes."
    exit 1
}

Write-Host "URL publique: http://$ExternalIp"
Write-Host "Test health frontend:"
curl.exe "http://$ExternalIp/health"

Write-Host "Test health backend via frontend:"
curl.exe "http://$ExternalIp/api/health"
