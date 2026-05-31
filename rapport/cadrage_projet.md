# Cadrage du projet PFA Kubernetes

## Décisions validées

- Langue du rapport et de la présentation : français.
- Sujet : mise en place d'une solution de conteneurisation avec Kubernetes.
- Entreprise fictive : Wendev.
- Scénario : migration d'applications monolithiques vers une architecture conteneurisée et orchestrée.
- Application de démonstration : application web de gestion de tickets/incidents.
- Environnement disponible : Windows 10, Docker Desktop, WSL 2.
- Approche recommandée : démarrage local pour apprendre et tester, puis déploiement cloud sur Azure AKS si le budget et le temps le permettent.

## Objectif principal

L'objectif du projet n'est pas de développer une application complexe, mais de mettre en place et démontrer une architecture Kubernetes capable d'héberger une application conteneurisée avec redondance, haute disponibilité, exposition via LoadBalancer ou Ingress, et gestion automatisée des déploiements.

## Scénario retenu

La société Wendev dispose initialement de plusieurs applications monolithiques installées sur des serveurs ou machines virtuelles séparés. Chaque application embarque une grande partie de sa logique dans un seul bloc applicatif et dépend souvent d'une configuration spécifique au serveur.

Cette architecture fonctionne pour un petit volume d'utilisateurs, mais elle devient difficile à maintenir lorsque les besoins augmentent. Les déploiements sont manuels, la scalabilité est limitée, la disponibilité dépend fortement de l'état du serveur, et une panne peut rendre l'application indisponible.

Pour répondre à ces limites, Wendev souhaite moderniser son infrastructure applicative en migrant progressivement vers des conteneurs Docker, puis vers une orchestration Kubernetes. Kubernetes permettra de déployer les applications sous forme de Pods, de les répliquer, de les exposer aux utilisateurs et de maintenir leur disponibilité en cas de panne d'un Pod ou d'un worker node.

## Application de démonstration

L'application retenue sera une application simple de gestion de tickets/incidents.

Fonctionnalités minimales :

- consulter la liste des tickets ;
- créer un ticket ;
- modifier le statut d'un ticket ;
- afficher l'état de santé de l'API via un endpoint de type `/health`.

Architecture applicative cible :

- Frontend web ;
- API backend ;
- Base de données PostgreSQL ;
- Images Docker pour le frontend et le backend ;
- Manifests Kubernetes pour déployer, exposer et répliquer les composants.

## Architecture Kubernetes cible

L'architecture cible devra permettre de démontrer les notions suivantes :

- cluster Kubernetes avec Control Plane et worker nodes ;
- Deployments pour gérer les replicas applicatifs ;
- Pods pour exécuter les conteneurs ;
- Services pour la communication interne ;
- Ingress ou LoadBalancer pour l'accès externe ;
- ConfigMap pour les paramètres non sensibles ;
- Secret pour les informations sensibles ;
- probes de santé pour vérifier la disponibilité ;
- test de suppression d'un Pod pour montrer l'auto-réparation ;
- éventuellement HPA pour montrer la scalabilité automatique.

## Choix local et cloud

Pour l'apprentissage local, un cluster multi-node est préférable afin de mieux illustrer la haute disponibilité. Deux options sont adaptées à Windows 10 avec Docker Desktop et WSL 2 :

- kind : pratique pour créer un cluster Kubernetes multi-node local à partir de conteneurs Docker ;
- Minikube : simple pour débuter, mais souvent utilisé en single-node, donc moins démonstratif pour la haute disponibilité.

Pour le cloud, Azure AKS est le meilleur candidat parce que l'utilisateur dispose de crédits Azure via son offre étudiante. AKS permettra de montrer un Kubernetes managé, avec Control Plane géré par Azure et worker nodes administrables côté client.

## Critères de réussite

Le projet sera considéré comme réussi si la démonstration permet de montrer :

- une application accessible via une URL ;
- au moins deux replicas du backend ou du frontend ;
- une exposition centralisée via Ingress ou LoadBalancer ;
- la recréation automatique d'un Pod après suppression ;
- une séparation claire entre application, conteneur Docker et orchestration Kubernetes ;
- des captures d'écran et diagrammes intégrés dans le rapport ;
- une explication claire des composants Kubernetes utilisés.

## Prochaines étapes

1. Rédiger la première version de l'étude de l'existant.
2. Préparer le schéma de l'existant.
3. Préparer le schéma de l'architecture cible Kubernetes.
4. Choisir l'outil local : kind ou Minikube.
5. Créer ensuite l'application de démonstration et les fichiers Docker/Kubernetes.
