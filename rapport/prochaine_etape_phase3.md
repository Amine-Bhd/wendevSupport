# Prochaine étape - Phase 3 Architecture Kubernetes

## Objectif

La phase 3 doit expliquer l'architecture Kubernetes retenue avant de passer à la mise en œuvre. Elle doit montrer que les composants du cluster sont compris et que leur rôle est clair.

## Contenu à rédiger

La phase 3 devra contenir :

- définition d'un cluster Kubernetes ;
- différence entre Control Plane et Data Plane ;
- rôle des worker nodes ;
- rôle des Pods ;
- rôle des Deployments ;
- rôle des Services ;
- rôle de l'Ingress ou du LoadBalancer ;
- rôle des ConfigMaps et Secrets ;
- architecture applicative de l'application de tickets ;
- architecture de haute disponibilité avec plusieurs replicas ;
- différence entre cluster local kind et cluster cloud AKS.

## Diagrammes à utiliser

- `diagrams/architecture_cible_kubernetes.mmd`
- `diagrams/haute_disponibilite.mmd`
- `diagrams/flux_deploiement.mmd`

## Décisions techniques déjà prises

- Application : gestion de tickets/incidents.
- Environnement local : kind avec Docker Desktop.
- Cluster local visé : 1 control-plane + 2 worker nodes.
- Exposition locale : Ingress.
- Exposition cloud optionnelle : LoadBalancer AKS.
- Base de données : PostgreSQL pour la démonstration.

## Points à vérifier avant installation

- Docker Desktop doit être lancé.
- L'intégration Docker avec Debian WSL 2 doit être activée dans Docker Desktop.
- `kubectl` doit être accessible.
- `kind` doit être installé.
- Le cluster local doit être créé avec une configuration multi-node.

## Commandes prévues plus tard

```bash
kind create cluster --config infra/kind/kind-cluster.yaml
kubectl get nodes
kubectl get pods -A
kubectl apply -f k8s/
kubectl get pods -o wide
```

Ces commandes seront utilisées pendant la phase 4, après la rédaction de l'architecture.
