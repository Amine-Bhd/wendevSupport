# Stratégie GitHub et préparation cloud

## 1. Pourquoi utiliser GitHub ?

Même avant le passage vers Azure, GitHub apporte plusieurs avantages :

- conserver l'historique du projet ;
- montrer la progression du travail ;
- centraliser le code, les manifests Kubernetes, les diagrammes et la documentation ;
- faciliter la collaboration et la relecture ;
- préparer une future automatisation CI/CD ;
- simplifier le passage vers le cloud.

Dans le cadre de ce projet, GitHub sert donc à la fois de preuve de traçabilité et de base technique pour une éventuelle version Azure AKS.

## 2. Ce qu'il faut versionner

À versionner :

- le code frontend et backend dans `app/` ;
- les Dockerfiles ;
- les manifests Kubernetes dans `k8s/` ;
- la configuration kind dans `infra/kind/` ;
- les diagrammes dans `diagrams/` ;
- le rapport et les documents de soutenance ;
- les captures utiles.

À éviter dans un dépôt public :

- les transcripts bruts des séances d'encadrement ;
- le cahier des charges PDF original ;
- les secrets réels ;
- les fichiers générés localement ;
- les dépendances comme `node_modules/`.

## 3. Gestion des Secrets

Le fichier réel suivant ne doit pas être poussé sur GitHub :

```text
k8s/02-secret.yaml
```

Il est ignoré par `.gitignore`.

Un exemple versionnable est fourni ici :

```text
k8s/examples/02-secret.example.yaml
```

Pour travailler localement, on peut copier l'exemple :

```powershell
Copy-Item k8s\examples\02-secret.example.yaml k8s\02-secret.yaml
```

En cloud, il faudra utiliser une solution plus propre :

- GitHub Secrets pour les pipelines ;
- Azure Key Vault ;
- variables sécurisées ;
- création du Secret Kubernetes au moment du déploiement.

## 4. Préparation avant push GitHub

Commandes recommandées :

```powershell
git init
git status
git add .
git commit -m "Initialisation du projet Kubernetes Wendev Tickets"
```

Ensuite, créer un dépôt GitHub vide, puis lier le dépôt local :

```powershell
git remote add origin https://github.com/<utilisateur>/<repo>.git
git branch -M main
git push -u origin main
```

Remplacer `<utilisateur>` et `<repo>` par les valeurs réelles.

## 5. Utilité pour Azure

GitHub facilitera le passage vers Azure AKS :

- le code applicatif sera centralisé ;
- les images Docker pourront être construites automatiquement ;
- les manifests Kubernetes seront réutilisables ;
- un pipeline GitHub Actions pourra déployer vers AKS ;
- les secrets cloud pourront être stockés hors du dépôt.
- les scripts Azure pourront être suivis, relus et réutilisés.

Architecture cible possible :

```text
GitHub
  -> build images
  -> Azure Container Registry
  -> Azure Kubernetes Service
  -> Ingress ou LoadBalancer
```

## 6. Décision retenue

Pour cette étape, le projet est préparé pour GitHub avec :

- un `README.md` ;
- un `.gitignore` ;
- un exemple de Secret Kubernetes ;
- une documentation expliquant quoi versionner et quoi exclure.

Le push vers GitHub doit être fait après validation du contenu à publier.

## 7. Maîtrise des coûts Azure

Le dépôt contient aussi des scripts pour éviter de laisser tourner inutilement les ressources cloud :

```text
infra/azure/05-stop-aks.ps1
infra/azure/06-start-aks.ps1
infra/azure/04-cleanup-azure.ps1
```

Cette approche permet de garder la traçabilité GitHub tout en contrôlant la consommation des crédits Azure.
