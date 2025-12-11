# Setup Guide

Complete setup instructions for the GoHighLevel Interview Todo Application.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

### Required Software

1. **Go 1.23 or later**
   ```bash
   go version
   # Should output: go version go1.23.x
   ```

2. **Node.js 20 or later**
   ```bash
   node --version
   # Should output: v20.x.x
   ```

3. **Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - **Enable Kubernetes** in Docker Desktop settings
   - Verify:
     ```bash
     docker --version
     kubectl version --client
     ```

4. **Protocol Buffers Tools**
   ```bash
   # Install buf
   brew install bufbuild/buf/buf
   
   # Verify
   buf --version
   ```

5. **Go Development Tools**
   ```bash
   # Install sqlc
   brew install sqlc
   
   # Install goose
   go install github.com/pressly/goose/v3/cmd/goose@latest
   
   # Verify
   sqlc version
   goose --version
   ```

### Alternative: Minikube

If you prefer Minikube over Docker Desktop:

```bash
# Install Minikube
brew install minikube

# Start Minikube
minikube start --driver=docker

# Configure kubectl to use Minikube
kubectl config use-context minikube
```

## 🔧 Setup Steps

### 1. Clone the Repository

```bash
cd ~/Desktop/Saurabh/Github
git clone <your-repo-url> lld-interview
cd lld-interview
```

### 2. Backend Setup

```bash
cd backend

# Make setup script executable
chmod +x setup.sh

# Run setup script (installs tools, generates code, starts DB)
./setup.sh

# The script will:
# - Install buf, sqlc, goose
# - Download Go dependencies
# - Generate protobuf code
# - Generate sqlc code
# - Start PostgreSQL with Docker Compose
# - Run database migrations
```

#### Manual Backend Setup (if needed)

If the script fails or you want to run steps manually:

```bash
# 1. Install dependencies
go mod download
go mod tidy

# 2. Generate protobuf code
buf generate

# 3. Generate sqlc code
sqlc generate

# 4. Start PostgreSQL
docker-compose up -d

# Wait a few seconds for PostgreSQL to start
sleep 5

# 5. Run migrations
make migrate-up

# 6. Test the backend
make run
```

#### Verify Backend

```bash
# In another terminal
curl http://localhost:8080/health
# Should return: OK
```

### 3. Frontend Setup

```bash
cd ../frontend

# Make setup script executable
chmod +x setup.sh

# Run setup script
./setup.sh

# The script will:
# - Install npm dependencies
# - Copy proto files from backend
# - Generate TypeScript ConnectRPC client code
```

#### Manual Frontend Setup (if needed)

```bash
# 1. Install dependencies
npm install

# 2. Copy proto files (if not already present)
cp -r ../backend/proto .

# 3. Generate TypeScript code
npx buf generate

# 4. Start development server
npm run dev
```

#### Verify Frontend

```bash
# Frontend should be available at:
open http://localhost:3000
```

### 4. Build Docker Images

Once backend and frontend are working locally, build Docker images for Kubernetes:

```bash
# Backend image
cd backend
docker build -t todo-backend:latest .

# Frontend image
cd ../frontend
docker build -t todo-frontend:latest .

# Verify images
docker images | grep todo
```

### 5. Setup Kubernetes

#### Option A: Docker Desktop Kubernetes

```bash
# Ensure Kubernetes is enabled in Docker Desktop
kubectl config use-context docker-desktop

# Verify cluster
kubectl cluster-info
```

#### Option B: Minikube

```bash
# Start Minikube
minikube start

# Configure environment to use Minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild images in Minikube
cd backend
docker build -t todo-backend:latest .

cd ../frontend
docker build -t todo-frontend:latest .
```

### 6. Deploy to Kubernetes

```bash
cd ../k8s

# Create namespace and deploy all resources
kubectl apply -f namespace.yaml
kubectl apply -f postgres-config.yaml
kubectl apply -f postgres.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml

# Or apply everything at once
kubectl apply -f .
```

#### Wait for Pods to be Ready

```bash
# Watch pods starting up
kubectl get pods -n todo-app -w

# You should see:
# NAME                        READY   STATUS    RESTARTS   AGE
# postgres-xxxxx              1/1     Running   0          30s
# backend-xxxxx               1/1     Running   0          25s
# frontend-xxxxx              1/1     Running   0          20s
```

Press `Ctrl+C` to stop watching.

### 7. Access the Application

#### Option A: Docker Desktop

```bash
# Frontend is exposed via NodePort
open http://localhost:30080
```

#### Option B: Minikube

```bash
# Get Minikube IP
minikube service frontend -n todo-app --url

# Open the URL in browser
open $(minikube service frontend -n todo-app --url)
```

#### Option C: Port Forwarding (works for both)

```bash
# Forward frontend port
kubectl port-forward -n todo-app service/frontend 3000:80

# Forward backend port (for direct testing)
kubectl port-forward -n todo-app service/backend 8080:8080

# Access:
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

## 🔍 Verification Checklist

Use this checklist to verify everything is working:

- [ ] **Go version** 1.23+ installed
- [ ] **Node.js version** 20+ installed
- [ ] **Docker** running and Kubernetes enabled
- [ ] **buf, sqlc, goose** installed
- [ ] **Backend**: `go mod download` successful
- [ ] **Backend**: Proto code generated (`gen/` directory exists)
- [ ] **Backend**: SQLC code generated (`.go` files in `internal/adapter/postgresql/sqlc/`)
- [ ] **Backend**: PostgreSQL running (`docker ps` shows postgres container)
- [ ] **Backend**: Migrations applied (no errors from `make migrate-up`)
- [ ] **Backend**: Server starts (`make run` works)
- [ ] **Backend**: Health check passes (`curl http://localhost:8080/health`)
- [ ] **Frontend**: Dependencies installed (`node_modules/` exists)
- [ ] **Frontend**: TypeScript client generated (`src/gen/` exists)
- [ ] **Frontend**: Dev server runs (`npm run dev` works)
- [ ] **Frontend**: Page loads in browser
- [ ] **Docker Images**: Both images built (`docker images | grep todo`)
- [ ] **Kubernetes**: Cluster accessible (`kubectl cluster-info`)
- [ ] **Kubernetes**: All pods running (`kubectl get pods -n todo-app`)
- [ ] **Kubernetes**: Frontend accessible (browser or port-forward)
- [ ] **End-to-End**: Can create, read, update, delete todos in UI

## 🐛 Troubleshooting

### Backend Issues

**Problem**: `go mod download` fails
```bash
# Solution: Clean cache and retry
go clean -modcache
go mod download
```

**Problem**: `buf generate` fails
```bash
# Solution: Ensure buf is installed correctly
buf --version
brew reinstall bufbuild/buf/buf
```

**Problem**: PostgreSQL connection fails
```bash
# Solution: Check if PostgreSQL is running
docker ps | grep postgres

# Restart PostgreSQL
docker-compose down
docker-compose up -d

# Check logs
docker logs ecom-postgres
```

**Problem**: Migration fails
```bash
# Solution: Reset database
docker-compose down -v
docker-compose up -d
sleep 5
make migrate-up
```

### Frontend Issues

**Problem**: `npm install` fails
```bash
# Solution: Clear cache and retry
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

**Problem**: TypeScript client not generated
```bash
# Solution: Ensure proto files are present
ls proto/todo/v1/todo.proto

# Copy if missing
cp -r ../backend/proto .

# Regenerate
npx buf generate
```

**Problem**: Cannot connect to backend
```bash
# Solution: Check .env file
cat .env
# Should have: VITE_BACKEND_URL=http://localhost:8080

# If missing, copy from example
cp .env.example .env
```

### Kubernetes Issues

**Problem**: Pods not starting
```bash
# Check pod status
kubectl describe pod -n todo-app <pod-name>

# Check logs
kubectl logs -n todo-app <pod-name>
```

**Problem**: Image pull errors
```bash
# If using Docker Desktop:
# Images should be available locally, use imagePullPolicy: Never

# If using Minikube:
# Rebuild images in Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t todo-backend:latest backend/
docker build -t todo-frontend:latest frontend/
```

**Problem**: Backend can't connect to PostgreSQL
```bash
# Check if postgres service is running
kubectl get svc -n todo-app

# Check postgres pod logs
kubectl logs -n todo-app -l app=postgres

# Verify DNS resolution
kubectl run -n todo-app -it --rm debug --image=busybox --restart=Never -- nslookup postgres
```

### General Issues

**Problem**: Port already in use
```bash
# Find process using port
lsof -i :8080  # or :3000

# Kill process
kill -9 <PID>
```

**Problem**: Need to start fresh
```bash
# Complete cleanup
docker-compose down -v
kubectl delete namespace todo-app
rm -rf backend/gen frontend/src/gen

# Then run setup again
```

## 🎯 Next Steps

Once setup is complete:

1. **Test the Application**: Create some todos, mark them complete, delete them
2. **Review the Code**: Understand how ConnectRPC works
3. **Practice Deployment**: Delete and redeploy to Kubernetes
4. **Read Interview Prep**: Go through [INTERVIEW_PREP.md](./INTERVIEW_PREP.md)

## 📞 Need Help?

If you encounter issues not covered here:

1. Check pod logs: `kubectl logs -n todo-app <pod-name>`
2. Check events: `kubectl get events -n todo-app`
3. Review the [DEPLOYMENT.md](./DEPLOYMENT.md) guide
4. Ensure all prerequisites are correctly installed

---

**Ready for the interview!** 🚀
