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
| Région | `spaincentral` |
| Resource Group | `rg-wendev-k8s` |
| Cluster AKS | `aks-wendev-support` |
| Azure Container Registry | `acrwendevsupportamine` |
| Nombre de nœuds | `2` |
| Taille des nœuds | `Standard_B2s_v2` |
| Base de données | PostgreSQL dans le cluster |
| Exposition | Service Kubernetes de type `LoadBalancer` |

La région `spaincentral` est retenue, car la subscription Azure for Students utilisée applique une policy de régions autorisées. Les régions autorisées observées sont `spaincentral`, `germanywestcentral`, `switzerlandnorth`, `norwayeast` et `polandcentral`. La taille `Standard_B2s_v2` est utilisée car `Standard_B2s` n'est pas autorisée dans cette région pour cette subscription.

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
| `05-stop-aks.ps1` | Arrêter AKS pour réduire les coûts compute |
| `06-start-aks.ps1` | Redémarrer AKS avant une démonstration |

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

Le premier script peut prendre plusieurs minutes, car il crée ACR, construit les images localement avec Docker, pousse les images vers ACR et crée le cluster AKS.

Remarque : dans cette subscription Azure for Students, les ACR Tasks ont été refusées avec l'erreur `TasksOperationsNotAllowed`. Le projet utilise donc la méthode classique :

```text
docker build -> docker push -> Azure Container Registry
```

## 9. Résultats obtenus

Le déploiement Azure AKS a été validé avec succès.

Résultat principal :

```text
URL publique Azure LoadBalancer : http://158.158.64.6
Frontend : ok
Backend API : ok
Base PostgreSQL : connected
```

Les sorties détaillées sont regroupées dans :

```text
rapport/captures_phase5_azure_aks.md
```

Les validations réalisées sont :

- cluster AKS créé dans `spaincentral` ;
- deux worker nodes AKS en état `Ready` ;
- images backend et frontend stockées dans Azure Container Registry ;
- backend déployé avec trois replicas ;
- frontend déployé avec deux replicas ;
- Service frontend exposé avec un LoadBalancer Azure ;
- création d'un ticket via l'API publique ;
- persistance confirmée dans PostgreSQL.

## 10. Captures réalisées et à conserver

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

Capture sauvegardée :

```text
screenshots/wendev-tickets-azure.png
```

## 11. Coût et nettoyage

La version Azure consomme des crédits Azure for Students tant que les ressources existent.

Le cluster créé utilise :

```text
2 noeuds Standard_B2s_v2
AKS Base / Free tier
ACR Basic
1 Service LoadBalancer
1 volume persistant PostgreSQL
```

Le 31/05/2026, l'API officielle Azure Retail Prices indique pour `Standard_B2s_v2` dans `spaincentral` :

```text
0.0912 USD / heure / noeud
```

Estimation du coût compute si le cluster reste allumé en continu :

```text
2 x 0.0912 x 24 = 4.3776 USD / jour
4.3776 x 30 = 131.328 USD / mois
```

Avec un crédit restant d'environ `68.47 USD`, ce budget est suffisant pour faire les tests, prendre les captures et répéter la démonstration si le cluster est arrêté après usage. Il n'est pas suffisant pour laisser deux noeuds AKS tourner en continu pendant un mois ou plus.

Pour supprimer les ressources :

```powershell
.\infra\azure\04-cleanup-azure.ps1
```

Ce script supprime le Resource Group `rg-wendev-k8s`, donc AKS, ACR, disques et LoadBalancer associés.

Pour conserver l'environnement tout en réduisant fortement les coûts compute, on peut arrêter AKS :

```powershell
.\infra\azure\05-stop-aks.ps1
```

Puis le redémarrer avant une démonstration :

```powershell
.\infra\azure\06-start-aks.ps1
```

Selon la documentation Microsoft, l'arrêt d'un cluster AKS stoppe le Control Plane et les nœuds agents, ce qui permet d'économiser les coûts de calcul tout en conservant l'état du cluster. Il peut toutefois rester de petits coûts liés au stockage, au registre d'images et aux ressources associées.

## 12. Difficultés rencontrées

Pendant la mise en oeuvre Azure, plusieurs contraintes réelles ont été rencontrées :

| Contrainte | Impact | Solution |
| --- | --- | --- |
| `westeurope` refusée par la policy Azure for Students | Création impossible dans la région prévue initialement | Passage à `spaincentral` |
| `Standard_B2s` indisponible ou non autorisée | Création AKS impossible avec cette taille | Passage à `Standard_B2s_v2` |
| ACR Tasks refusées avec `TasksOperationsNotAllowed` | `az acr build` impossible | Build Docker local puis `docker push` vers ACR |
| Crédit Azure limité | Risque de consommation excessive | Scripts stop/start/cleanup ajoutés |

Ces difficultés sont intéressantes pour le rapport, car elles montrent une vraie démarche de troubleshooting cloud.

## 13. Limite assumée

Comme dans la version locale, PostgreSQL reste en une seule instance pour la démonstration. La version de production recommandée serait :

```text
Azure Database for PostgreSQL
```

Cela permettrait d'améliorer la disponibilité, la sauvegarde et la maintenance de la base de données.

## 14. Sources officielles

- Microsoft Learn - AKS pricing tiers : https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers
- Microsoft Learn - Stop and start AKS cluster : https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster
- Microsoft Learn - Azure Container Registry tiers : https://learn.microsoft.com/en-us/azure/container-registry/container-registry-skus
- Microsoft Learn - AKS Standard Load Balancer : https://learn.microsoft.com/en-us/azure/aks/configure-load-balancer-standard
- Azure Retail Prices API : https://prices.azure.com/api/retail/prices

## 15. Conclusion

Cette phase montre que la solution Kubernetes fonctionne non seulement en local, mais aussi dans un cloud public avec :

- un cluster AKS managé ;
- des images stockées dans ACR ;
- une application exposée publiquement ;
- des replicas backend/frontend ;
- un LoadBalancer Azure ;
- les mêmes tests de disponibilité que la version locale.
