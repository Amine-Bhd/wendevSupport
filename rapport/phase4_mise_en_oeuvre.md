# Phase 4 - Mise en œuvre de la solution Kubernetes

## 1. Objectif de la phase

Cette phase consiste à passer de la conception à la réalisation pratique. L'objectif est de déployer une application simple de gestion de tickets dans un cluster Kubernetes local afin de démontrer :

- la conteneurisation avec Docker ;
- l'orchestration avec Kubernetes ;
- la répartition des Pods sur plusieurs worker nodes ;
- l'exposition de l'application ;
- l'auto-réparation ;
- le scaling manuel ;
- la préparation d'une future migration vers Azure Kubernetes Service.

L'application utilisée est volontairement simple afin de garder le projet centré sur Kubernetes.

## 2. Environnement technique

L'environnement utilisé pour la mise en œuvre est le suivant :

| Élément | Choix retenu |
| --- | --- |
| Système | Windows 10 |
| Virtualisation Linux | WSL 2 avec Debian |
| Conteneurisation | Docker Desktop |
| Outil Kubernetes | kubectl |
| Cluster local | kind |
| Application | Wendev Tickets |
| Base de données | PostgreSQL |

Le cluster local a été créé avec `kind`, car il permet de simuler un vrai cluster Kubernetes multi-nœuds sur une machine locale. Cette solution est adaptée pour apprendre, tester et préparer la démonstration avant un éventuel passage vers AKS.

## 3. Architecture réalisée

Le cluster local s'appelle `wendev-local`. Il contient :

- un nœud Control Plane ;
- deux worker nodes.

Fichier de configuration :

```text
infra/kind/kind-cluster.yaml
```

Contenu logique :

```text
wendev-local
├── control-plane
├── worker
└── worker2
```

L'application est composée de trois parties :

- un frontend web statique servi par NGINX ;
- une API backend Node.js / Express ;
- une base de données PostgreSQL.

Dans cette démonstration, la haute disponibilité est prouvée au niveau applicatif avec plusieurs replicas frontend et backend. PostgreSQL est déployé en une seule instance pour garder le projet simple et démontrable. Dans une architecture de production, la base de données devrait être remplacée par un service managé comme Azure Database for PostgreSQL ou par une architecture PostgreSQL hautement disponible.

Flux applicatif :

```text
Utilisateur
  -> Frontend
  -> Backend API
  -> PostgreSQL
```

Dans Kubernetes, ces composants sont déployés dans le Namespace `wendev`.

## 4. Création des images Docker

Deux images Docker ont été construites :

```bash
docker build -t wendev-tickets-backend:local app/backend
docker build -t wendev-tickets-frontend:local app/frontend
```

Ensuite, les images ont été chargées dans le cluster kind :

```bash
kind load docker-image wendev-tickets-backend:local --name wendev-local
kind load docker-image wendev-tickets-frontend:local --name wendev-local
```

Cette étape est nécessaire avec kind, car le cluster local doit pouvoir accéder aux images construites sur la machine.

## 5. Création du cluster Kubernetes

Le cluster a été créé avec :

```bash
kind create cluster --config infra/kind/kind-cluster.yaml
```

Vérification :

```bash
kubectl get nodes -o wide
```

Résultat observé :

```text
wendev-local-control-plane   Ready
wendev-local-worker          Ready
wendev-local-worker2         Ready
```

Ce résultat confirme que le cluster est opérationnel et qu'il contient deux worker nodes pour exécuter les Pods applicatifs.

## 6. Déploiement Kubernetes

Les manifests sont placés dans le dossier :

```text
k8s/
```

Les objets déployés sont :

| Fichier | Rôle |
| --- | --- |
| `00-namespace.yaml` | Création du Namespace `wendev` |
| `01-configmap.yaml` | Configuration non sensible |
| `02-secret.yaml` | Identifiants PostgreSQL |
| `03-postgres.yaml` | StatefulSet et Service PostgreSQL |
| `04-backend.yaml` | Deployment et Service backend |
| `05-frontend.yaml` | Deployment et Service frontend |
| `06-ingress.yaml` | Règle d'exposition HTTP |
| `optional/07-hpa.yaml` | Autoscaling optionnel |

Déploiement :

```bash
kubectl apply -f k8s
```

Vérification des Deployments :

```bash
kubectl get deploy -n wendev -o wide
```

Résultat observé après le test de scaling :

```text
backend-api   3/3   3 disponibles   wendev-tickets-backend:local
frontend      2/2   2 disponibles   wendev-tickets-frontend:local
```

Le backend possède trois replicas dans l'état actuel du cluster, car un test de scaling manuel a été effectué. Le manifest de base définit deux replicas, ce qui est déjà suffisant pour démontrer la haute disponibilité.

## 7. Répartition des Pods

Commande :

```bash
kubectl get pods -n wendev -o wide
```

Résultat observé :

```text
backend-api   Running   wendev-local-worker
backend-api   Running   wendev-local-worker2
backend-api   Running   wendev-local-worker2
frontend      Running   wendev-local-worker
frontend      Running   wendev-local-worker2
postgres-0    Running   wendev-local-worker
```

Ce résultat montre que les Pods frontend et backend sont distribués sur les deux worker nodes. Cette distribution permet à l'application de continuer à fonctionner si un Pod applicatif est supprimé.

## 8. Services Kubernetes

Commande :

```bash
kubectl get svc -n wendev
```

Résultat observé :

```text
backend-api   ClusterIP   3000/TCP
frontend      ClusterIP   80/TCP
postgres      ClusterIP   5432/TCP
```

Les Services jouent un rôle essentiel. Ils fournissent une adresse stable pour accéder aux Pods, même si ces Pods sont recréés avec de nouvelles adresses IP.

## 9. Exposition de l'application

Un Ingress a été préparé dans :

```text
k8s/06-ingress.yaml
```

Dans l'environnement local, l'installation directe du NGINX Ingress Controller depuis `raw.githubusercontent.com` a été bloquée par un problème DNS local. Le même manifest a donc été appliqué depuis le miroir jsDelivr :

```bash
kubectl apply -f https://cdn.jsdelivr.net/gh/kubernetes/ingress-nginx@controller-v1.15.1/deploy/static/provider/kind/deploy.yaml
```

Le contrôleur Ingress a ensuite été placé sur le nœud Control Plane, car le fichier kind expose le port 80 de ce nœud sur le port 8080 de la machine locale.

Commandes utilisées :

```bash
kubectl label node wendev-local-control-plane ingress-ready=true --overwrite
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type merge --patch-file infra/kind/ingress-nginx-node-selector-patch.yaml
```

URL locale de test via Ingress :

```text
http://127.0.0.1:8080
```

L'Ingress route les requêtes HTTP vers les Services Kubernetes :

```text
/      -> Service frontend
/api   -> Service backend-api
```

Le port-forward reste une solution de secours possible :

```bash
kubectl port-forward -n wendev svc/frontend 8081:80
```

Dans Azure AKS, l'exposition finale pourra être remplacée par un LoadBalancer Azure ou par un Ingress Controller installé dans le cluster.

## 10. Test applicatif

Test du frontend :

```bash
curl http://127.0.0.1:8080/health
```

Résultat :

```text
ok
```

Test de l'API backend :

```bash
curl http://127.0.0.1:8080/api/health
```

Résultat observé :

```json
{
  "status": "ok",
  "service": "backend-api",
  "database": "connected"
}
```

Ce test valide que :

- le frontend est accessible ;
- le routage vers l'API fonctionne ;
- le backend est disponible ;
- la connexion à PostgreSQL fonctionne.

Un ticket de démonstration a été créé depuis l'interface web :

```text
Test haute disponibilite Kubernetes
```

Ce ticket confirme le passage complet par le frontend, le backend et la base de données.

## 11. Test d'auto-réparation

Pour tester l'auto-réparation, un Pod backend a été supprimé volontairement :

```bash
kubectl delete pod <nom-du-pod> -n wendev
```

Après suppression, Kubernetes a créé automatiquement un nouveau Pod backend. L'API a continué à répondre :

```bash
curl http://127.0.0.1:8080/api/health
```

Le hostname retourné par l'API a changé, ce qui montre que la requête a été servie par un autre Pod backend.

Ce test démontre le rôle du Deployment et du ReplicaSet : maintenir le nombre de replicas demandé et recréer les Pods en cas d'incident.

## 12. Test de scaling manuel

Le nombre de replicas backend a été augmenté à trois :

```bash
kubectl scale deployment backend-api -n wendev --replicas=3
```

Vérification :

```bash
kubectl get deploy -n wendev -o wide
```

Résultat :

```text
backend-api   3/3   3 disponibles
```

Ce test montre que Kubernetes peut augmenter le nombre d'instances applicatives sans reconstruire l'application.

## 13. Test de rollout

Le statut des rollouts a été vérifié avec :

```bash
kubectl rollout status deployment/backend-api -n wendev
kubectl rollout status deployment/frontend -n wendev
```

Résultat :

```text
deployment "backend-api" successfully rolled out
deployment "frontend" successfully rolled out
```

Cela confirme que les Deployments sont stables.

## 14. Captures disponibles

Deux captures ont été générées :

| Capture | Description |
| --- | --- |
| `screenshots/wendev-tickets-home.png` | Page principale de l'application |
| `screenshots/wendev-tickets-after-create.png` | Application après création d'un ticket |
| `rapport/captures_phase4_kubectl.md` | Sorties terminal Kubernetes et tests Ingress |

Les sorties terminal suivantes sont sauvegardées dans `rapport/captures_phase4_kubectl.md` :

- résultat de `kubectl get nodes -o wide` ;
- résultat de `kubectl get pods -n wendev -o wide` ;
- résultat de `kubectl get svc -n wendev` ;
- résultat de `kubectl get ingress -n wendev` ;
- résultat de `kubectl get pods -n ingress-nginx -o wide` ;
- résultat du test d'accès via Ingress ;
- résultat du test d'auto-réparation ;
- résultat du test de scaling manuel.

## 15. Bilan de la phase

La phase 4 valide que la solution fonctionne en local :

- les images Docker sont construites ;
- le cluster Kubernetes local est opérationnel ;
- l'application est déployée dans un Namespace dédié ;
- le frontend, le backend et PostgreSQL fonctionnent ensemble ;
- les Services fournissent des points d'accès stables ;
- les replicas backend et frontend permettent la redondance applicative ;
- Kubernetes recrée automatiquement un Pod supprimé ;
- le scaling manuel fonctionne ;
- l'exposition locale est validée avec Ingress NGINX sur `http://127.0.0.1:8080`.

La limite principale de cette version locale est que la base de données PostgreSQL n'est pas encore redondée. Cette limite est acceptable pour une démonstration pédagogique centrée sur Kubernetes, mais elle doit être mentionnée dans le rapport comme perspective d'amélioration.

La prochaine amélioration consiste à préparer une version cloud sur Azure AKS si le temps du projet le permet.
