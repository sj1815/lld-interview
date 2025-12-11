# GoHighLevel Interview Preparation - Todo App

A full-stack Todo application built with **Go (ConnectRPC)** backend, **Vue.js** frontend, and **PostgreSQL** database, fully containerized and deployable on **Kubernetes**.

## 🎯 Project Overview

This project demonstrates a production-ready, cloud-native application architecture suitable for the GoHighLevel interview process. It showcases:

- **Backend**: Go with ConnectRPC, PostgreSQL, SQLC, and Goose migrations
- **Frontend**: Vue 3 with ConnectRPC client
- **Database**: PostgreSQL 16
- **Infrastructure**: Docker and Kubernetes (local setup)
- **API Protocol**: ConnectRPC (gRPC-compatible HTTP/2)

## 🏗️ Architecture

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│             │         │              │         │              │
│   Vue.js    │────────▶│  Go Backend  │────────▶│  PostgreSQL  │
│  Frontend   │ Connect │   (gRPC)     │  SQLC   │   Database   │
│             │   RPC   │              │         │              │
└─────────────┘         └──────────────┘         └──────────────┘
      │                        │                         │
      │                        │                         │
   Port 3000              Port 8080                  Port 5432
   (NodePort)             (ClusterIP)               (ClusterIP)
```

## 📁 Project Structure

```
lld-interview/
├── backend/                    # Go backend service
│   ├── cmd/                   # Application entry points
│   ├── internal/              # Internal packages
│   │   ├── adapter/          # Database adapters
│   │   │   └── postgresql/   # PostgreSQL implementation
│   │   │       ├── migrations/ # Goose migrations
│   │   │       └── sqlc/     # SQLC queries & generated code
│   │   ├── env/              # Environment configuration
│   │   └── implementation/   # Business logic & handlers
│   ├── proto/                # Protobuf definitions
│   ├── Dockerfile            # Backend container image
│   ├── Makefile              # Build automation
│   └── setup.sh              # Backend setup script
│
├── frontend/                  # Vue.js frontend
│   ├── src/                  # Source code
│   │   ├── gen/             # Generated ConnectRPC client
│   │   ├── App.vue          # Main component
│   │   ├── client.js        # ConnectRPC client setup
│   │   └── main.js          # Application entry
│   ├── proto/               # Protobuf definitions (copied)
│   ├── Dockerfile           # Frontend container image
│   └── setup.sh             # Frontend setup script
│
├── k8s/                      # Kubernetes manifests
│   ├── namespace.yaml        # Namespace definition
│   ├── postgres-config.yaml  # PostgreSQL config
│   ├── postgres.yaml         # PostgreSQL deployment
│   ├── backend.yaml          # Backend deployment
│   └── frontend.yaml         # Frontend deployment
│
└── docs/                     # Documentation
    ├── SETUP.md             # Setup instructions
    ├── DEPLOYMENT.md        # Deployment guide
    └── INTERVIEW_PREP.md    # Interview preparation guide
```

## 🚀 Quick Start

### Prerequisites

- **Go 1.23+**
- **Node.js 20+**
- **Docker Desktop** (with Kubernetes enabled) or **Minikube**
- **kubectl** CLI tool
- **buf** (Protocol Buffers tool)
- **sqlc** (SQL code generator)
- **goose** (Database migration tool)

### Installation

See [SETUP.md](./SETUP.md) for detailed setup instructions.

### Quick Commands

```bash
# Backend
cd backend
chmod +x setup.sh
./setup.sh
make run

# Frontend
cd frontend
chmod +x setup.sh
./setup.sh
npm run dev

# Kubernetes
kubectl apply -f k8s/
```

## 🎓 Interview Preparation

This project is specifically designed for the GoHighLevel interview. Key highlights:

### ✅ What's Prepared

1. **Full-Stack Application**
   - Working Go backend with ConnectRPC
   - Vue.js frontend with generated client
   - End-to-end communication established

2. **Local Kubernetes Cluster**
   - All services containerized
   - Deployments and Services configured
   - Health checks and probes implemented

3. **Database Management**
   - PostgreSQL with migrations (Goose)
   - Type-safe queries (SQLC)
   - Schema-first development

4. **Development Workflow**
   - Fast rebuild and redeploy
   - Easy debugging with logs
   - Port-forwarding ready

### 🎯 During the Interview

You'll be well-prepared to:

- **Extend the application** with new features
- **Add new RPC endpoints** quickly
- **Modify Kubernetes deployments** confidently
- **Debug issues** using kubectl and logs
- **Explain architectural decisions** clearly

See [INTERVIEW_PREP.md](./INTERVIEW_PREP.md) for detailed interview tips.

## 🧪 Testing the Application

### Local Development

```bash
# Backend (http://localhost:8080)
curl http://localhost:8080/health

# Frontend (http://localhost:3000)
open http://localhost:3000
```

### Kubernetes

```bash
# Check all pods are running
kubectl get pods -n todo-app

# Access frontend
kubectl port-forward -n todo-app service/frontend 3000:80

# Access backend directly
kubectl port-forward -n todo-app service/backend 8080:8080
```

## 📚 API Endpoints

### Todo Service (ConnectRPC)

- `CreateTodo(CreateTodoRequest) → CreateTodoResponse`
- `GetTodo(GetTodoRequest) → GetTodoResponse`
- `ListTodos(ListTodosRequest) → ListTodosResponse`
- `UpdateTodo(UpdateTodoRequest) → UpdateTodoResponse`
- `DeleteTodo(DeleteTodoRequest) → DeleteTodoResponse`

### Health Check

- `GET /health` - Returns 200 OK when service is healthy

## 🛠️ Technologies Used

### Backend
- **Go 1.23** - Programming language
- **ConnectRPC** - RPC framework (gRPC-compatible)
- **PostgreSQL** - Database
- **SQLC** - Type-safe SQL code generator
- **Goose** - Database migrations
- **pgx/v5** - PostgreSQL driver

### Frontend
- **Vue 3** - JavaScript framework
- **Vite** - Build tool
- **ConnectRPC Web** - TypeScript client
- **Buf** - Protocol Buffers tooling

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **Nginx** - Frontend web server

## 🤝 Contributing

This is an interview preparation project. Feel free to:
- Extend functionality
- Add tests
- Improve documentation
- Experiment with features

## 📝 License

This project is created for interview purposes.

## 👤 Author

**Saurabh Jain**
- GitHub: [@saurabhj](https://github.com/saurabhj)

---

**Good luck with your GoHighLevel interview! 🚀**
