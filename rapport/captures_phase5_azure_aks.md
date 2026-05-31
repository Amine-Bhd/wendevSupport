# Captures et sorties - Phase 5 Azure AKS

Ce document regroupe les sorties terminal utiles pour justifier le déploiement cloud de l'application Wendev Tickets sur Azure Kubernetes Service.

## 1. Compte Azure utilisé

Commande :

```powershell
az account show --query "{name:name,id:id,state:state,tenantDisplayName:tenantDisplayName,user:user.name}" -o table
```

Résultat :

```text
Name                State    TenantDisplayName    User
------------------  -------  -------------------  --------------------
Azure for Students  Enabled  Default Directory    aminelous1@gmail.com
```

## 2. Registre Azure Container Registry

Commande :

```powershell
az acr repository list --name acrwendevsupportamine -o table
```

Résultat :

```text
Result
-----------------------
wendev-tickets-backend
wendev-tickets-frontend
```

Ce résultat confirme que les deux images Docker de l'application sont stockées dans Azure Container Registry.

## 3. Cluster AKS

Commande :

```powershell
az aks show --resource-group rg-wendev-k8s --name aks-wendev-support --query "{name:name,location:location,kubernetesVersion:kubernetesVersion,powerState:powerState.code,provisioningState:provisioningState,nodeResourceGroup:nodeResourceGroup,sku:sku.tier}" -o table
```

Résultat :

```text
Name                Location      KubernetesVersion    PowerState    ProvisioningState    NodeResourceGroup                                 Sku
------------------  ------------  -------------------  ------------  -------------------  ------------------------------------------------  -----
aks-wendev-support  spaincentral  1.34                 Running       Succeeded            MC_rg-wendev-k8s_aks-wendev-support_spaincentral  Free
```

## 4. Noeuds AKS

Commande :

```powershell
kubectl get nodes -o wide
```

Résultat :

```text
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-40638013-vmss000000   Ready    <none>   16m   v1.34.7   10.224.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1111-azure   containerd://1.7.31-1
aks-nodepool1-40638013-vmss000001   Ready    <none>   16m   v1.34.7   10.224.0.5    <none>        Ubuntu 22.04.5 LTS   5.15.0-1111-azure   containerd://1.7.31-1
```

Ce résultat confirme que le cluster AKS contient deux worker nodes disponibles.

## 5. Déploiements applicatifs

Commande :

```powershell
kubectl get deploy -n wendev -o wide
```

Résultat :

```text
NAME          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS    IMAGES                                                        SELECTOR
backend-api   3/3     3            3           14m   backend-api   acrwendevsupportamine.azurecr.io/wendev-tickets-backend:v1    app.kubernetes.io/name=backend-api
frontend      2/2     2            2           14m   frontend      acrwendevsupportamine.azurecr.io/wendev-tickets-frontend:v1   app.kubernetes.io/name=frontend
```

Ce résultat montre la redondance applicative :

- trois replicas pour le backend ;
- deux replicas pour le frontend.

## 6. Pods et répartition sur les noeuds

Commande :

```powershell
kubectl get pods -n wendev -o wide
```

Résultat :

```text
NAME                         READY   STATUS    RESTARTS      AGE   IP             NODE                                NOMINATED NODE   READINESS GATES
backend-api-656c5d7b-4g9m7   1/1     Running   0             14m   10.244.0.112   aks-nodepool1-40638013-vmss000000   <none>           <none>
backend-api-656c5d7b-99r7f   1/1     Running   0             14m   10.244.0.254   aks-nodepool1-40638013-vmss000000   <none>           <none>
backend-api-656c5d7b-9px46   1/1     Running   1 (13m ago)   14m   10.244.1.225   aks-nodepool1-40638013-vmss000001   <none>           <none>
frontend-55f84d6db8-52knt    1/1     Running   0             14m   10.244.0.111   aks-nodepool1-40638013-vmss000000   <none>           <none>
frontend-55f84d6db8-mpdz8    1/1     Running   0             14m   10.244.1.24    aks-nodepool1-40638013-vmss000001   <none>           <none>
postgres-0                   1/1     Running   0             14m   10.244.0.115   aks-nodepool1-40638013-vmss000000   <none>           <none>
```

Les Pods frontend et backend sont répartis sur les deux noeuds AKS, ce qui permet de démontrer la haute disponibilité au niveau applicatif.

## 7. Services Kubernetes

Commande :

```powershell
kubectl get svc -n wendev
```

Résultat :

```text
NAME          TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
backend-api   ClusterIP      10.0.50.222    <none>         3000/TCP       14m
frontend      LoadBalancer   10.0.232.138   158.158.64.6   80:30870/TCP   14m
postgres      ClusterIP      10.0.180.64    <none>         5432/TCP       14m
```

Le Service `frontend` est de type `LoadBalancer`. Azure lui attribue l'adresse publique :

```text
http://158.158.64.6
```

## 8. Tests HTTP publics

Test du frontend :

```powershell
Invoke-RestMethod -Uri 'http://158.158.64.6/health' -Method Get
```

Résultat :

```text
ok
```

Test du backend via le frontend :

```powershell
Invoke-RestMethod -Uri 'http://158.158.64.6/api/health' -Method Get
```

Résultat :

```json
{
  "status": "ok",
  "service": "backend-api",
  "hostname": "backend-api-656c5d7b-9px46",
  "database": "connected",
  "timestamp": "2026-05-31T12:42:29.617Z"
}
```

Ce test confirme que le chemin complet fonctionne :

```text
Internet -> Azure LoadBalancer -> frontend -> backend-api -> PostgreSQL
```

## 9. Création d'un ticket sur la version cloud

Commande :

```powershell
$body = @{
  title = 'Test Azure AKS'
  description = 'Ticket cree sur la version cloud pour valider LoadBalancer, frontend, backend et PostgreSQL.'
  priority = 'haute'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://158.158.64.6/api/tickets' -Method Post -ContentType 'application/json' -Body $body
```

Résultat :

```json
{
  "id": 3,
  "title": "Test Azure AKS",
  "description": "Ticket cree sur la version cloud pour valider LoadBalancer, frontend, backend et PostgreSQL.",
  "priority": "haute",
  "status": "ouvert",
  "createdAt": "2026-05-31T12:40:54.709Z",
  "updatedAt": "2026-05-31T12:40:54.709Z"
}
```

La création du ticket valide le fonctionnement de l'application cloud de bout en bout.

Capture navigateur réalisée :

```text
screenshots/wendev-tickets-azure.png
```

## 10. Difficultés rencontrées et corrections

| Problème rencontré | Cause | Correction appliquée |
| --- | --- | --- |
| Région `westeurope` refusée | Policy Azure for Students limitant les régions autorisées | Utilisation de `spaincentral` |
| `Standard_B2s` refusée | Taille indisponible ou non autorisée dans la région/subscription | Utilisation de `Standard_B2s_v2` |
| `az acr build` refusé | ACR Tasks non autorisées dans la subscription | Build Docker local puis `docker push` vers ACR |
| Coût potentiel sur 1 mois | Deux VMs AKS consomment du compute en continu | Ajout des scripts `05-stop-aks.ps1` et `06-start-aks.ps1` |

## 11. Estimation budgétaire

Le cluster utilise deux noeuds `Standard_B2s_v2`. D'après l'API officielle Azure Retail Prices consultée le 31/05/2026, le prix observé pour `Standard_B2s_v2` en `spaincentral` est :

```text
0.0912 USD / heure / noeud
```

Estimation compute :

```text
2 noeuds x 0.0912 USD x 24 h = 4.3776 USD / jour
4.3776 USD x 30 jours = 131.328 USD / mois
```

Avec un crédit restant d'environ `68.47 USD`, il n'est pas recommandé de laisser le cluster tourner en continu pendant un mois. La stratégie retenue est donc :

- démarrer AKS uniquement pour les tests, captures et répétitions ;
- arrêter AKS après usage avec `infra/azure/05-stop-aks.ps1` ;
- redémarrer AKS avant la démonstration avec `infra/azure/06-start-aks.ps1` ;
- supprimer toutes les ressources après la soutenance avec `infra/azure/04-cleanup-azure.ps1`.

## 12. État après validation

Après les tests et les captures, le cluster AKS a été arrêté afin de réduire la consommation des crédits Azure.

Commande :

```powershell
az aks show --resource-group rg-wendev-k8s --name aks-wendev-support --query "{name:name,powerState:powerState.code,provisioningState:provisioningState,location:location,sku:sku.tier}" -o table
```

Résultat :

```text
Name                PowerState    ProvisioningState    Location      Sku
------------------  ------------  -------------------  ------------  -----
aks-wendev-support  Stopped       Succeeded            spaincentral  Free
```

L'application publique n'est donc pas accessible tant que le cluster est arrêté. Avant une démonstration, il suffit d'exécuter :

```powershell
.\infra\azure\06-start-aks.ps1
```
