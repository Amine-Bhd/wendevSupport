# Phase 5 - Déploiement cloud sur Azure Kubernetes Service

## 1. Objectif

Après validation locale avec kind, la phase Azure consiste à déployer la même application Wendev Tickets sur un cluster Kubernetes managé : Azure Kubernetes Service.

L'objectif n'est pas de remplacer la version locale, mais d'ajouter une version cloud en parallèle.

```text
Version locale kind
  -> apprentissage, tests rapides, démonstration hors connexion

Version Azure AKS
  -> exposition publique, infrastructure cloud, LoadBalancer Azure
```

## 2. Compte Azure

Azure CLI est installé :

```text
azure-cli 2.86.0
```

La connexion Azure CLI est validée avec la subscription :

```text
Nom : Azure for Students
ID : db23b29c-dc6c-4e7d-abaf-a148e637343b
Tenant : Default Directory
État : Enabled
Utilisateur : aminelous1@gmail.com
```

## 3. Choix retenus

Configuration proposée pour la première version cloud :

| Élément | Valeur |
| --- | --- |
| Région | `westeurope` |
| Resource Group | `rg-wendev-k8s` |
| Cluster AKS | `aks-wendev-support` |
| Azure Container Registry | `acrwendevsupportamine` |
| Nombre de nœuds | `2` |
| Taille des nœuds | `Standard_B2s` |
| Base de données | PostgreSQL dans le cluster |
| Exposition | Service Kubernetes de type `LoadBalancer` |

Ce choix permet de garder une architecture simple, compréhensible et adaptée à la soutenance.

## 4. Différence entre local et Azure

En local :

- les images Docker sont chargées directement dans kind ;
- l'application est exposée via NGINX Ingress sur `127.0.0.1:8080` ;
- le cluster est simulé sur la machine locale.

Sur Azure :

- les images Docker sont construites et stockées dans Azure Container Registry ;
- AKS tire les images depuis ACR ;
- le frontend est exposé avec un LoadBalancer Azure ;
- l'application devient accessible via une IP publique.

## 5. Architecture cloud

```text
Utilisateur Internet
  -> IP publique Azure LoadBalancer
  -> Service frontend
  -> Pods frontend
  -> Service backend-api
  -> Pods backend-api
  -> Service postgres
  -> Pod PostgreSQL
```

## 6. Scripts préparés

Les scripts Azure sont placés dans :

```text
infra/azure/
```

| Script | Rôle |
| --- | --- |
| `01-provision-aks.ps1` | Créer Resource Group, ACR, images Docker et cluster AKS |
| `02-deploy-app.ps1` | Déployer l'application dans AKS |
| `03-check-app.ps1` | Vérifier les Pods, Services et l'URL publique |
| `04-cleanup-azure.ps1` | Supprimer le Resource Group pour arrêter les coûts |

## 7. Manifests Azure

Les manifests cloud sont séparés dans :

```text
k8s/azure/
```

Cela évite de modifier la version locale. Les principales différences sont :

- images Docker basées sur Azure Container Registry ;
- frontend exposé avec `type: LoadBalancer` ;
- backend et PostgreSQL restent internes avec `ClusterIP`.

## 8. Commandes prévues

Depuis la racine du projet :

```powershell
.\infra\azure\01-provision-aks.ps1
.\infra\azure\02-deploy-app.ps1
.\infra\azure\03-check-app.ps1
```

Le premier script peut prendre plusieurs minutes, car il crée ACR, construit les images et crée le cluster AKS.

## 9. Captures à prendre

Captures terminal :

- `az account show -o table` ;
- création du Resource Group ;
- création ACR ;
- build des images dans ACR ;
- création AKS ;
- `kubectl get nodes -o wide` ;
- `kubectl get pods -n wendev -o wide` ;
- `kubectl get svc -n wendev` ;
- test `curl http://<EXTERNAL-IP>/api/health`.

Captures navigateur :

- application accessible via l'IP publique ;
- création d'un ticket dans la version cloud.

## 10. Coût et nettoyage

La version Azure consomme des crédits Azure for Students tant que les ressources existent.

Pour supprimer les ressources :

```powershell
.\infra\azure\04-cleanup-azure.ps1
```

Ce script supprime le Resource Group `rg-wendev-k8s`, donc AKS, ACR, disques et LoadBalancer associés.

## 11. Limite assumée

Comme dans la version locale, PostgreSQL reste en une seule instance pour la démonstration. La version de production recommandée serait :

```text
Azure Database for PostgreSQL
```

Cela permettrait d'améliorer la disponibilité, la sauvegarde et la maintenance de la base de données.

## 12. Conclusion attendue

Cette phase permettra de montrer que la solution Kubernetes fonctionne non seulement en local, mais aussi dans un cloud public avec :

- un cluster AKS managé ;
- des images stockées dans ACR ;
- une application exposée publiquement ;
- des replicas backend/frontend ;
- un LoadBalancer Azure ;
- les mêmes tests de disponibilité que la version locale.

