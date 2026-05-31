# Plan technique Kubernetes

## État actuel de la machine

Environnement confirmé :

- Windows 10 ;
- Docker Desktop installé ;
- WSL 2 installé ;
- Debian disponible dans WSL 2 ;
- `kubectl` installé ;
- aucun contexte Kubernetes actif dans `kubectl` ;
- `kind` non installé ;
- `minikube` non installé.

Conséquence : la machine est prête pour commencer. Le poste dispose déjà d'un environnement Linux via Debian WSL 2, ce qui permet de travailler proprement avec Docker, `kubectl`, `kind` et les fichiers YAML Kubernetes.

## Option 1 : Docker Desktop Kubernetes

Principe : activer Kubernetes directement dans Docker Desktop.

Avantages :

- très simple à activer ;
- bonne option pour apprendre les premières commandes `kubectl` ;
- pas besoin d'installer un outil supplémentaire.

Limites :

- cluster généralement single-node ;
- moins adapté pour démontrer la haute disponibilité entre plusieurs worker nodes ;
- utile pour les tests de base, mais moins fort pour la soutenance.

## Option 2 : kind avec Docker Desktop

Principe : utiliser kind pour créer un cluster Kubernetes local composé de plusieurs nœuds, chaque nœud étant simulé par un conteneur Docker.

Avantages :

- permet de créer un cluster multi-node local ;
- très adapté pour démontrer Control Plane + plusieurs worker nodes ;
- bon compromis entre simplicité et démonstration Kubernetes réaliste ;
- fonctionne bien avec Docker Desktop.

Limites :

- nécessite l'installation de kind ;
- le LoadBalancer cloud n'est pas disponible naturellement en local, donc il faudra utiliser Ingress ou un outil complémentaire.

Recommandation locale : utiliser kind pour créer un cluster avec 1 control-plane et 2 worker nodes, de préférence depuis Debian WSL 2 ou depuis PowerShell selon l'intégration Docker disponible.

Architecture locale visée :

```text
Machine Windows 10
    |
Docker Desktop
    |
kind cluster
    |
+-------------------+-------------------+-------------------+
| control-plane     | worker-1          | worker-2          |
| API Kubernetes    | Pods applicatifs  | Pods applicatifs  |
+-------------------+-------------------+-------------------+
```

## Option 3 : Azure AKS

Principe : créer un cluster Kubernetes managé sur Azure.

Avantages :

- aligné avec le sujet du projet ;
- Control Plane géré par Azure ;
- possibilité d'utiliser un vrai LoadBalancer cloud ;
- très bon pour les captures et la soutenance ;
- cohérent avec l'offre étudiante Azure.

Limites :

- peut générer des coûts ;
- nécessite une configuration cloud plus longue ;
- il faut supprimer les ressources après les tests pour éviter les frais.

Recommandation cloud : utiliser AKS après validation locale.

## Chemin de travail recommandé

1. Installer kind si nécessaire.
2. Démarrer localement avec kind.
3. Créer une application simple de gestion de tickets.
4. Créer les images Docker frontend et backend.
5. Déployer l'application sur le cluster kind.
6. Exposer l'application via Ingress local.
7. Tester la haute disponibilité avec plusieurs replicas.
8. Capturer les commandes et les écrans.
9. Reproduire ensuite une version cloud sur Azure AKS si le temps et le budget le permettent.

## Tests Kubernetes à démontrer

Commandes et tests à prévoir :

- `kubectl get nodes` pour afficher les nœuds du cluster ;
- `kubectl get pods -o wide` pour voir sur quels worker nodes les Pods sont placés ;
- `kubectl get deployments` pour afficher les Deployments ;
- `kubectl get svc` pour afficher les Services ;
- `kubectl get ingress` pour afficher l'Ingress ;
- suppression d'un Pod avec `kubectl delete pod` ;
- vérification de la recréation automatique du Pod ;
- scaling manuel avec `kubectl scale deployment` ;
- rolling update avec une nouvelle image ;
- accès navigateur à l'application.

## Décision à prendre

Pour la première mise en œuvre locale, le choix recommandé est :

```text
kind + Docker Desktop + kubectl
```

Ce choix permet de rester sur la machine Windows 10 tout en ayant un cluster multi-node suffisamment démonstratif pour le rapport et la soutenance.
