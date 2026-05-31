# Captures texte phase 4 - Kubernetes local

Date de capture : 31 mai 2026

## 1. Nœuds du cluster

Commande :

```bash
kubectl get nodes -o wide
```

Sortie :

```text
NAME                         STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                      CONTAINER-RUNTIME
wendev-local-control-plane   Ready    control-plane   6h16m   v1.35.0   172.18.0.4    <none>        Debian GNU/Linux 12 (bookworm)   6.6.114.1-microsoft-standard-WSL2   containerd://2.2.0
wendev-local-worker          Ready    <none>          6h16m   v1.35.0   172.18.0.3    <none>        Debian GNU/Linux 12 (bookworm)   6.6.114.1-microsoft-standard-WSL2   containerd://2.2.0
wendev-local-worker2         Ready    <none>          6h16m   v1.35.0   172.18.0.2    <none>        Debian GNU/Linux 12 (bookworm)   6.6.114.1-microsoft-standard-WSL2   containerd://2.2.0
```

Interprétation :

Le cluster local est opérationnel. Il contient un nœud Control Plane et deux worker nodes, ce qui permet de démontrer la séparation entre la gestion du cluster et l'exécution des Pods applicatifs.

## 2. Pods applicatifs

Commande :

```bash
kubectl get pods -n wendev -o wide
```

Sortie :

```text
NAME                           READY   STATUS    RESTARTS       AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
backend-api-54bbc88cd6-fbr4s   1/1     Running   0              6h4m    10.244.2.5   wendev-local-worker2   <none>           <none>
backend-api-54bbc88cd6-t9x7j   1/1     Running   0              6h5m    10.244.2.4   wendev-local-worker2   <none>           <none>
backend-api-54bbc88cd6-x2sdf   1/1     Running   2 (6h9m ago)   6h10m   10.244.1.2   wendev-local-worker    <none>           <none>
frontend-9647fcd54-5bqrc       1/1     Running   0              6h10m   10.244.1.4   wendev-local-worker    <none>           <none>
frontend-9647fcd54-98ggf       1/1     Running   0              6h10m   10.244.2.3   wendev-local-worker2   <none>           <none>
postgres-0                     1/1     Running   0              6h10m   10.244.1.5   wendev-local-worker    <none>           <none>
```

Interprétation :

Les Pods backend et frontend sont en état `Running`. Les replicas sont répartis sur les deux worker nodes, ce qui permet de démontrer la redondance applicative.

## 3. Services applicatifs

Commande :

```bash
kubectl get svc -n wendev
```

Sortie :

```text
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
backend-api   ClusterIP   10.96.113.150   <none>        3000/TCP   6h10m
frontend      ClusterIP   10.96.106.154   <none>        80/TCP     6h10m
postgres      ClusterIP   10.96.234.193   <none>        5432/TCP   6h10m
```

Interprétation :

Les Services de type `ClusterIP` donnent des points d'accès internes stables au frontend, au backend et à PostgreSQL.

## 4. Ingress applicatif

Commande :

```bash
kubectl get ingress -n wendev
```

Sortie :

```text
NAME             CLASS   HOSTS   ADDRESS     PORTS   AGE
wendev-tickets   nginx   *       localhost   80      6h21m
```

Interprétation :

La règle Ingress `wendev-tickets` route le trafic HTTP vers les Services Kubernetes de l'application.

## 5. Contrôleur Ingress NGINX

Le téléchargement direct depuis `raw.githubusercontent.com` a échoué à cause d'un problème DNS local :

```text
Unable to connect to the server: dial tcp: lookup raw.githubusercontent.com: no such host
```

Le contrôleur a été installé depuis le miroir jsDelivr :

```bash
kubectl apply -f https://cdn.jsdelivr.net/gh/kubernetes/ingress-nginx@controller-v1.15.1/deploy/static/provider/kind/deploy.yaml
```

Le nœud Control Plane a été étiqueté pour recevoir le contrôleur :

```bash
kubectl label node wendev-local-control-plane ingress-ready=true --overwrite
```

Le Deployment du contrôleur a été patché avec :

```bash
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type merge --patch-file infra/kind/ingress-nginx-node-selector-patch.yaml
```

Vérification :

```bash
kubectl get pods -n ingress-nginx -o wide
```

Sortie :

```text
NAME                                        READY   STATUS    RESTARTS   AGE   IP           NODE                         NOMINATED NODE   READINESS GATES
ingress-nginx-controller-5856d4bfd7-p4fkm   1/1     Running   0          87s   10.244.0.5   wendev-local-control-plane   <none>           <none>
```

## 6. Test d'accès via Ingress

Grâce au mapping défini dans `infra/kind/kind-cluster.yaml`, le port 80 du nœud kind est exposé sur le port 8080 de la machine locale.

Test du frontend :

```bash
curl http://127.0.0.1:8080/health
```

Résultat :

```text
ok
```

Test du backend via Ingress :

```bash
curl http://127.0.0.1:8080/api/health
```

Résultat :

```json
{"status":"ok","service":"backend-api","hostname":"backend-api-54bbc88cd6-t9x7j","database":"connected","timestamp":"2026-05-31T10:26:07.443Z"}
```

Le champ `hostname` peut changer d'un appel à l'autre, car les requêtes sont distribuées vers les différents Pods backend disponibles.

Conclusion :

L'application est maintenant accessible localement via Ingress à l'adresse :

```text
http://127.0.0.1:8080
```

## 7. Test d'auto-réparation

Objectif :

Vérifier que Kubernetes recrée automatiquement un Pod backend supprimé et que l'application reste disponible pendant l'incident.

État avant suppression :

```bash
kubectl get deploy -n wendev -o wide
```

```text
NAME          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS    IMAGES                          SELECTOR
backend-api   3/3     3            3           6h24m   backend-api   wendev-tickets-backend:local    app.kubernetes.io/name=backend-api
frontend      2/2     2            2           6h24m   frontend      wendev-tickets-frontend:local   app.kubernetes.io/name=frontend
```

Pods avant suppression :

```bash
kubectl get pods -n wendev -o wide
```

```text
NAME                           READY   STATUS    RESTARTS        AGE     IP           NODE
backend-api-54bbc88cd6-fbr4s   1/1     Running   0               6h19m   10.244.2.5   wendev-local-worker2
backend-api-54bbc88cd6-t9x7j   1/1     Running   0               6h20m   10.244.2.4   wendev-local-worker2
backend-api-54bbc88cd6-x2sdf   1/1     Running   2 (6h23m ago)   6h24m   10.244.1.2   wendev-local-worker
frontend-9647fcd54-5bqrc       1/1     Running   0               6h24m   10.244.1.4   wendev-local-worker
frontend-9647fcd54-98ggf       1/1     Running   0               6h24m   10.244.2.3   wendev-local-worker2
postgres-0                     1/1     Running   0               6h24m   10.244.1.5   wendev-local-worker
```

Suppression contrôlée d'un Pod backend :

```bash
kubectl delete pod backend-api-54bbc88cd6-fbr4s -n wendev
```

Résultat :

```text
pod "backend-api-54bbc88cd6-fbr4s" deleted
```

État juste après suppression :

```bash
kubectl get pods -n wendev -o wide
```

```text
NAME                           READY   STATUS        RESTARTS        AGE     IP           NODE
backend-api-54bbc88cd6-5whk5   1/1     Running       0               17s     10.244.1.8   wendev-local-worker
backend-api-54bbc88cd6-fbr4s   1/1     Terminating   0               6h20m   10.244.2.5   wendev-local-worker2
backend-api-54bbc88cd6-t9x7j   1/1     Running       0               6h21m   10.244.2.4   wendev-local-worker2
backend-api-54bbc88cd6-x2sdf   1/1     Running       2 (6h24m ago)   6h25m   10.244.1.2   wendev-local-worker
```

Test de disponibilité pendant l'incident :

```bash
curl http://127.0.0.1:8080/api/health
```

```json
{"status":"ok","service":"backend-api","hostname":"backend-api-54bbc88cd6-x2sdf","database":"connected","timestamp":"2026-05-31T10:30:52.351Z"}
```

État final après recréation :

```bash
kubectl get pods -n wendev -o wide
```

```text
NAME                           READY   STATUS    RESTARTS        AGE     IP           NODE
backend-api-54bbc88cd6-5whk5   1/1     Running   0               39s     10.244.1.8   wendev-local-worker
backend-api-54bbc88cd6-t9x7j   1/1     Running   0               6h21m   10.244.2.4   wendev-local-worker2
backend-api-54bbc88cd6-x2sdf   1/1     Running   2 (6h25m ago)   6h26m   10.244.1.2   wendev-local-worker
frontend-9647fcd54-5bqrc       1/1     Running   0               6h26m   10.244.1.4   wendev-local-worker
frontend-9647fcd54-98ggf       1/1     Running   0               6h26m   10.244.2.3   wendev-local-worker2
postgres-0                     1/1     Running   0               6h26m   10.244.1.5   wendev-local-worker
```

Interprétation :

Kubernetes a détecté la disparition d'un Pod backend et a recréé automatiquement un nouveau Pod. L'application est restée disponible grâce aux autres replicas backend et au Service Kubernetes.

## 8. Test de scaling manuel

Objectif :

Vérifier que Kubernetes peut modifier le nombre de replicas backend sans changer le code de l'application.

Réduction du backend de trois à deux replicas :

```bash
kubectl scale deployment backend-api -n wendev --replicas=2
```

Résultat :

```text
deployment.apps/backend-api scaled
```

Vérification :

```bash
kubectl get deploy backend-api -n wendev -o wide
```

```text
NAME          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS    IMAGES                         SELECTOR
backend-api   2/2     2            2           6h27m   backend-api   wendev-tickets-backend:local   app.kubernetes.io/name=backend-api
```

Pendant cette réduction, un Pod excédentaire passe en `Terminating` :

```text
NAME                           READY   STATUS        RESTARTS        AGE     IP           NODE
backend-api-54bbc88cd6-5whk5   1/1     Terminating   0               2m5s    10.244.1.8   wendev-local-worker
backend-api-54bbc88cd6-t9x7j   1/1     Running       0               6h23m   10.244.2.4   wendev-local-worker2
backend-api-54bbc88cd6-x2sdf   1/1     Running       2 (6h26m ago)   6h27m   10.244.1.2   wendev-local-worker
```

Test de disponibilité après réduction :

```bash
curl http://127.0.0.1:8080/api/health
```

```json
{"status":"ok","service":"backend-api","hostname":"backend-api-54bbc88cd6-t9x7j","database":"connected","timestamp":"2026-05-31T10:32:40.321Z"}
```

Augmentation du backend vers trois replicas :

```bash
kubectl scale deployment backend-api -n wendev --replicas=3
```

Résultat :

```text
deployment.apps/backend-api scaled
```

Suivi du rollout :

```bash
kubectl rollout status deployment/backend-api -n wendev --timeout=120s
```

```text
Waiting for deployment "backend-api" rollout to finish: 2 of 3 updated replicas are available...
deployment "backend-api" successfully rolled out
```

État final :

```bash
kubectl get deploy backend-api -n wendev -o wide
```

```text
NAME          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS    IMAGES                         SELECTOR
backend-api   3/3     3            3           6h28m   backend-api   wendev-tickets-backend:local   app.kubernetes.io/name=backend-api
```

Pods backend après retour à trois replicas :

```text
NAME                           READY   STATUS    RESTARTS        AGE     IP           NODE
backend-api-54bbc88cd6-bz86r   1/1     Running   0               23s     10.244.2.7   wendev-local-worker2
backend-api-54bbc88cd6-t9x7j   1/1     Running   0               6h23m   10.244.2.4   wendev-local-worker2
backend-api-54bbc88cd6-x2sdf   1/1     Running   2 (6h27m ago)   6h28m   10.244.1.2   wendev-local-worker
```

Interprétation :

Le scaling manuel permet d'adapter rapidement le nombre d'instances backend selon le besoin. Kubernetes crée ou supprime les Pods nécessaires pour atteindre l'état demandé.
