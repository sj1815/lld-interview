# Deployment Guide

Comprehensive guide for deploying and managing the Todo application on Kubernetes.

## 🎯 Overview

This guide covers:
- Building and deploying to Kubernetes
- Managing deployments during the interview
- Quick rebuild and redeploy workflows
- Debugging and monitoring

## 🏗️ Deployment Architecture

```
Kubernetes Cluster (todo-app namespace)
├── PostgreSQL Pod (StatefulSet-like with PVC)
│   └── Service: postgres:5432 (ClusterIP)
├── Backend Pod (Go + ConnectRPC)
│   └── Service: backend:8080 (ClusterIP)
└── Frontend Pod (Vue + Nginx)
    └── Service: frontend:80 (NodePort 30080)
```

## 📦 Initial Deployment

### Step 1: Ensure Kubernetes is Running

```bash
# Verify cluster
kubectl cluster-info

# Should show:
# Kubernetes control plane is running at https://...
```

### Step 2: Build Docker Images

```bash
# Backend
cd backend
docker build -t todo-backend:latest .

# Frontend  
cd ../frontend
docker build -t todo-frontend:latest .

# Verify images exist
docker images | grep todo
```

### Step 3: Apply Kubernetes Manifests

```bash
cd ../k8s

# Apply in order (for dependencies)
kubectl apply -f namespace.yaml
kubectl apply -f postgres-config.yaml
kubectl apply -f postgres.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n todo-app --timeout=60s

# Deploy backend
kubectl apply -f backend.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n todo-app --timeout=60s

# Deploy frontend
kubectl apply -f frontend.yaml
```

### Step 4: Verify Deployment

```bash
# Check all resources
kubectl get all -n todo-app

# Check pods are running
kubectl get pods -n todo-app

# Expected output:
# NAME                        READY   STATUS    RESTARTS   AGE
# postgres-xxxxx              1/1     Running   0          2m
# backend-xxxxx               1/1     Running   0          1m
# frontend-xxxxx              1/1     Running   0          30s
```

## 🔄 Quick Rebuild & Redeploy Workflow

During the interview, you'll need to quickly iterate. Here's the fast workflow:

### For Backend Changes

```bash
cd backend

# 1. Make your code changes
# 2. Rebuild image with same tag
docker build -t todo-backend:latest .

# 3. Delete pod to force recreation (since imagePullPolicy: Never)
kubectl delete pod -n todo-app -l app=backend

# 4. Watch new pod start
kubectl get pods -n todo-app -w

# 5. Check logs if needed
kubectl logs -n todo-app -l app=backend -f
```

**One-liner for fast iteration:**
```bash
docker build -t todo-backend:latest . && kubectl delete pod -n todo-app -l app=backend
```

### For Frontend Changes

```bash
cd frontend

# 1. Make your code changes
# 2. Rebuild image
docker build -t todo-frontend:latest .

# 3. Delete pod to force recreation
kubectl delete pod -n todo-app -l app=frontend

# 4. Watch new pod start
kubectl get pods -n todo-app -w
```

**One-liner:**
```bash
docker build -t todo-frontend:latest . && kubectl delete pod -n todo-app -l app=frontend
```

### For Proto Changes (Both Backend & Frontend)

```bash
# 1. Edit proto file
vim backend/proto/todo/v1/todo.proto

# 2. Regenerate backend code
cd backend
buf generate
docker build -t todo-backend:latest .
kubectl delete pod -n todo-app -l app=backend

# 3. Copy proto to frontend and regenerate
cd ../frontend
cp -r ../backend/proto .
npx buf generate
docker build -t todo-frontend:latest .
kubectl delete pod -n todo-app -l app=frontend
```

### For Database Changes

```bash
cd backend

# 1. Create migration
make migrate-create name=add_new_table

# 2. Edit the migration file
vim internal/adapter/postgresql/migrations/<timestamp>_add_new_table.sql

# 3. Update queries if needed
vim internal/adapter/postgresql/sqlc/queries.sql

# 4. Regenerate sqlc code
sqlc generate

# 5. Rebuild and redeploy
docker build -t todo-backend:latest .
kubectl delete pod -n todo-app -l app=backend

# The init container will run migrations automatically
```

## 🔍 Monitoring & Debugging

### View Logs

```bash
# Tail backend logs
kubectl logs -n todo-app -l app=backend -f

# Tail frontend logs
kubectl logs -n todo-app -l app=frontend -f

# Tail postgres logs
kubectl logs -n todo-app -l app=postgres -f

# View specific pod logs
kubectl logs -n todo-app <pod-name> -f

# View previous pod logs (if crashed)
kubectl logs -n todo-app <pod-name> -p
```

### Port Forwarding for Testing

```bash
# Forward backend directly
kubectl port-forward -n todo-app svc/backend 8080:8080

# Test backend endpoints
curl http://localhost:8080/health

# Forward frontend
kubectl port-forward -n todo-app svc/frontend 3000:80

# Open in browser
open http://localhost:3000

# Forward postgres for direct queries
kubectl port-forward -n todo-app svc/postgres 5432:5432

# Connect with psql
psql postgresql://postgres:postgres@localhost:5432/ecom
```

### Exec into Pods

```bash
# Exec into backend pod
kubectl exec -it -n todo-app -l app=backend -- sh

# Inside pod:
# - Check files: ls -la
# - Test connectivity: wget http://postgres:5432
# - Check env vars: env | grep DATABASE

# Exec into postgres pod
kubectl exec -it -n todo-app -l app=postgres -- psql -U postgres -d ecom

# Inside postgres:
# - List tables: \dt
# - Query: SELECT * FROM todos;
# - Describe table: \d todos
```

### Check Resource Usage

```bash
# Get pod resource usage
kubectl top pods -n todo-app

# Describe pod for events and issues
kubectl describe pod -n todo-app <pod-name>

# Get events (useful for debugging)
kubectl get events -n todo-app --sort-by='.lastTimestamp'
```

### Health Checks

```bash
# Check if health checks are passing
kubectl get pods -n todo-app -o wide

# Describe pod to see probe status
kubectl describe pod -n todo-app -l app=backend | grep -A 10 "Readiness"
```

## 🛠️ Common Interview Scenarios

### Scenario 1: Add a New RPC Endpoint

```bash
# 1. Update proto file
vim backend/proto/todo/v1/todo.proto
# Add: rpc GetStats(GetStatsRequest) returns (GetStatsResponse) {}

# 2. Regenerate code
cd backend
buf generate

# 3. Implement handler
vim internal/implementation/handler.go
# Add GetStats method

# 4. Implement service logic
vim internal/implementation/service.go

# 5. Rebuild and deploy
docker build -t todo-backend:latest .
kubectl delete pod -n todo-app -l app=backend

# 6. Update frontend
cd ../frontend
cp -r ../backend/proto .
npx buf generate
# Update UI to call new endpoint
vim src/App.vue

# 7. Rebuild frontend
docker build -t todo-frontend:latest .
kubectl delete pod -n todo-app -l app=frontend
```

### Scenario 2: Add Database Field

```bash
# 1. Create migration
cd backend
make migrate-create name=add_priority_field

# 2. Edit migration
vim internal/adapter/postgresql/migrations/<new>.sql
# Add: ALTER TABLE todos ADD COLUMN priority INT DEFAULT 0;

# 3. Update queries
vim internal/adapter/postgresql/sqlc/queries.sql
# Update queries to include priority

# 4. Regenerate sqlc
sqlc generate

# 5. Update proto
vim proto/todo/v1/todo.proto
# Add: int32 priority = 7;

# 6. Regenerate proto
buf generate

# 7. Update service layer
vim internal/implementation/service.go
# Handle priority field

# 8. Rebuild and deploy
docker build -t todo-backend:latest .
kubectl delete pod -n todo-app -l app=backend

# Migration runs automatically in init container
```

### Scenario 3: Debug Connection Issue

```bash
# 1. Check pod status
kubectl get pods -n todo-app

# 2. Check backend logs
kubectl logs -n todo-app -l app=backend

# 3. Check if backend can reach postgres
kubectl exec -n todo-app -l app=backend -- nc -zv postgres 5432

# 4. Check postgres is ready
kubectl exec -n todo-app -l app=postgres -- pg_isready

# 5. Check service endpoints
kubectl get endpoints -n todo-app

# 6. Check configmap
kubectl get configmap -n todo-app backend-config -o yaml

# 7. Verify DNS resolution
kubectl run -n todo-app -it --rm debug --image=busybox --restart=Never -- nslookup postgres
```

### Scenario 4: Scale Backend

```bash
# Scale to multiple replicas
kubectl scale deployment backend -n todo-app --replicas=3

# Watch pods come up
kubectl get pods -n todo-app -w

# Check distribution
kubectl get pods -n todo-app -o wide

# Test load balancing
for i in {1..10}; do
  kubectl exec -n todo-app -l app=frontend -- wget -qO- http://backend:8080/health
done
```

## 📊 Useful Commands Reference

### Quick Status Check

```bash
# Everything in one view
kubectl get all -n todo-app

# Just pods with more details
kubectl get pods -n todo-app -o wide

# Watch for changes
kubectl get pods -n todo-app -w
```

### Complete Teardown

```bash
# Delete everything
kubectl delete namespace todo-app

# Or delete resources individually
kubectl delete -f k8s/
```

### Fresh Start

```bash
# 1. Delete namespace
kubectl delete namespace todo-app

# 2. Rebuild images
docker build -t todo-backend:latest backend/
docker build -t todo-frontend:latest frontend/

# 3. Redeploy
kubectl apply -f k8s/

# 4. Wait for ready
kubectl wait --for=condition=ready pod --all -n todo-app --timeout=120s
```

### Update ConfigMap

```bash
# Edit configmap
kubectl edit configmap backend-config -n todo-app

# Or apply new version
kubectl apply -f k8s/backend-config.yaml

# Restart pods to pick up changes
kubectl rollout restart deployment backend -n todo-app
```

## 🎯 Pre-Interview Checklist

Practice these before the interview:

- [ ] Build and deploy from scratch (time yourself)
- [ ] Add a simple RPC endpoint and deploy
- [ ] Create a migration and deploy
- [ ] Debug a connection issue
- [ ] View logs of different pods
- [ ] Port-forward and test manually
- [ ] Scale deployment up and down
- [ ] Complete teardown and redeploy
- [ ] Modify frontend component and redeploy
- [ ] Test end-to-end flow after deployment

## 💡 Tips for Interview

1. **Keep terminals organized**: 
   - Terminal 1: Backend development
   - Terminal 2: Frontend development
   - Terminal 3: kubectl commands and logs
   - Terminal 4: Port forwarding

2. **Use aliases**:
   ```bash
   alias k='kubectl'
   alias kgp='kubectl get pods -n todo-app'
   alias klf='kubectl logs -n todo-app -f'
   alias kpf='kubectl port-forward -n todo-app'
   ```

3. **Watch mode is your friend**:
   ```bash
   kubectl get pods -n todo-app -w
   ```

4. **Keep logs open**:
   ```bash
   kubectl logs -n todo-app -l app=backend -f | tee backend.log
   ```

5. **Quick health check**:
   ```bash
   kubectl get pods -n todo-app && \
   kubectl logs -n todo-app -l app=backend --tail=10
   ```

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Pod stuck in `ImagePullBackOff` | Verify image exists: `docker images \| grep todo` |
| Pod stuck in `CrashLoopBackOff` | Check logs: `kubectl logs -n todo-app <pod>` |
| Backend can't connect to DB | Check postgres pod is ready: `kubectl get pods -n todo-app` |
| Frontend can't reach backend | Check service: `kubectl get svc -n todo-app` |
| Migrations not running | Check init container logs: `kubectl logs -n todo-app <pod> -c run-migrations` |
| Changes not reflected | Ensure you rebuilt image and deleted pod |

---

**You're ready to deploy! 🚀**
