# GoHighLevel Interview - Full Stack Todo Application

A production-ready, cloud-native Todo application built for the GoHighLevel technical interview. Features Go backend with ConnectRPC, Vue.js frontend, PostgreSQL database, and Kubernetes deployment.

## 🚀 Quick Start

```bash
# Prerequisites: Docker Desktop (with Kubernetes), Go 1.23+, Node.js 20+

# 1. Setup Backend
cd backend
chmod +x setup.sh
./setup.sh

# 2. Setup Frontend (in new terminal)
cd frontend
chmod +x setup.sh
./setup.sh

# 3. Test Locally
cd backend && make run          # Terminal 1
cd frontend && npm run dev      # Terminal 2

# Visit: http://localhost:3000

# 4. Deploy to Kubernetes
docker build -t todo-backend:latest backend/
docker build -t todo-frontend:latest frontend/
kubectl apply -f k8s/

# Visit: http://localhost:30080
```

## 📚 Documentation

- **[📖 README](docs/README.md)** - Complete project overview
- **[⚙️ SETUP](docs/SETUP.md)** - Detailed setup instructions
- **[🚢 DEPLOYMENT](docs/DEPLOYMENT.md)** - Kubernetes deployment guide
- **[🎯 INTERVIEW_PREP](docs/INTERVIEW_PREP.md)** - Interview preparation tips

## 🏗️ Tech Stack

### Backend
- **Go 1.23** with ConnectRPC
- **PostgreSQL** with SQLC & Goose
- **Protocol Buffers** for API definitions

### Frontend
- **Vue 3** with Composition API
- **ConnectRPC** TypeScript client
- **Vite** for build tooling

### Infrastructure
- **Docker** for containerization
- **Kubernetes** for orchestration
- **Nginx** for serving frontend

## 📁 Project Structure

```
lld-interview/
├── backend/          # Go backend with ConnectRPC
│   ├── cmd/         # Application entry points
│   ├── internal/    # Internal packages
│   ├── proto/       # Protobuf definitions
│   └── Dockerfile
├── frontend/        # Vue.js frontend
│   ├── src/        # Source code
│   ├── proto/      # Protobuf definitions
│   └── Dockerfile
├── k8s/            # Kubernetes manifests
│   ├── namespace.yaml
│   ├── postgres.yaml
│   ├── backend.yaml
│   └── frontend.yaml
└── docs/           # Documentation
    ├── README.md
    ├── SETUP.md
    ├── DEPLOYMENT.md
    └── INTERVIEW_PREP.md
```

## ✨ Features

- ✅ Full CRUD operations for todos
- ✅ ConnectRPC for type-safe APIs
- ✅ Type-safe database queries with SQLC
- ✅ Database migrations with Goose
- ✅ Containerized with Docker
- ✅ Kubernetes deployment ready
- ✅ Health checks and monitoring
- ✅ CORS enabled for frontend
- ✅ Responsive UI design

## 🎯 Interview Ready

This project is specifically designed for the GoHighLevel hands-on interview. It demonstrates:

- **Working Kubernetes Setup** - All services deployed and communicating
- **ConnectRPC Implementation** - Backend and frontend using gRPC-compatible APIs
- **Schema-First Development** - Proto definitions driving implementation
- **Quick Iteration** - Fast rebuild and redeploy workflows
- **Debugging Skills** - Logging, port-forwarding, and troubleshooting

## 📝 Quick Commands

```bash
# Backend Development
make proto          # Generate protobuf code
make sqlc           # Generate SQLC code
make migrate-up     # Run migrations
make run            # Start server

# Frontend Development
npm run dev         # Start dev server
npm run build       # Build for production
npm run proto       # Generate TypeScript client

# Kubernetes
kubectl get pods -n todo-app                    # Check pod status
kubectl logs -n todo-app -l app=backend -f      # View backend logs
kubectl port-forward -n todo-app svc/frontend 3000:80  # Access frontend
```

## 🔍 API Endpoints

### ConnectRPC Service

- `CreateTodo` - Create a new todo
- `GetTodo` - Retrieve a specific todo
- `ListTodos` - List all todos (paginated)
- `UpdateTodo` - Update an existing todo
- `DeleteTodo` - Delete a todo

### Health Check

- `GET /health` - Service health status

## 🛠️ Development Workflow

### Adding a New Feature

1. Update proto definition
2. Regenerate code (`buf generate`)
3. Implement backend logic
4. Update frontend UI
5. Rebuild Docker images
6. Redeploy to Kubernetes
7. Test end-to-end

### Quick Redeploy

```bash
# Backend
docker build -t todo-backend:latest backend/ && \
kubectl delete pod -n todo-app -l app=backend

# Frontend
docker build -t todo-frontend:latest frontend/ && \
kubectl delete pod -n todo-app -l app=frontend
```

## 🐛 Troubleshooting

**Pods not starting?**
```bash
kubectl describe pod -n todo-app <pod-name>
kubectl logs -n todo-app <pod-name>
```

**Can't connect to database?**
```bash
kubectl exec -n todo-app -l app=backend -- nc -zv postgres 5432
```

**Images not found?**
```bash
docker images | grep todo
# Ensure images are built with correct tags
```

See [SETUP.md](docs/SETUP.md#troubleshooting) for more solutions.

## 📖 Learning Resources

- [ConnectRPC Documentation](https://connectrpc.com/docs/)
- [SQLC Documentation](https://docs.sqlc.dev/)
- [Goose Migrations](https://github.com/pressly/goose)
- [Vue 3 Documentation](https://vuejs.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🎓 Interview Tips

1. **Practice the setup** - Run through it at least once
2. **Know your tools** - Understand kubectl, docker, buf, sqlc
3. **Think aloud** - Explain your reasoning
4. **Ask questions** - Clarify requirements
5. **Use AI wisely** - For boilerplate, not entire features
6. **Stay calm** - You're well-prepared!

See [INTERVIEW_PREP.md](docs/INTERVIEW_PREP.md) for detailed tips.

## 🤝 Interview Process

This project supports the GoHighLevel Round 1 hands-on interview:

- **Duration**: 2 hours (10min intro + 10min problem + 100min coding)
- **Format**: Collaborative coding session
- **Focus**: Extending this application with new features
- **Expectations**: Problem-solving, communication, AI collaboration

## 📞 Support

If you encounter issues:

1. Check [SETUP.md](docs/SETUP.md#troubleshooting)
2. Review [DEPLOYMENT.md](docs/DEPLOYMENT.md#common-issues--solutions)
3. Check pod logs: `kubectl logs -n todo-app <pod-name>`
4. Verify prerequisites are correctly installed

## 🎉 Ready to Go!

You've built a complete, production-ready application. You understand the architecture, can extend it, debug it, and deploy it. You're ready for the interview!

**Good luck! 🚀**

---

## 📄 License

Created for interview purposes.

## 👤 Author

**Saurabh Jain**

- GitHub: [@saurabhj](https://github.com/saurabhj)
- Interview Prep: GoHighLevel Round 1

---

*Last updated: December 2025*
