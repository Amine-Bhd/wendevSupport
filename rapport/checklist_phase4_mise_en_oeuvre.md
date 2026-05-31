# Checklist phase 4 - Mise en œuvre

## 1. Objectif

La phase 4 consiste à réaliser la partie pratique du projet :

- préparer l'environnement technique ;
- créer l'application de démonstration ;
- construire les images Docker ;
- créer le cluster Kubernetes local ;
- déployer les composants ;
- exposer l'application ;
- tester la haute disponibilité ;
- capturer les résultats pour le rapport et la soutenance.

## État actuel

Statut au 31 mai 2026 :

- environnement Docker Desktop / WSL 2 disponible ;
- `kind` installé et fonctionnel ;
- cluster local `wendev-local` créé avec 1 Control Plane et 2 worker nodes ;
- images Docker frontend et backend construites ;
- images chargées dans le cluster kind ;
- manifests Kubernetes appliqués dans le Namespace `wendev` ;
- frontend, backend et PostgreSQL en état `Running` ;
- application accessible localement via Ingress sur `http://127.0.0.1:8080` ;
- contrôleur NGINX Ingress installé via le miroir jsDelivr à cause d'un problème DNS vers `raw.githubusercontent.com` ;
- test de création d'un ticket réalisé depuis le navigateur ;
- test d'auto-réparation réalisé par suppression d'un Pod backend ;
- test de scaling réalisé avec passage du backend à 3 replicas ;
- captures d'écran applicatives disponibles dans `screenshots/` ;
- sorties terminal Kubernetes, Ingress, auto-réparation et scaling sauvegardées dans `rapport/captures_phase4_kubectl.md`.

## 2. Préparation de l'environnement

À vérifier :

- Docker Desktop lancé ;
- Debian WSL 2 disponible ;
- intégration Docker Desktop avec Debian WSL 2 activée ;
- `kubectl` fonctionnel ;
- installation de `kind` ;
- création d'un dossier `app/` pour le code ;
- création d'un dossier `infra/kind/` pour le cluster local ;
- création d'un dossier `k8s/` pour les manifests Kubernetes ;
- création d'un dossier `screenshots/` pour les captures.

## 3. Cluster local kind

Cluster visé :

```text
1 control-plane
2 worker nodes
```

Fichier prévu :

```text
infra/kind/kind-cluster.yaml
```

Commandes prévues :

```bash
kind create cluster --config infra/kind/kind-cluster.yaml
kubectl get nodes
kubectl get pods -A
```

Capture à prendre :

- résultat de `kubectl get nodes`.

## 4. Application de démonstration

Application : gestion de tickets/incidents.

Composants :

- frontend web ;
- backend API ;
- PostgreSQL.

Fonctionnalités minimales :

- lister les tickets ;
- créer un ticket ;
- modifier le statut d'un ticket ;
- endpoint `/health` côté backend.

## 5. Images Docker

Images prévues :

- `wendev-tickets-frontend`;
- `wendev-tickets-backend`.

Actions :

- créer un Dockerfile frontend ;
- créer un Dockerfile backend ;
- construire les images ;
- tester les conteneurs localement ;
- charger les images dans le cluster kind.

Commandes prévues :

```bash
docker build -t wendev-tickets-frontend:local ./app/frontend
docker build -t wendev-tickets-backend:local ./app/backend
kind load docker-image wendev-tickets-frontend:local
kind load docker-image wendev-tickets-backend:local
```

Captures à prendre :

- résultat de `docker images`;
- application testée localement si nécessaire.

## 6. Manifests Kubernetes

Objets prévus :

- Namespace ;
- ConfigMap ;
- Secret ;
- PostgreSQL Deployment ou StatefulSet ;
- PostgreSQL Service ;
- Backend Deployment ;
- Backend Service ;
- Frontend Deployment ;
- Frontend Service ;
- Ingress ;
- éventuellement PersistentVolumeClaim ;
- éventuellement HPA.

Fichiers possibles :

```text
k8s/00-namespace.yaml
k8s/01-configmap.yaml
k8s/02-secret.yaml
k8s/03-postgres.yaml
k8s/04-backend.yaml
k8s/05-frontend.yaml
k8s/06-ingress.yaml
```

Commandes prévues :

```bash
kubectl apply -f k8s/
kubectl get all -n wendev
kubectl get pods -n wendev -o wide
kubectl get svc -n wendev
kubectl get ingress -n wendev
```

Captures à prendre :

- Pods en cours d'exécution ;
- Services ;
- Ingress ;
- Pods répartis sur plusieurs worker nodes.

## 7. Tests de disponibilité

Tests prévus :

### 7.1 Test d'accès

Objectif : vérifier que l'application est accessible depuis le navigateur.

Capture :

- page frontend affichée.

### 7.2 Test de santé backend

Objectif : vérifier l'endpoint `/health`.

Commande possible :

```bash
curl http://localhost/api/health
```

Capture :

- réponse de santé de l'API.

### 7.3 Test d'auto-réparation

Objectif : supprimer un Pod et vérifier que Kubernetes le recrée.

Commandes prévues :

```bash
kubectl get pods -n wendev
kubectl delete pod <nom-du-pod> -n wendev
kubectl get pods -n wendev -w
```

Capture :

- Pod supprimé ;
- nouveau Pod créé automatiquement.

### 7.4 Test de scaling

Objectif : augmenter ou réduire le nombre de replicas.

Commande prévue :

```bash
kubectl scale deployment backend-api -n wendev --replicas=3
kubectl get pods -n wendev -o wide
```

Capture :

- augmentation du nombre de Pods.

### 7.5 Test de rolling update

Objectif : montrer la mise à jour progressive d'une application.

Commandes possibles :

```bash
kubectl rollout status deployment/backend-api -n wendev
kubectl rollout history deployment/backend-api -n wendev
```

Capture :

- statut du rollout.

## 8. Démonstration soutenance

Déroulé recommandé :

1. Afficher le cluster avec `kubectl get nodes`.
2. Afficher les Pods avec `kubectl get pods -n wendev -o wide`.
3. Ouvrir l'application dans le navigateur.
4. Créer un ticket.
5. Supprimer un Pod backend.
6. Montrer que Kubernetes recrée le Pod.
7. Montrer que l'application reste accessible.
8. Expliquer le rôle du Service et de l'Ingress.

## 9. Captures finales à intégrer au rapport

- Docker Desktop / environnement local ;
- version `kubectl` ;
- cluster kind avec 3 nœuds ;
- images Docker créées ;
- manifests appliqués ;
- Pods frontend/backend/PostgreSQL ;
- Services ;
- Ingress ;
- application web ;
- test de suppression d'un Pod ;
- test de scaling ;
- diagramme final d'architecture.

## 10. Conclusion attendue

La phase 4 devra prouver que la solution Kubernetes fonctionne et répond à la problématique :

- l'application est conteneurisée ;
- elle est déployée sur Kubernetes ;
- elle est exposée aux utilisateurs ;
- elle possède plusieurs replicas ;
- Kubernetes recrée les Pods en cas de panne ;
- l'architecture est documentée par des captures et diagrammes.
