# Mise en place d'une solution de conteneurisation avec Kubernetes

## Page de garde

- Filière : 4ème année - Ingénierie des Systèmes d'Information
- Sujet : Mise en place d'une solution de conteneurisation avec Kubernetes
- Entreprise fictive : Wendev
- Encadrant : M. Mohamed Amine ESSFALI
- Année universitaire : 2025-2026

## Résumé

Ce projet vise à concevoir et mettre en place une solution de conteneurisation basée sur Kubernetes. À travers le cas d'une entreprise fictive, Wendev, le projet étudie les limites d'une architecture monolithique classique et propose une migration vers une architecture conteneurisée, orchestrée et hautement disponible. Une application simple de gestion de tickets/incidents sera utilisée comme support de démonstration afin de valider le déploiement, la redondance, l'exposition via LoadBalancer ou Ingress et la capacité de Kubernetes à maintenir les services disponibles.

## Introduction générale

Les applications modernes doivent répondre à des exigences croissantes en matière de disponibilité, de scalabilité, de rapidité de déploiement et de maintenance. Les architectures traditionnelles basées sur des applications monolithiques installées directement sur des serveurs présentent des limites importantes lorsque le volume d'utilisateurs, le nombre de services ou la fréquence des déploiements augmente.

La conteneurisation apporte une première réponse à ces problèmes en isolant les applications et leurs dépendances dans des conteneurs portables. Cependant, lorsque le nombre de conteneurs devient important, leur gestion manuelle devient complexe. Kubernetes intervient alors comme une plateforme d'orchestration permettant d'automatiser le déploiement, la supervision, la mise à l'échelle et l'exposition des applications conteneurisées.

## 1. Présentation de l'entreprise et de l'existant

Cette première partie est détaillée dans le document de travail `rapport/phase1_etude_existant.md`.

### 1.1 Présentation de Wendev

Wendev est une entreprise fictive spécialisée dans le développement logiciel, la formation, la vente de matériels informatiques et le support technique. Son système d'information repose sur plusieurs applications internes et externes utilisées par les équipes métiers, les clients et les administrateurs.

### 1.2 Existant matériel

Dans l'architecture initiale, chaque application est installée sur un serveur ou une machine virtuelle dédiée. Les serveurs sont reliés au réseau local de l'entreprise à travers un switch et un routeur permettant l'accès interne ou externe selon le besoin.

| Élément | Description |
| --- | --- |
| Serveur applicatif 1 | Héberge une application monolithique |
| Serveur applicatif 2 | Héberge une autre application métier |
| Serveur applicatif 3 | Héberge une application support ou tickets |
| Serveur base de données | Héberge les données applicatives |
| Switch / routeur | Assure la connectivité réseau |
| Poste administrateur | Utilisé pour les opérations de maintenance |

### 1.3 Existant logiciel

Les applications existantes sont principalement monolithiques. Une application monolithique regroupe dans un seul bloc les interfaces, la logique métier et parfois une forte dépendance à la base de données ou au serveur d'exécution.

### 1.4 Schéma du réseau existant

Le schéma de l'existant est préparé dans `diagrams/existant_monolithique.mmd`. Il représente plusieurs applications monolithiques installées sur des serveurs séparés, reliés au réseau local de l'entreprise.

### 1.5 Critique de l'existant

L'architecture existante présente plusieurs limites :

- faible disponibilité en cas de panne d'un serveur ;
- scalabilité difficile, car il faut redimensionner ou dupliquer manuellement les serveurs ;
- déploiements manuels et peu automatisés ;
- dépendances fortes entre l'application et son environnement ;
- difficulté à isoler les incidents ;
- maintenance complexe lorsque plusieurs applications évoluent en parallèle ;
- absence d'orchestration centralisée.

## 2. Problématique et solution envisagée

### 2.1 Problématique

Comment moderniser l'infrastructure applicative de Wendev afin d'améliorer la disponibilité, la scalabilité, l'automatisation des déploiements et la gestion des applications ?

### 2.2 Solution envisagée

La solution proposée consiste à conteneuriser les applications avec Docker, puis à les déployer sur un cluster Kubernetes. Kubernetes permettra de gérer automatiquement les Pods, les replicas, les Services, l'exposition externe et la reprise après incident.

Dans le cadre de la démonstration, une application simple de gestion de tickets/incidents sera utilisée. Elle sera volontairement limitée fonctionnellement afin de concentrer le projet sur Kubernetes : création des images Docker, déploiement des Pods, exposition via Ingress ou LoadBalancer, haute disponibilité et tests de reprise.

## 3. Étude comparative des solutions

Cette partie est détaillée dans le document de travail `rapport/phase2_conduite_etude_comparative.md`.

Les solutions comparées sont :

- Docker seul ;
- Docker Swarm ;
- Kubernetes ;
- Apache Mesos ;
- OpenShift / Rancher ;
- Kubernetes managé : AKS, EKS, GKE ;
- Kubernetes local : kind, Minikube, Docker Desktop Kubernetes.

Les critères de comparaison sont :

- facilité d'installation ;
- maturité ;
- haute disponibilité ;
- scalabilité ;
- intégration cloud ;
- coût ;
- communauté ;
- complexité d'administration.

Après comparaison, Kubernetes est retenu comme solution principale, car il répond directement au besoin d'orchestration, de haute disponibilité, de scalabilité et d'exposition des applications conteneurisées.

Pour la mise en œuvre locale, l'environnement retenu est :

```text
Docker Desktop + Debian WSL 2 + kubectl + kind
```

Pour une extension cloud, Azure Kubernetes Service est retenu comme option privilégiée, car il s'agit d'un service Kubernetes managé adapté au déploiement d'applications conteneurisées sur Azure.

## 4. Architecture Kubernetes

Cette partie est détaillée dans le document de travail `rapport/phase3_architecture_kubernetes.md`.

### 4.1 Vue générale

Le schéma cible est préparé dans `diagrams/architecture_cible_kubernetes.mmd`. Il présente un cluster Kubernetes composé d'un Control Plane et de plusieurs worker nodes. Les composants applicatifs sont déployés sous forme de Pods répliqués et exposés à travers des Services et un Ingress ou LoadBalancer.

### 4.2 Control Plane

Le Control Plane représente le cerveau du cluster Kubernetes. Il prend les décisions d'orchestration, planifie les Pods, surveille l'état du cluster et expose l'API Kubernetes.

Composants à expliquer :

- kube-apiserver ;
- etcd ;
- kube-scheduler ;
- kube-controller-manager ;
- cloud-controller-manager, si cloud.

Dans l'environnement local, le Control Plane sera créé par kind. Dans l'environnement cloud AKS, le Control Plane sera géré par Azure.

### 4.3 Data Plane / Worker Nodes

Le Data Plane est composé des worker nodes qui exécutent les Pods applicatifs.

Composants à expliquer :

- kubelet ;
- kube-proxy ;
- runtime de conteneurs ;
- Pods ;
- conteneurs.

Dans le projet, les worker nodes exécuteront les Pods du frontend, du backend et de la base de données PostgreSQL. L'objectif est de répartir les replicas applicatifs sur plusieurs nœuds afin de démontrer la haute disponibilité.

### 4.4 Objets Kubernetes utilisés

À détailler :

- Namespace ;
- Deployment ;
- Pod ;
- Service ;
- Ingress ;
- ConfigMap ;
- Secret ;
- PersistentVolume / PersistentVolumeClaim si base de données dans le cluster ;
- HorizontalPodAutoscaler si activé.

Les objets Kubernetes de l'application sont représentés dans `diagrams/objets_kubernetes_application.mmd`.

## 5. Application de démonstration

L'application de démonstration sera une application de gestion de tickets/incidents.

Objectif de l'application :

- fournir un cas simple et compréhensible ;
- permettre la création et la consultation de tickets ;
- disposer d'un frontend, d'une API et d'une base de données ;
- servir de support pour tester les fonctionnalités Kubernetes.

Architecture prévue :

```text
Utilisateur
    |
Ingress / LoadBalancer
    |
Frontend
    |
Backend API
    |
PostgreSQL
```

## 6. Mise en œuvre

Cette partie est détaillée dans le document de travail `rapport/phase4_mise_en_oeuvre.md`.

La mise en œuvre a été réalisée dans un environnement local Windows 10 avec Docker Desktop, WSL 2, `kubectl` et `kind`. Le cluster local s'appelle `wendev-local` et contient trois nœuds :

- un nœud Control Plane ;
- deux worker nodes.

Les images Docker créées pour l'application sont :

- `wendev-tickets-frontend:local` ;
- `wendev-tickets-backend:local`.

Les composants Kubernetes déployés sont :

- un Namespace `wendev` ;
- un ConfigMap pour la configuration applicative ;
- un Secret pour les identifiants PostgreSQL ;
- un StatefulSet PostgreSQL avec stockage persistant ;
- un Deployment backend API ;
- un Deployment frontend ;
- des Services internes de type `ClusterIP` ;
- un Ingress prévu pour l'exposition HTTP via NGINX Ingress Controller.

La redondance est démontrée au niveau frontend et backend grâce aux replicas. PostgreSQL reste volontairement en une seule instance dans cette version locale pour garder la démonstration simple. En production, la base de données devrait être externalisée vers un service managé ou déployée avec une architecture hautement disponible.

Le déploiement a été appliqué avec :

```bash
kubectl apply -f k8s
```

L'accès local de démonstration a été validé via Ingress NGINX. Dans le cluster kind, le port 80 du nœud Control Plane est exposé sur le port 8080 de la machine locale.

L'application est accessible depuis le navigateur à l'adresse :

```text
http://127.0.0.1:8080
```

Remarque : l'installation directe de NGINX Ingress Controller depuis `raw.githubusercontent.com` a été bloquée par un problème DNS local. Le même manifest a été appliqué depuis le miroir jsDelivr, puis le contrôleur a été placé sur le nœud Control Plane pour utiliser le mapping local de kind. Dans un environnement cloud comme Azure AKS, l'exposition finale pourra être faite avec un Service de type `LoadBalancer` ou avec un Ingress Controller installé dans le cluster.

## 7. Tests et validation

Les tests suivants ont été réalisés.

### 7.1 Vérification du cluster

La commande suivante confirme que le cluster local contient un Control Plane et deux worker nodes :

```bash
kubectl get nodes -o wide
```

Résultat observé :

```text
wendev-local-control-plane   Ready
wendev-local-worker          Ready
wendev-local-worker2         Ready
```

### 7.2 Vérification des déploiements

Les Deployments applicatifs sont disponibles :

```bash
kubectl get deploy -n wendev -o wide
```

Résultat observé :

```text
backend-api   3/3   wendev-tickets-backend:local
frontend      2/2   wendev-tickets-frontend:local
```

Le backend avait initialement deux replicas dans le manifest. Il a été augmenté à trois replicas pendant le test de scaling manuel.

### 7.3 Vérification des Pods

La commande suivante permet de vérifier les Pods et leur répartition sur les worker nodes :

```bash
kubectl get pods -n wendev -o wide
```

Résultat observé :

```text
backend-api   Running   worker / worker2
frontend      Running   worker / worker2
postgres-0    Running   worker
```

Les Pods frontend et backend sont répartis sur plusieurs worker nodes grâce aux replicas et aux règles d'anti-affinité préférentielle.

### 7.4 Vérification des Services

Les Services internes sont créés :

```bash
kubectl get svc -n wendev
```

Résultat observé :

```text
backend-api   ClusterIP   3000/TCP
frontend      ClusterIP   80/TCP
postgres      ClusterIP   5432/TCP
```

Ces Services fournissent des points d'accès stables même si les Pods sont supprimés puis recréés avec de nouvelles adresses IP.

### 7.5 Test applicatif

Le frontend répond correctement :

```bash
curl http://127.0.0.1:8080/health
```

Résultat :

```text
ok
```

L'API backend répond également et confirme la connexion à PostgreSQL :

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

Un ticket a été créé depuis l'interface web afin de valider le chemin complet :

```text
Navigateur -> Frontend -> Backend API -> PostgreSQL
```

### 7.6 Test d'auto-réparation

Un Pod backend a été supprimé volontairement avec :

```bash
kubectl delete pod <nom-du-pod> -n wendev
```

Kubernetes a automatiquement recréé un nouveau Pod backend afin de revenir à l'état désiré du Deployment. L'application est restée accessible après la suppression du Pod, ce qui démontre le principe d'auto-réparation.

### 7.7 Test de scaling

Le backend a été augmenté à trois replicas avec :

```bash
kubectl scale deployment backend-api -n wendev --replicas=3
```

Le résultat obtenu confirme que les trois replicas sont disponibles :

```text
backend-api   3/3   3 disponibles
```

Ce test montre la capacité de Kubernetes à adapter le nombre d'instances applicatives selon le besoin.

### 7.8 Test de rollout

Les rollouts du backend et du frontend sont terminés correctement :

```bash
kubectl rollout status deployment/backend-api -n wendev
kubectl rollout status deployment/frontend -n wendev
```

Résultat :

```text
deployment "backend-api" successfully rolled out
deployment "frontend" successfully rolled out
```

## 8. Captures d'écran et diagrammes

Captures disponibles :

- `screenshots/wendev-tickets-home.png` : page principale de l'application ;
- `screenshots/wendev-tickets-after-create.png` : application après création d'un ticket de test.
- `rapport/captures_phase4_kubectl.md` : sorties terminal Kubernetes et tests Ingress.

La phase Azure est préparée dans `rapport/phase5_deploiement_azure_aks.md`. Elle décrit le passage vers Azure Kubernetes Service, l'utilisation d'Azure Container Registry et l'exposition de l'application par un LoadBalancer Azure.

Sorties terminal déjà sauvegardées dans `rapport/captures_phase4_kubectl.md` :

- sortie de `kubectl get nodes -o wide` ;
- sortie de `kubectl get pods -n wendev -o wide` ;
- sortie de `kubectl get svc -n wendev` ;
- sortie de `kubectl get ingress -n wendev` ;
- sortie de `kubectl get pods -n ingress-nginx -o wide` ;
- test d'accès via Ingress ;
- test de suppression puis recréation d'un Pod ;
- test de scaling manuel.

Diagrammes préparés :

- `diagrams/existant_monolithique.mmd` : architecture existante monolithique ;
- `diagrams/architecture_cible_kubernetes.mmd` : architecture cible Kubernetes ;
- `diagrams/flux_deploiement.mmd` : flux de déploiement Docker vers Kubernetes ;
- `diagrams/haute_disponibilite.mmd` : principe de haute disponibilité avec replicas.
- `diagrams/planning_projet.mmd` : planification globale du projet.
- `diagrams/objets_kubernetes_application.mmd` : objets Kubernetes de l'application de tickets.

## Conclusion

Ce projet permet de comprendre la valeur de Kubernetes dans une stratégie de modernisation applicative. En partant d'une architecture monolithique classique, la solution proposée introduit la conteneurisation, l'orchestration, la haute disponibilité et l'exposition centralisée des services. L'application de gestion de tickets/incidents sert de support concret pour démontrer les apports techniques de Kubernetes.
