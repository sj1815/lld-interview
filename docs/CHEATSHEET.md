# Quick Reference Cheat Sheet

One-page reference for the GoHighLevel interview.

## 🚀 Quick Commands

### Setup & Run Locally
```bash
# Complete setup
./setup.sh

# Backend
cd backend && make run

# Frontend
cd frontend && npm run dev
```

### Code Generation
```bash
# Backend proto
cd backend && buf generate

# Backend SQL
cd backend && sqlc generate

# Frontend proto
cd frontend && npx buf generate
```

### Docker
```bash
# Build images
docker build -t todo-backend:latest backend/
docker build -t todo-frontend:latest frontend/

# Quick rebuild & redeploy
docker build -t todo-backend:latest backend/ && kubectl delete pod -n todo-app -l app=backend
docker build -t todo-frontend:latest frontend/ && kubectl delete pod -n todo-app -l app=frontend
```

### Kubernetes
```bash
# Deploy
kubectl apply -f k8s/

# Status
kubectl get pods -n todo-app
kubectl get all -n todo-app

# Logs
kubectl logs -n todo-app -l app=backend -f
kubectl logs -n todo-app -l app=frontend -f

# Port Forward
kubectl port-forward -n todo-app svc/backend 8080:8080
kubectl port-forward -n todo-app svc/frontend 3000:80

# Debug
kubectl describe pod -n todo-app <pod-name>
kubectl exec -it -n todo-app -l app=backend -- sh
kubectl get events -n todo-app --sort-by='.lastTimestamp'

# Cleanup
kubectl delete namespace todo-app
```

### Database Migrations
```bash
# Create migration
cd backend && make migrate-create name=add_field

# Run migrations (local)
make migrate-up

# Rollback
make migrate-down

# Migrations run automatically in k8s init container
```

## 📝 File Locations

### Proto Definitions
```
backend/proto/todo/v1/todo.proto
frontend/proto/todo/v1/todo.proto  (copy of backend)
```

### Generated Code
```
backend/gen/proto/todo/v1/          (Go)
frontend/src/gen/proto/todo/v1/     (TypeScript)
```

### Database
```
backend/internal/adapter/postgresql/migrations/  (SQL migrations)
backend/internal/adapter/postgresql/sqlc/queries.sql
backend/internal/adapter/postgresql/sqlc/*.go    (Generated)
```

### Handlers & Services
```
backend/internal/implementation/handler.go   (RPC handlers)
backend/internal/implementation/service.go   (Business logic)
```

### Frontend
```
frontend/src/App.vue        (Main component)
frontend/src/client.js      (ConnectRPC setup)
frontend/src/style.css      (Styles)
```

### Kubernetes
```
k8s/namespace.yaml
k8s/postgres-config.yaml
k8s/postgres.yaml
k8s/backend.yaml
k8s/frontend.yaml
```

## 🔧 Common Tasks

### Add New RPC Endpoint
```bash
# 1. Edit proto
vim backend/proto/todo/v1/todo.proto

# 2. Regenerate
cd backend && buf generate

# 3. Implement handler
vim internal/implementation/handler.go

# 4. Implement service
vim internal/implementation/service.go

# 5. Redeploy
docker build -t todo-backend:latest . && kubectl delete pod -n todo-app -l app=backend
```

### Add Database Field
```bash
# 1. Create migration
cd backend && make migrate-create name=add_field

# 2. Edit migration
vim internal/adapter/postgresql/migrations/<new>.sql

# 3. Update queries
vim internal/adapter/postgresql/sqlc/queries.sql

# 4. Regenerate SQLC
sqlc generate

# 5. Update proto (if needed)
vim proto/todo/v1/todo.proto && buf generate

# 6. Redeploy (migrations run automatically)
docker build -t todo-backend:latest . && kubectl delete pod -n todo-app -l app=backend
```

### Update Frontend
```bash
# 1. Edit component
vim frontend/src/App.vue

# 2. Rebuild & redeploy
cd frontend
docker build -t todo-frontend:latest . && kubectl delete pod -n todo-app -l app=frontend
```

## 🐛 Debugging

### Check Pod Status
```bash
kubectl get pods -n todo-app
kubectl describe pod -n todo-app <pod-name>
kubectl logs -n todo-app <pod-name>
```

### Test Connectivity
```bash
# Backend to Postgres
kubectl exec -n todo-app -l app=backend -- nc -zv postgres 5432

# Frontend to Backend
kubectl exec -n todo-app -l app=frontend -- wget -qO- http://backend:8080/health

# Direct test
kubectl port-forward -n todo-app svc/backend 8080:8080
curl http://localhost:8080/health
```

### View Database
```bash
# Port forward
kubectl port-forward -n todo-app svc/postgres 5432:5432

# Connect
psql postgresql://postgres:postgres@localhost:5432/ecom

# Inside psql:
\dt                    # List tables
\d todos               # Describe table
SELECT * FROM todos;   # Query
```

## 📋 Interview Checklist

### Before Interview
- [ ] Run `./setup.sh` and verify everything works
- [ ] Deploy to Kubernetes and test
- [ ] Practice adding an RPC endpoint
- [ ] Practice creating a migration
- [ ] Review proto syntax
- [ ] Review SQLC query syntax
- [ ] Have multiple terminals ready

### During Interview
- [ ] Share screen showing working app
- [ ] Keep terminals organized (backend, frontend, kubectl)
- [ ] Think aloud while coding
- [ ] Ask clarifying questions
- [ ] Test incrementally
- [ ] Use kubectl logs for debugging
- [ ] Explain AI usage when using it

## 🎯 Key Concepts

### ConnectRPC
- gRPC-compatible RPC over HTTP/2
- Type-safe APIs from proto definitions
- Auto-generated clients
- Works in browsers without grpc-web proxy

### SQLC
- Generates type-safe Go from SQL
- No ORM overhead
- Compile-time safety
- `queries.sql` → `*.go` files

### Goose
- Database migrations
- Version control for schema
- Up/down migrations
- Init container runs migrations in k8s

### Kubernetes
- **Pod**: Container runtime
- **Deployment**: Manages pods
- **Service**: Network endpoint
- **ConfigMap**: Configuration
- **InitContainer**: Pre-start tasks

## 💡 Pro Tips

1. **Terminal Layout**
   ```
   ┌─────────────┬─────────────┐
   │  Backend    │  Frontend   │
   │  Dev/Build  │  Dev/Build  │
   ├─────────────┴─────────────┤
   │  kubectl & logs           │
   └───────────────────────────┘
   ```

2. **Useful Aliases**
   ```bash
   alias k='kubectl'
   alias kgp='kubectl get pods -n todo-app'
   alias klf='kubectl logs -n todo-app -f'
   ```

3. **Watch Mode**
   ```bash
   watch -n 1 'kubectl get pods -n todo-app'
   ```

4. **Quick Health Check**
   ```bash
   kubectl get pods -n todo-app && \
   kubectl logs -n todo-app -l app=backend --tail=5
   ```

## 🚨 Common Errors

| Error | Solution |
|-------|----------|
| `ImagePullBackOff` | Image not built: `docker images \| grep todo` |
| `CrashLoopBackOff` | Check logs: `kubectl logs -n todo-app <pod>` |
| Connection refused | Check if target pod is ready |
| Migration failed | Check postgres logs, verify connection string |
| CORS error | Verify CORS middleware in `cmd/api.go` |
| Proto not found | Run `buf generate` in both backend and frontend |

## 📞 Help Resources

- ConnectRPC: https://connectrpc.com/docs/
- SQLC: https://docs.sqlc.dev/
- Vue 3: https://vuejs.org/
- kubectl: https://kubernetes.io/docs/reference/kubectl/

## 🎉 You Got This!

- Stay calm and think aloud
- Ask questions when unclear
- Use AI for boilerplate, not architecture
- Test incrementally
- Debug systematically
- Be collaborative

**Remember: They want you to succeed! 🚀**
