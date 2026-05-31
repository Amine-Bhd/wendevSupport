# Wendev Tickets - Démonstration Kubernetes

Ce projet sert de support pratique pour apprendre Kubernetes à travers le déploiement d'une application simple de gestion de tickets.

## Objectif

Démontrer :

- la conteneurisation avec Docker ;
- le déploiement sur Kubernetes ;
- la redondance avec plusieurs replicas ;
- l'exposition via Ingress ;
- l'auto-réparation après suppression d'un Pod ;
- le scaling manuel.

## Architecture

```text
Utilisateur
  -> Ingress NGINX
  -> Frontend
  -> Backend API
  -> PostgreSQL
```

## Structure

```text
app/              Code frontend et backend
k8s/              Manifests Kubernetes
infra/kind/       Configuration du cluster local kind
diagrams/         Diagrammes Mermaid
rapport/          Documents du rapport en français
presentation/     Plan, slides et script de démonstration
screenshots/      Captures de l'application
```

## Démarrage local

Construire les images :

```powershell
docker build -t wendev-tickets-backend:local app/backend
docker build -t wendev-tickets-frontend:local app/frontend
```

Créer le cluster kind :

```powershell
kind create cluster --config infra/kind/kind-cluster.yaml
```

Charger les images dans kind :

```powershell
kind load docker-image wendev-tickets-backend:local --name wendev-local
kind load docker-image wendev-tickets-frontend:local --name wendev-local
```

Préparer le Secret local :

```powershell
Copy-Item k8s\examples\02-secret.example.yaml k8s\02-secret.yaml
```

Déployer l'application :

```powershell
kubectl apply -f k8s
```

Installer Ingress NGINX pour kind :

```powershell
kubectl apply -f https://cdn.jsdelivr.net/gh/kubernetes/ingress-nginx@controller-v1.15.1/deploy/static/provider/kind/deploy.yaml
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type merge --patch-file infra/kind/ingress-nginx-node-selector-patch.yaml
```

Tester :

```powershell
curl.exe http://127.0.0.1:8080/api/health
```

URL locale :

```text
http://127.0.0.1:8080
```

## Démonstration

Le déroulé de soutenance est disponible dans :

```text
presentation/script_demonstration_kubernetes.md
```

Les slides sont disponibles dans :

```text
presentation/slides_soutenance_kubernetes.md
```

## Déploiement Azure AKS

La version cloud est préparée dans :

```text
infra/azure/
k8s/azure/
rapport/phase5_deploiement_azure_aks.md
```

Déroulé prévu :

```powershell
.\infra\azure\01-provision-aks.ps1
.\infra\azure\02-deploy-app.ps1
.\infra\azure\03-check-app.ps1
```

Le script de nettoyage des ressources Azure est :

```powershell
.\infra\azure\04-cleanup-azure.ps1
```

## Note de sécurité

Le fichier `k8s/02-secret.yaml` est ignoré par Git. Il faut créer ce fichier localement à partir de `k8s/examples/02-secret.example.yaml`.

Pour une version cloud ou publique, il faut remplacer les secrets de démonstration par une solution adaptée : GitHub Secrets, Azure Key Vault, variables d'environnement sécurisées ou Secret Kubernetes généré au moment du déploiement.
