# Phase 1 - Étude de l'existant et définition de la problématique

## 1. Introduction

La première phase du projet consiste à étudier l'existant de l'entreprise fictive Wendev afin d'identifier les limites de son architecture actuelle. Cette étape permet de justifier le besoin d'une solution de conteneurisation et d'orchestration basée sur Kubernetes.

Dans ce scénario, Wendev possède plusieurs applications métiers développées progressivement selon une architecture monolithique. Chaque application est installée directement sur un serveur ou une machine virtuelle, avec ses dépendances, sa configuration et parfois sa base de données.

## 2. Présentation de l'entreprise Wendev

Wendev est une entreprise fictive organisée autour de plusieurs activités :

- développement logiciel ;
- vente de matériels informatiques ;
- formation ;
- atelier technique et support.

Ces activités nécessitent plusieurs applications internes et externes, par exemple :

- application de gestion des clients ;
- application de gestion des tickets/incidents ;
- application de suivi des formations ;
- application de gestion commerciale ;
- application d'administration interne.

L'entreprise souhaite moderniser son infrastructure afin de rendre ses applications plus faciles à déployer, plus disponibles et plus évolutives.

## 3. Existant matériel

L'architecture actuelle repose sur plusieurs serveurs ou machines virtuelles hébergés dans l'infrastructure de l'entreprise. Chaque serveur est généralement associé à une application précise.

| Élément | Rôle dans l'existant |
| --- | --- |
| Serveur applicatif 1 | Héberge une application monolithique de gestion interne |
| Serveur applicatif 2 | Héberge une application métier ou commerciale |
| Serveur applicatif 3 | Héberge une application support ou tickets |
| Serveur de base de données | Héberge les données d'une ou plusieurs applications |
| Switch | Relie les serveurs au réseau local |
| Routeur / pare-feu | Permet l'accès réseau interne ou externe |
| Poste administrateur | Sert aux opérations de maintenance et de déploiement |

Dans certains cas, l'application et la base de données peuvent se trouver sur le même serveur. Cette situation simplifie l'installation initiale, mais augmente les risques en cas de panne ou de surcharge.

## 4. Existant logiciel

Les applications existantes sont principalement monolithiques. Une application monolithique regroupe dans un seul projet ou un seul bloc applicatif :

- l'interface utilisateur ;
- la logique métier ;
- l'accès aux données ;
- les dépendances techniques ;
- la configuration d'exécution.

Ce modèle peut être adapté au début d'un projet, car il est simple à développer et à déployer. Cependant, il devient plus difficile à maintenir lorsque l'application grandit ou lorsque plusieurs équipes doivent travailler en parallèle.

Les déploiements se font de manière manuelle ou semi-manuelle. L'administrateur doit se connecter aux serveurs, copier les fichiers, configurer les dépendances, redémarrer les services et vérifier que l'application fonctionne correctement.

## 5. Schéma du réseau existant

Le réseau existant peut être représenté par plusieurs serveurs applicatifs connectés au réseau local de l'entreprise. Chaque serveur héberge une application spécifique.

Voir le diagramme : `diagrams/existant_monolithique.mmd`.

## 6. Critique de l'existant

L'architecture actuelle présente plusieurs limites techniques et organisationnelles.

### 6.1 Faible disponibilité

Chaque application dépend fortement du serveur sur lequel elle est installée. Si ce serveur tombe en panne, l'application devient indisponible jusqu'à l'intervention de l'administrateur.

### 6.2 Scalabilité limitée

Pour augmenter la capacité d'une application, il faut généralement ajouter des ressources au serveur existant ou préparer manuellement un nouveau serveur. Cette opération est lente et peu flexible.

### 6.3 Déploiements manuels

Les déploiements nécessitent des interventions humaines répétitives. Cela augmente le risque d'erreur de configuration, d'oubli de dépendances ou d'interruption de service.

### 6.4 Dépendance à l'environnement serveur

Une application peut fonctionner sur un serveur mais rencontrer des problèmes sur un autre à cause de différences de versions, de bibliothèques ou de configuration.

### 6.5 Maintenance complexe

Dans une architecture monolithique, une modification sur une fonctionnalité peut nécessiter le redéploiement de toute l'application. Cela rend les mises à jour plus risquées.

### 6.6 Faible isolation des incidents

Lorsqu'une partie de l'application rencontre un problème, l'ensemble du monolithe peut être impacté. Il est difficile d'isoler une fonctionnalité défaillante.

### 6.7 Absence d'orchestration

Les conteneurs peuvent être lancés manuellement avec Docker, mais lorsque leur nombre augmente, leur supervision, leur redémarrage, leur exposition et leur répartition deviennent difficiles sans orchestrateur.

## 7. Problématique

La problématique du projet peut être formulée ainsi :

> Comment moderniser l'infrastructure applicative de Wendev afin de garantir une meilleure disponibilité, une scalabilité plus flexible, une automatisation des déploiements et une gestion centralisée des applications conteneurisées ?

Cette problématique conduit à rechercher une solution capable de :

- conteneuriser les applications ;
- automatiser leur déploiement ;
- répartir les conteneurs sur plusieurs nœuds ;
- redémarrer automatiquement les composants défaillants ;
- exposer les applications aux utilisateurs ;
- faciliter les mises à jour ;
- préparer une évolution vers le cloud.

## 8. Solution envisagée

La solution envisagée consiste à migrer progressivement les applications vers des conteneurs Docker, puis à les déployer dans un cluster Kubernetes.

Docker permettra d'encapsuler les applications avec leurs dépendances dans des images portables. Kubernetes permettra ensuite d'orchestrer ces conteneurs à travers des objets tels que les Pods, Deployments, Services et Ingress.

Grâce à Kubernetes, Wendev pourra :

- exécuter plusieurs replicas d'une application ;
- répartir les Pods sur plusieurs worker nodes ;
- exposer l'application via un point d'accès centralisé ;
- redémarrer automatiquement les Pods en cas de panne ;
- effectuer des mises à jour progressives ;
- préparer un déploiement local ou cloud selon les besoins.

## 9. Cas d'étude retenu

Pour démontrer la solution, une application simple de gestion de tickets/incidents sera utilisée. Elle servira de support pour tester :

- la création d'images Docker ;
- le déploiement sur Kubernetes ;
- la communication entre frontend, backend et base de données ;
- l'exposition via Ingress ou LoadBalancer ;
- la haute disponibilité grâce aux replicas ;
- la reprise automatique après suppression d'un Pod.

L'application reste volontairement simple afin que le cœur du projet reste Kubernetes et non le développement applicatif.

## 10. Conclusion de la phase 1

L'étude de l'existant montre que l'architecture monolithique actuelle de Wendev présente des limites en matière de disponibilité, de scalabilité et d'automatisation. La solution envisagée repose sur la conteneurisation avec Docker et l'orchestration avec Kubernetes.

Cette phase justifie donc le passage vers une architecture moderne, capable d'héberger des applications conteneurisées de manière plus fiable, plus flexible et plus industrialisée.
