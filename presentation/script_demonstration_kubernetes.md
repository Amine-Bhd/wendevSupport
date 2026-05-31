# Script de démonstration Kubernetes

## Objectif de la démonstration

Montrer que l'application Wendev Tickets est conteneurisée, déployée sur Kubernetes, exposée via Ingress, redondée avec plusieurs replicas et capable de continuer à fonctionner lorsqu'un Pod backend est supprimé.

Durée recommandée : 8 à 12 minutes.

## 0. Préparation avant la soutenance

À faire avant de commencer la démonstration :

- lancer Docker Desktop ;
- vérifier que le cluster kind `wendev-local` est actif ;
- vérifier que l'application répond sur `http://127.0.0.1:8080` ;
- ouvrir un terminal PowerShell dans le dossier du projet :

```powershell
cd C:\Users\amine\Desktop\PFAm1
```

Vérification rapide :

```powershell
kubectl get nodes -o wide
kubectl get deploy -n wendev -o wide
curl.exe http://127.0.0.1:8080/api/health
```

Résultat attendu :

```text
backend-api   3/3
frontend      2/2
database      connected
```

Phrase à dire :

> Avant de commencer, je vérifie que mon cluster Kubernetes local est opérationnel et que l'application répond bien à travers l'Ingress.

## 1. Présenter le cluster Kubernetes

Commande :

```powershell
kubectl get nodes -o wide
```

Résultat attendu :

```text
wendev-local-control-plane   Ready
wendev-local-worker          Ready
wendev-local-worker2         Ready
```

Phrase à dire :

> Ici, on voit que le cluster contient un nœud Control Plane et deux worker nodes. Le Control Plane gère l'orchestration, tandis que les worker nodes exécutent les Pods applicatifs.

Point à expliquer :

- le Control Plane prend les décisions ;
- les workers exécutent les conteneurs ;
- cette architecture permet de répartir l'application sur plusieurs nœuds.

## 2. Présenter les composants déployés

Commande :

```powershell
kubectl get deploy -n wendev -o wide
```

Résultat attendu :

```text
backend-api   3/3
frontend      2/2
```

Phrase à dire :

> Dans le Namespace `wendev`, le backend est actuellement exécuté avec trois replicas et le frontend avec deux replicas. Cela permet d'avoir plusieurs instances de l'application au lieu d'un seul serveur applicatif.

Commande :

```powershell
kubectl get pods -n wendev -o wide
```

Phrase à dire :

> Avec l'option `-o wide`, on voit aussi sur quel worker node chaque Pod est placé. Les Pods frontend et backend sont répartis sur les worker nodes, ce qui illustre la redondance applicative.

## 3. Présenter les Services

Commande :

```powershell
kubectl get svc -n wendev
```

Résultat attendu :

```text
backend-api   ClusterIP   3000/TCP
frontend      ClusterIP   80/TCP
postgres      ClusterIP   5432/TCP
```

Phrase à dire :

> Les Pods peuvent être recréés avec de nouvelles adresses IP. Les Services Kubernetes fournissent donc des points d'accès stables. Le frontend contacte le Service backend, et le backend contacte le Service PostgreSQL.

Point à expliquer :

- `ClusterIP` signifie accès interne au cluster ;
- le Service fait du load balancing interne entre les Pods disponibles ;
- l'utilisateur ne contacte pas directement les Pods.

## 4. Présenter l'Ingress

Commande :

```powershell
kubectl get ingress -n wendev
```

Résultat attendu :

```text
wendev-tickets   nginx   localhost   80
```

Phrase à dire :

> L'Ingress est le point d'entrée HTTP de l'application. Il route les requêtes `/` vers le frontend et les requêtes `/api` vers le backend.

Commande :

```powershell
curl.exe http://127.0.0.1:8080/health
curl.exe http://127.0.0.1:8080/api/health
```

Phrase à dire :

> Ces deux tests montrent que l'accès externe fonctionne via l'Ingress et que le backend communique correctement avec PostgreSQL.

## 5. Montrer l'application dans le navigateur

Action :

Ouvrir :

```text
http://127.0.0.1:8080
```

Créer un ticket de test, par exemple :

```text
Titre : Test soutenance Kubernetes
Description : Ticket créé pendant la démonstration pour valider le chemin frontend, backend et base de données.
Priorité : Haute
```

Phrase à dire :

> Cette action valide le chemin complet : navigateur, Ingress, frontend, backend API et PostgreSQL. L'application n'est pas seulement déployée, elle est réellement fonctionnelle.

## 6. Démontrer l'auto-réparation

Commande pour afficher les Pods :

```powershell
kubectl get pods -n wendev -o wide
```

Action :

Choisir un Pod dont le nom commence par `backend-api`.

Commande :

```powershell
kubectl delete pod <nom-du-pod-backend> -n wendev
```

Exemple :

```powershell
kubectl delete pod backend-api-54bbc88cd6-bz86r -n wendev
```

Commande de vérification :

```powershell
kubectl get pods -n wendev -o wide
```

Résultat attendu :

- l'ancien Pod passe en `Terminating` ;
- un nouveau Pod backend apparaît ;
- le Deployment revient à l'état désiré.

Test de disponibilité :

```powershell
curl.exe http://127.0.0.1:8080/api/health
```

Phrase à dire :

> Je viens de supprimer volontairement un Pod backend. Kubernetes détecte que le nombre de replicas réel ne correspond plus à l'état désiré du Deployment, donc il recrée automatiquement un nouveau Pod. Pendant ce temps, l'application reste accessible grâce aux autres replicas et au Service Kubernetes.

Point important :

> Ce test démontre l'auto-réparation, qui est un des apports majeurs de Kubernetes par rapport à une installation classique sur un serveur unique.

## 7. Démontrer le scaling manuel

Réduire le backend à deux replicas :

```powershell
kubectl scale deployment backend-api -n wendev --replicas=2
kubectl get deploy backend-api -n wendev -o wide
kubectl get pods -n wendev -o wide
```

Phrase à dire :

> Ici, je demande à Kubernetes de passer le backend de trois replicas à deux. Kubernetes supprime donc un Pod backend pour atteindre l'état demandé.

Vérifier que l'application répond encore :

```powershell
curl.exe http://127.0.0.1:8080/api/health
```

Remettre trois replicas :

```powershell
kubectl scale deployment backend-api -n wendev --replicas=3
kubectl rollout status deployment/backend-api -n wendev --timeout=120s
kubectl get deploy backend-api -n wendev -o wide
kubectl get pods -n wendev -o wide
```

Phrase à dire :

> Maintenant je remets trois replicas. Kubernetes crée un nouveau Pod backend et attend qu'il soit disponible. Le scaling permet donc d'adapter rapidement la capacité de l'application.

## 8. Conclusion orale de la démonstration

Phrase de conclusion :

> Cette démonstration montre que l'application Wendev Tickets est conteneurisée et orchestrée par Kubernetes. Elle est exposée via Ingress, répartie sur plusieurs Pods, accessible depuis le navigateur, et capable de continuer à fonctionner lorsqu'un Pod backend est supprimé. Kubernetes apporte donc la redondance, l'auto-réparation, le scaling et une meilleure automatisation du déploiement.

## 9. Questions probables du professeur

### Pourquoi utiliser Kubernetes au lieu de Docker seul ?

Réponse :

> Docker permet de créer et lancer des conteneurs, mais il ne suffit pas pour gérer automatiquement un grand nombre de conteneurs. Kubernetes ajoute l'orchestration : replicas, Services, auto-réparation, scaling, rolling update et exposition.

### Pourquoi utiliser un Ingress ?

Réponse :

> L'Ingress permet d'exposer l'application HTTP à travers un point d'entrée central. Il peut router plusieurs chemins ou domaines vers différents Services Kubernetes.

### Est-ce que toute l'application est hautement disponible ?

Réponse :

> Dans cette démonstration, la haute disponibilité est montrée sur le frontend et le backend grâce aux replicas. PostgreSQL reste en une seule instance pour simplifier le projet local. En production, je recommanderais une base de données managée comme Azure Database for PostgreSQL ou une architecture PostgreSQL hautement disponible.

### Pourquoi faire un test local avant Azure ?

Réponse :

> Le test local permet de comprendre les objets Kubernetes et de maîtriser le déploiement sans dépendre directement du cloud. Une fois la solution validée localement, elle peut être portée vers AKS avec un LoadBalancer ou un Ingress Controller cloud.

### Quel est le rôle du Service Kubernetes ?

Réponse :

> Le Service fournit une adresse stable pour accéder à un groupe de Pods. Même si les Pods changent d'adresse IP, le Service continue à router le trafic vers les Pods disponibles.

## 10. Commandes de secours

Si l'application ne répond pas :

```powershell
kubectl get pods -n wendev -o wide
kubectl get pods -n ingress-nginx -o wide
kubectl get ingress -n wendev
curl.exe http://127.0.0.1:8080/api/health
```

Si le backend n'est pas à trois replicas :

```powershell
kubectl scale deployment backend-api -n wendev --replicas=3
kubectl rollout status deployment/backend-api -n wendev --timeout=120s
```

Si l'Ingress ne répond pas mais les Pods sont bons :

```powershell
kubectl port-forward -n wendev svc/frontend 8081:80
```

Puis tester :

```text
http://127.0.0.1:8081
```
