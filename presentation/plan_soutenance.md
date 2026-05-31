# Plan de soutenance

## Objectif

Présenter clairement la mise en place d'une solution de conteneurisation avec Kubernetes, en montrant le passage d'une architecture monolithique classique vers une architecture conteneurisée, répliquée et exposée.

## Proposition de slides

1. Titre du projet
2. Contexte et objectifs
3. Présentation de l'existant Wendev
4. Limites de l'architecture monolithique
5. Problématique
6. Solution proposée : Docker + Kubernetes
7. Étude comparative des solutions
8. Architecture Kubernetes : Control Plane et Worker Nodes
9. Architecture cible de l'application
10. Mise en œuvre : cluster, images, manifests
11. Tests : accès, replicas, suppression d'un Pod, haute disponibilité
12. Conclusion et perspectives

## Démonstration prévue

Le déroulé détaillé est préparé dans `presentation/script_demonstration_kubernetes.md`.

- afficher le cluster avec `kubectl get nodes -o wide` ;
- afficher les Deployments avec `kubectl get deploy -n wendev -o wide` ;
- afficher les Pods avec `kubectl get pods -n wendev -o wide` ;
- ouvrir l'application dans le navigateur via `http://127.0.0.1:8080` ;
- créer un ticket depuis l'interface web ;
- supprimer un Pod backend ;
- montrer que Kubernetes recrée automatiquement un nouveau Pod ;
- montrer que l'application reste accessible ;
- expliquer que l'Ingress local fonctionne avec NGINX Ingress Controller et que l'exposition cloud pourra se faire avec un LoadBalancer Azure ou un Ingress Controller.
