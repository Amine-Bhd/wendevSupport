# Phase 3 - Architecture Kubernetes

## 1. Introduction

La troisième phase du projet consiste à définir l'architecture Kubernetes retenue pour héberger l'application de démonstration. Cette phase permet de comprendre les composants d'un cluster Kubernetes, leur rôle, ainsi que la manière dont l'application sera déployée, exposée et répliquée.

L'objectif est de passer d'une architecture traditionnelle basée sur des serveurs applicatifs séparés vers une architecture centralisée autour d'un cluster Kubernetes capable d'exécuter des conteneurs de manière automatisée.

## 2. Définition d'un cluster Kubernetes

Un cluster Kubernetes est un ensemble de machines physiques ou virtuelles utilisées pour exécuter des applications conteneurisées. Ces machines sont appelées des nœuds.

Un cluster Kubernetes est composé de deux grandes parties :

- le Control Plane ;
- le Data Plane, aussi appelé ensemble des worker nodes.

Le Control Plane est responsable de la gestion globale du cluster. Les worker nodes exécutent les applications sous forme de Pods.

Dans le cadre de ce projet, l'architecture locale visée est composée de :

- 1 nœud Control Plane ;
- 2 worker nodes ;
- plusieurs Pods applicatifs répartis sur les worker nodes.

Cette architecture permet de démontrer la séparation entre la gestion du cluster et l'exécution réelle des conteneurs.

## 3. Control Plane

Le Control Plane représente le cerveau du cluster Kubernetes. Il reçoit les demandes d'administration, surveille l'état du cluster et prend les décisions nécessaires pour maintenir l'état désiré.

Par exemple, si un Deployment indique que deux replicas d'une application doivent fonctionner, le Control Plane s'assure que ces deux replicas existent réellement. Si un Pod est supprimé ou tombe en panne, Kubernetes crée automatiquement un nouveau Pod pour revenir à l'état désiré.

### 3.1 kube-apiserver

Le kube-apiserver expose l'API Kubernetes. Toutes les commandes `kubectl` passent par cette API.

Rôle :

- recevoir les demandes d'administration ;
- valider les objets Kubernetes ;
- permettre la communication entre les composants du cluster ;
- exposer le point d'entrée principal du Control Plane.

Exemple :

```bash
kubectl get pods
kubectl apply -f deployment.yaml
```

Ces commandes communiquent avec le kube-apiserver.

### 3.2 etcd

etcd est la base de données clé-valeur du cluster Kubernetes. Elle stocke l'état du cluster.

Elle contient par exemple :

- les Deployments ;
- les Services ;
- les Secrets ;
- les ConfigMaps ;
- les informations sur les nœuds ;
- l'état souhaité et l'état courant du cluster.

etcd est un composant critique. Si etcd est perdu sans sauvegarde, l'état du cluster peut être perdu.

### 3.3 kube-scheduler

Le kube-scheduler décide sur quel worker node un nouveau Pod doit être placé.

Il prend en compte plusieurs éléments :

- ressources disponibles ;
- contraintes de placement ;
- état des nœuds ;
- règles éventuelles d'affinité ou anti-affinité.

Dans le projet, ce composant permettra de répartir les Pods frontend et backend sur les worker nodes disponibles.

### 3.4 kube-controller-manager

Le kube-controller-manager exécute plusieurs contrôleurs chargés de surveiller le cluster et de corriger les écarts entre l'état souhaité et l'état réel.

Exemple :

- si un Deployment demande deux replicas ;
- si un Pod disparaît ;
- le contrôleur crée un nouveau Pod pour revenir à deux replicas.

Ce mécanisme est essentiel pour démontrer l'auto-réparation de Kubernetes.

### 3.5 cloud-controller-manager

Le cloud-controller-manager est utilisé lorsque Kubernetes est exécuté dans un cloud provider comme Azure, AWS ou Google Cloud.

Il permet l'intégration avec les services cloud, par exemple :

- création d'un LoadBalancer ;
- gestion des nœuds cloud ;
- intégration réseau ;
- interaction avec les ressources du fournisseur cloud.

Dans l'environnement local kind, ce composant n'a pas le même rôle que dans Azure AKS. Dans AKS, Azure gère une partie importante de cette intégration.

## 4. Data Plane / Worker Nodes

Le Data Plane est composé des worker nodes. Ce sont les machines qui exécutent réellement les conteneurs applicatifs.

Chaque worker node contient plusieurs composants importants :

- kubelet ;
- kube-proxy ;
- runtime de conteneurs ;
- Pods applicatifs.

Dans notre architecture locale, les worker nodes seront simulés par des conteneurs Docker grâce à kind. Dans un environnement cloud comme AKS, les worker nodes correspondent à des machines virtuelles Azure.

## 5. kubelet

Le kubelet est un agent installé sur chaque worker node. Il communique avec le Control Plane et s'assure que les Pods demandés fonctionnent correctement sur le nœud.

Rôle :

- recevoir les instructions du Control Plane ;
- lancer les Pods ;
- surveiller l'état des conteneurs ;
- remonter l'état du nœud au Control Plane.

Sans kubelet, un nœud ne peut pas participer correctement au cluster.

## 6. kube-proxy

kube-proxy est chargé de gérer une partie du réseau Kubernetes sur chaque worker node.

Rôle :

- permettre la communication vers les Services ;
- rediriger le trafic vers les bons Pods ;
- participer au load balancing interne entre les replicas.

Grâce à kube-proxy, un Service Kubernetes peut envoyer le trafic vers plusieurs Pods backend sans que l'utilisateur connaisse l'adresse IP de chaque Pod.

## 7. Runtime de conteneurs

Le runtime de conteneurs est le composant qui exécute concrètement les conteneurs.

Historiquement, Docker était très utilisé comme runtime. Aujourd'hui, Kubernetes utilise souvent containerd. Dans le cadre du projet local avec kind, les nœuds Kubernetes sont créés au-dessus de Docker Desktop, et les conteneurs applicatifs sont exécutés dans l'environnement Kubernetes.

## 8. Objets Kubernetes utilisés dans le projet

Kubernetes repose sur des objets déclaratifs. L'administrateur décrit l'état souhaité dans des fichiers YAML, puis Kubernetes applique cet état.

Les principaux objets utilisés dans ce projet seront les suivants.

## 9. Namespace

Un Namespace permet d'organiser les ressources Kubernetes dans un espace logique.

Dans ce projet, il est possible de créer un Namespace dédié :

```text
wendev
```

Cela permet de séparer les ressources de l'application de démonstration des ressources système du cluster.

## 10. Pod

Le Pod est la plus petite unité déployable dans Kubernetes. Il contient un ou plusieurs conteneurs qui partagent le même réseau et parfois les mêmes volumes.

Dans ce projet :

- un Pod frontend contiendra le conteneur de l'interface web ;
- un Pod backend contiendra le conteneur de l'API ;
- un Pod PostgreSQL pourra contenir la base de données pour la démonstration.

Un Pod peut disparaître et être recréé. Il ne faut donc pas dépendre directement de son adresse IP.

## 11. Deployment

Un Deployment permet de gérer le cycle de vie d'une application stateless.

Il permet de définir :

- l'image Docker à utiliser ;
- le nombre de replicas ;
- les variables d'environnement ;
- les probes de santé ;
- la stratégie de mise à jour.

Dans ce projet, le frontend et le backend seront déployés avec des Deployments.

Exemple d'objectif :

```text
backend-api : 2 replicas
frontend : 2 replicas
```

Si un Pod backend tombe en panne, le Deployment permet à Kubernetes d'en recréer automatiquement un autre.

## 12. ReplicaSet

Le ReplicaSet est créé automatiquement par le Deployment. Il garantit qu'un nombre précis de replicas est en cours d'exécution.

Dans le rapport, il suffit de retenir que le Deployment utilise un ReplicaSet pour maintenir le nombre de Pods demandé.

## 13. Service

Un Service permet d'exposer un ensemble de Pods à travers une adresse stable.

Les Pods peuvent être supprimés et recréés avec de nouvelles adresses IP. Le Service masque cette instabilité en fournissant un point d'accès stable.

Dans ce projet :

- un Service frontend permettra d'accéder aux Pods frontend ;
- un Service backend permettra au frontend de communiquer avec l'API ;
- un Service PostgreSQL permettra au backend d'accéder à la base de données.

Types importants :

- ClusterIP : accès interne au cluster ;
- NodePort : exposition sur un port du nœud ;
- LoadBalancer : exposition via un load balancer cloud ;
- ExternalName : redirection vers un nom externe.

En local avec kind, l'exposition se fera principalement via Ingress. Dans Azure AKS, un Service de type LoadBalancer pourra créer un vrai load balancer Azure.

## 14. Ingress

L'Ingress permet de gérer l'accès HTTP ou HTTPS aux applications depuis l'extérieur du cluster.

Il fonctionne avec un Ingress Controller, par exemple NGINX Ingress Controller.

Dans ce projet, l'Ingress permettra d'accéder à l'application via une URL locale ou cloud.

Exemple de routage possible :

```text
/          -> frontend
/api       -> backend
/health    -> backend
```

L'Ingress joue donc le rôle de point d'entrée applicatif.

## 15. ConfigMap

Une ConfigMap permet de stocker des paramètres de configuration non sensibles.

Exemples :

- URL interne de l'API ;
- mode d'exécution ;
- nom de l'application ;
- paramètres fonctionnels.

Cela évite de coder ces paramètres directement dans l'image Docker.

## 16. Secret

Un Secret permet de stocker des informations sensibles, par exemple :

- mot de passe de base de données ;
- utilisateur PostgreSQL ;
- clé d'API ;
- token.

Dans ce projet, les identifiants PostgreSQL seront stockés dans un Secret Kubernetes.

## 17. PersistentVolume et PersistentVolumeClaim

Les Pods sont éphémères. Si un Pod de base de données est supprimé, ses données peuvent être perdues si aucun stockage persistant n'est configuré.

Pour gérer ce besoin, Kubernetes utilise :

- PersistentVolume ;
- PersistentVolumeClaim.

Dans le cadre de la démonstration locale, PostgreSQL pourra utiliser un volume persistant simple. Dans une architecture de production, il serait préférable d'utiliser une base de données managée, par exemple Azure Database for PostgreSQL.

## 18. Probes de santé

Kubernetes permet de configurer des probes pour vérifier l'état des applications.

Types principaux :

- readinessProbe : indique si le Pod est prêt à recevoir du trafic ;
- livenessProbe : indique si le Pod est encore vivant ;
- startupProbe : utile pour les applications longues à démarrer.

Dans ce projet, le backend exposera un endpoint :

```text
/health
```

Kubernetes pourra l'utiliser pour vérifier que l'API fonctionne.

## 19. Architecture applicative cible

L'application de démonstration sera composée de trois parties :

- Frontend web ;
- Backend API ;
- PostgreSQL.

Flux logique :

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

Le frontend et le backend seront répliqués pour démontrer la haute disponibilité. PostgreSQL sera utilisé comme base de données de démonstration.

## 20. Architecture de haute disponibilité

La haute disponibilité sera démontrée à travers les replicas.

Exemple :

```text
backend-api replicas: 2
```

Kubernetes essaiera de maintenir deux Pods backend en fonctionnement. Si un Pod est supprimé, le Deployment et le ReplicaSet permettront d'en recréer un nouveau.

Dans un cluster multi-node, l'objectif est de répartir les replicas sur plusieurs worker nodes. Ainsi, si un worker node rencontre un problème, un autre replica peut continuer à répondre.

Limite importante :

Dans l'environnement local kind, les worker nodes sont simulés par des conteneurs Docker sur une même machine physique. Cela permet de démontrer le mécanisme Kubernetes, mais ce n'est pas une vraie haute disponibilité matérielle. Une vraie haute disponibilité de production nécessite plusieurs machines physiques ou virtuelles, idéalement réparties sur plusieurs zones de disponibilité.

## 21. Architecture locale avec kind

L'environnement local recommandé est kind.

Cluster local visé :

```text
1 control-plane
2 worker nodes
```

Avantages :

- aucun coût cloud ;
- rapide à créer et supprimer ;
- possibilité de tester `kubectl` ;
- possibilité de montrer plusieurs nœuds ;
- adapté aux captures d'écran et à l'apprentissage.

Limites :

- tous les nœuds tournent sur la même machine ;
- pas de vrai LoadBalancer cloud ;
- ressources limitées par le poste local.

## 22. Architecture cloud avec Azure AKS

Azure AKS représente l'extension cloud possible du projet.

Dans AKS :

- Azure gère le Control Plane ;
- le client gère principalement les worker nodes ;
- les Services de type LoadBalancer peuvent créer un Azure Load Balancer ;
- le cluster peut être intégré avec Azure Container Registry ;
- la disponibilité peut être améliorée avec plusieurs nœuds et zones.

AKS est donc plus proche d'un environnement professionnel, mais il demande une attention particulière au coût.

## 23. Sécurité et isolation

Même pour une démonstration simple, certains principes doivent être respectés :

- ne pas mettre les mots de passe directement dans le code ;
- utiliser des Secrets pour les informations sensibles ;
- utiliser des ConfigMaps pour les paramètres non sensibles ;
- limiter l'exposition externe aux composants nécessaires ;
- garder la base de données accessible uniquement depuis le backend ;
- utiliser un Namespace dédié pour organiser les ressources.

Dans une architecture plus avancée, on pourrait ajouter :

- NetworkPolicies ;
- RBAC ;
- TLS sur l'Ingress ;
- registry privé ;
- scanning des images Docker.

## 24. Synthèse de l'architecture retenue

L'architecture retenue pour le projet est la suivante :

| Élément | Choix |
| --- | --- |
| Cluster local | kind |
| Nœuds locaux | 1 control-plane + 2 workers |
| Application | Gestion de tickets/incidents |
| Frontend | Deployment avec 2 replicas |
| Backend | Deployment avec 2 replicas |
| Base de données | PostgreSQL |
| Communication interne | Services Kubernetes |
| Accès externe local | Ingress |
| Accès externe cloud | LoadBalancer ou Ingress AKS |
| Configuration | ConfigMap |
| Informations sensibles | Secret |
| Haute disponibilité | Replicas + redémarrage automatique |

## 25. Diagrammes associés

Les diagrammes associés à cette phase sont :

- `diagrams/architecture_cible_kubernetes.mmd` ;
- `diagrams/haute_disponibilite.mmd` ;
- `diagrams/flux_deploiement.mmd` ;
- `diagrams/objets_kubernetes_application.mmd`.

## 26. Conclusion de la phase 3

L'architecture Kubernetes proposée permet de répondre aux limites identifiées dans l'existant. Elle introduit une séparation claire entre la gestion du cluster et l'exécution des applications, tout en permettant la réplication, l'exposition centralisée et l'auto-réparation.

Cette architecture servira de base à la phase 4, qui consistera à mettre en œuvre le cluster local, créer les images Docker, déployer l'application et réaliser les tests de disponibilité.
