# Phase 2 - Conduite du projet et étude comparative des solutions

## 1. Introduction

La deuxième phase du projet concerne la conduite du projet et l'étude comparative des solutions possibles. Après avoir identifié les limites de l'architecture existante, il est nécessaire de comparer les approches disponibles pour choisir une solution adaptée au besoin de Wendev.

L'objectif est de sélectionner une plateforme permettant de déployer, superviser, répliquer et exposer des applications conteneurisées tout en préparant une évolution vers une infrastructure plus moderne et plus automatisée.

## 2. Objectifs de la phase 2

Cette phase vise à :

- planifier les principales étapes du projet ;
- comparer les solutions de conteneurisation et d'orchestration ;
- comparer les options locales, on-premise et cloud ;
- justifier le choix de Kubernetes ;
- choisir un environnement de test adapté à la démonstration ;
- préparer la phase d'architecture et de mise en œuvre.

## 3. Planification du projet

Le projet est organisé en quatre grandes phases.

| Phase | Description | Livrable attendu |
| --- | --- | --- |
| Phase 1 | Étude de l'existant et définition de la problématique | Analyse de l'existant, critique, problématique, solution envisagée |
| Phase 2 | Conduite du projet et étude comparative | Planning, comparaison des solutions, choix de la solution |
| Phase 3 | Architecture Kubernetes | Architecture Control Plane / Data Plane, objets Kubernetes, schémas |
| Phase 4 | Mise en œuvre | Installation, déploiement, tests, captures, démonstration |

La planification réelle peut évoluer selon l'avancement technique, mais cette organisation permet de respecter la structure attendue dans le cahier des charges.

## 4. Critères de comparaison

Les solutions sont comparées selon les critères suivants :

- facilité d'installation ;
- facilité d'administration ;
- capacité de scalabilité ;
- haute disponibilité ;
- automatisation des déploiements ;
- gestion réseau et exposition des services ;
- maturité et adoption sur le marché ;
- intégration avec le cloud ;
- coût ;
- adaptation au contexte pédagogique du projet.

## 5. Docker seul

Docker permet de créer et d'exécuter des conteneurs à partir d'images. Il répond au besoin d'isolation des applications et facilite la portabilité entre environnements.

### Avantages

- simple à utiliser pour créer et lancer des conteneurs ;
- très adapté à la phase de conteneurisation ;
- facilite la création d'images applicatives ;
- large adoption et documentation abondante.

### Limites

- ne suffit pas pour gérer un grand nombre de conteneurs ;
- nécessite une gestion manuelle des conteneurs ;
- ne fournit pas à lui seul une orchestration avancée ;
- la haute disponibilité doit être gérée par d'autres mécanismes ;
- exposition, supervision et redémarrage automatique restent limités dans un contexte multi-serveur.

### Conclusion

Docker est indispensable pour construire les images de l'application, mais il ne suffit pas comme solution finale d'orchestration.

## 6. Docker Swarm

Docker Swarm est le mode d'orchestration intégré à Docker Engine. Il permet de créer un cluster de moteurs Docker et de déployer des services distribués.

### Avantages

- intégré à Docker Engine ;
- plus simple à prendre en main que Kubernetes ;
- permet le clustering, le service discovery, le load balancing et les rolling updates ;
- adapté à des architectures simples.

### Limites

- écosystème moins riche que Kubernetes ;
- moins utilisé dans les architectures cloud-native modernes ;
- moins de ressources pédagogiques et professionnelles autour de son administration ;
- moins adapté au cahier des charges, qui cible explicitement Kubernetes.

### Conclusion

Docker Swarm est une solution intéressante pour orchestrer des conteneurs de manière simple, mais Kubernetes est plus pertinent pour ce projet grâce à sa maturité, son adoption et son alignement direct avec le sujet.

## 7. Apache Mesos

Apache Mesos est une plateforme de gestion de ressources distribuées. Elle peut être utilisée pour exécuter différents types de workloads sur un cluster.

### Avantages

- adapté à des environnements distribués complexes ;
- capable de gérer différents types de charges ;
- historiquement utilisé dans certains grands environnements.

### Limites

- plus complexe à mettre en place ;
- moins adapté à un projet pédagogique centré sur Kubernetes ;
- moins courant dans les nouveaux projets cloud-native ;
- nécessite souvent un écosystème complémentaire.

### Conclusion

Apache Mesos n'est pas retenu, car il dépasse le besoin du projet et n'est pas directement aligné avec l'objectif d'apprentissage Kubernetes.

## 8. Kubernetes

Kubernetes est une plateforme open source d'orchestration de conteneurs. Elle permet d'automatiser le déploiement, la mise à l'échelle, l'exposition et la gestion des applications conteneurisées.

### Avantages

- très forte adoption dans l'industrie ;
- gestion déclarative des applications ;
- support des Deployments, Pods, Services, Ingress, ConfigMaps et Secrets ;
- redémarrage automatique des Pods en cas de panne ;
- scalabilité horizontale ;
- rolling updates et rollbacks ;
- intégration avec les principaux fournisseurs cloud ;
- vaste écosystème d'outils DevOps.

### Limites

- courbe d'apprentissage plus importante ;
- installation et administration plus complexes qu'une solution Docker simple ;
- nécessite une bonne compréhension des composants du cluster ;
- peut être coûteux dans le cloud si les ressources ne sont pas maîtrisées.

### Conclusion

Kubernetes est retenu comme solution principale, car il répond directement aux objectifs du projet : orchestration, haute disponibilité, redondance, exposition centralisée et automatisation.

## 9. Distributions et environnements Kubernetes

Kubernetes peut être utilisé à travers plusieurs distributions ou environnements.

### 9.1 Minikube

Minikube permet de lancer un cluster Kubernetes local, souvent utilisé pour l'apprentissage et les tests.

Avantages :

- simple pour débuter ;
- bon outil pédagogique ;
- installation rapide.

Limites :

- souvent utilisé en single-node ;
- moins démonstratif pour la haute disponibilité multi-nœuds.

### 9.2 kind

kind permet de créer des clusters Kubernetes locaux en utilisant des conteneurs Docker comme nœuds.

Avantages :

- permet de créer facilement un cluster multi-node local ;
- adapté aux tests Kubernetes ;
- fonctionne bien avec Docker Desktop ;
- très utile pour démontrer un Control Plane et plusieurs worker nodes.

Limites :

- nécessite une installation supplémentaire ;
- le LoadBalancer cloud n'est pas disponible naturellement en local ;
- l'exposition externe se fait généralement avec Ingress ou port mapping.

### 9.3 Docker Desktop Kubernetes

Docker Desktop peut activer un cluster Kubernetes local.

Avantages :

- intégré à Docker Desktop ;
- très simple à activer ;
- pratique pour tester les commandes `kubectl`.

Limites :

- généralement single-node ;
- moins adapté à la démonstration de haute disponibilité.

### 9.4 Rancher et OpenShift

Rancher et OpenShift sont des plateformes permettant de gérer Kubernetes avec des fonctionnalités supplémentaires.

Avantages :

- administration avancée ;
- interface graphique ;
- gestion multi-cluster ;
- fonctionnalités de sécurité et de gouvernance.

Limites :

- plus complexes ;
- nécessitent plus de ressources ;
- peuvent détourner l'attention de l'objectif principal qui est d'apprendre Kubernetes.

## 10. Kubernetes dans le cloud

Les principaux fournisseurs cloud proposent des services Kubernetes managés.

### 10.1 Azure Kubernetes Service - AKS

AKS est le service Kubernetes managé d'Azure. Il permet de déployer et gérer des applications conteneurisées avec Kubernetes tout en réduisant la complexité de gestion du Control Plane.

Avantages :

- intégration avec Azure ;
- Control Plane géré par Azure ;
- possibilité d'utiliser Azure Load Balancer ;
- adapté à une démonstration cloud ;
- cohérent avec les crédits Azure disponibles.

Limites :

- peut générer des coûts ;
- nécessite une configuration Azure ;
- demande une gestion rigoureuse des ressources créées.

### 10.2 Amazon Elastic Kubernetes Service - EKS

EKS est le service Kubernetes managé d'AWS. AWS gère le Control Plane et fournit une intégration avec les services AWS comme EC2, ECR, CloudWatch et Elastic Load Balancing.

Avantages :

- service mature ;
- bonne intégration avec l'écosystème AWS ;
- adapté aux environnements professionnels ;
- support de l'automatisation et du scaling.

Limites :

- configuration parfois plus complexe ;
- coûts à surveiller ;
- moins pertinent pour ce projet si les crédits disponibles sont principalement Azure.

### 10.3 Google Kubernetes Engine - GKE

GKE est le service Kubernetes managé de Google Cloud. Il propose notamment les modes Standard et Autopilot.

Avantages :

- très forte intégration Kubernetes ;
- Control Plane géré par Google Cloud ;
- mode Autopilot pour réduire la gestion des nœuds ;
- bonne documentation.

Limites :

- nécessite un compte Google Cloud ;
- coûts à surveiller ;
- moins aligné avec les crédits disponibles dans ce projet.

## 11. Comparaison synthétique

| Solution | Type | Points forts | Limites | Décision |
| --- | --- | --- | --- | --- |
| Docker seul | Conteneurisation | Simple, portable, indispensable pour les images | Pas d'orchestration avancée | Utilisé pour créer les images |
| Docker Swarm | Orchestration Docker | Simple, intégré à Docker | Écosystème plus limité | Non retenu comme solution principale |
| Apache Mesos | Gestion de ressources distribuées | Puissant pour grands clusters hétérogènes | Trop complexe pour le besoin | Non retenu |
| Kubernetes | Orchestration | Standard du marché, HA, scaling, Services, Ingress | Plus complexe | Retenu |
| Minikube | Kubernetes local | Simple pour apprendre | Souvent single-node | Option secondaire |
| kind | Kubernetes local multi-node | Très adapté aux tests multi-node | Installation nécessaire | Retenu pour le local |
| Docker Desktop Kubernetes | Kubernetes local | Très simple | Moins démonstratif pour HA | Option de secours |
| AKS | Kubernetes managé Azure | Cloud, LoadBalancer, Control Plane géré | Coût à surveiller | Retenu pour extension cloud |
| EKS | Kubernetes managé AWS | Très mature, intégré AWS | Coût/configuration | Non retenu pour ce projet |
| GKE | Kubernetes managé Google | Très complet, Autopilot | Coût/configuration | Non retenu pour ce projet |

## 12. Choix final

La solution retenue est Kubernetes.

Pour la phase locale, le choix recommandé est :

```text
Docker Desktop + Debian WSL 2 + kubectl + kind
```

Ce choix permet de créer un cluster local multi-node composé d'un Control Plane et de plusieurs worker nodes. Il est adapté à la démonstration de la haute disponibilité, car les Pods peuvent être répartis sur plusieurs nœuds.

Pour la phase cloud optionnelle, le choix recommandé est :

```text
Azure Kubernetes Service - AKS
```

AKS est retenu comme extension cloud, car il est cohérent avec les crédits Azure disponibles et permettrait de montrer un vrai service Kubernetes managé avec exposition via LoadBalancer.

## 13. Justification du choix

Kubernetes est choisi parce qu'il répond aux besoins identifiés dans la phase 1 :

- automatiser le déploiement des applications ;
- gérer plusieurs conteneurs à grande échelle ;
- assurer la haute disponibilité grâce aux replicas ;
- exposer les applications avec Services, Ingress ou LoadBalancer ;
- faciliter les mises à jour progressives ;
- permettre une évolution vers le cloud ;
- correspondre directement au cahier des charges du projet.

Le choix de kind en local permet d'apprendre Kubernetes dans un environnement contrôlé, sans coût cloud immédiat. Le choix d'AKS en option cloud permet de prolonger la démonstration vers une architecture plus proche d'un environnement professionnel.

## 14. Sources officielles consultées

- Microsoft Learn - Azure Kubernetes Service : https://learn.microsoft.com/en-us/azure/aks/
- AWS Documentation - Amazon EKS : https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
- Google Cloud Documentation - GKE overview : https://docs.cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview
- Docker Documentation - Swarm mode : https://docs.docker.com/engine/swarm/
- Kubernetes Documentation - Ingress : https://kubernetes.io/docs/concepts/services-networking/ingress/

## 15. Conclusion de la phase 2

L'étude comparative montre que Docker est nécessaire pour créer les images, mais qu'il ne suffit pas pour répondre aux besoins d'orchestration. Docker Swarm et Mesos sont des alternatives possibles, mais Kubernetes reste la solution la plus adaptée au cahier des charges.

Le projet s'appuiera donc sur Kubernetes, avec une première mise en œuvre locale basée sur kind, puis une extension possible vers Azure AKS pour démontrer une solution Kubernetes managée dans le cloud.
