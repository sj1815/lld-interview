# Interview Preparation Guide

Your complete guide to confidently ace the GoHighLevel Round 1 hands-on interview.

## 🎯 Interview Structure Recap

- **Duration**: 2 hours
- **Format**: Collaborative coding session
- **Structure**:
  - 10 min: Getting to know you
  - 10 min: Understanding the problem
  - 100 min: Collaborative coding exercise

## ✅ What You've Already Prepared

### 1. ✓ Local Kubernetes Environment

You have a **fully functional** Kubernetes setup with:
- Docker Desktop with Kubernetes enabled (or Minikube)
- Ability to run pods and services
- Experience with kubectl commands
- Knowledge of debugging with logs and port-forwarding

**Practice commands:**
```bash
kubectl get pods -n todo-app
kubectl logs -n todo-app -l app=backend -f
kubectl port-forward -n todo-app svc/backend 8080:8080
kubectl describe pod -n todo-app <pod-name>
```

### 2. ✓ Go Backend with ConnectRPC

Your backend demonstrates:
- Clean Go project structure
- ConnectRPC endpoint implementation
- Database integration with PostgreSQL
- Type-safe database queries (SQLC)
- Database migrations (Goose)
- Proper error handling
- Health check endpoint
- CORS configuration for frontend access

**Key files to review:**
- `backend/proto/todo/v1/todo.proto` - RPC definitions
- `backend/internal/implementation/handler.go` - RPC handlers
- `backend/internal/implementation/service.go` - Business logic
- `backend/internal/adapter/postgresql/sqlc/queries.sql` - SQL queries

### 3. ✓ Vue.js Frontend with ConnectRPC

Your frontend shows:
- Vue 3 Composition API usage
- ConnectRPC client integration
- Generated TypeScript types
- End-to-end communication with backend
- Modern, responsive UI

**Key files to review:**
- `frontend/src/client.js` - ConnectRPC client setup
- `frontend/src/App.vue` - Main component with RPC calls
- `frontend/src/gen/` - Generated client code

### 4. ✓ Working End-to-End Communication

You can demonstrate:
- Frontend successfully calling backend RPCs
- Data flowing from UI → Backend → Database → Backend → UI
- CRUD operations working in the browser
- Error handling

### 5. ✓ Kubernetes Deployment Knowledge

You understand:
- Deployments and Services
- ConfigMaps for configuration
- Init containers for migrations
- Health checks and probes
- Port forwarding for debugging
- Pod logs for troubleshooting

## 🚀 Common Interview Scenarios

### Scenario 1: Add a New RPC Endpoint

**Task**: "Add an endpoint to get statistics about todos"

**Your approach:**

1. **Define the Proto**
   ```protobuf
   message GetStatsRequest {}
   
   message GetStatsResponse {
     int32 total = 1;
     int32 completed = 2;
     int32 pending = 3;
   }
   
   service TodoService {
     // ... existing RPCs
     rpc GetStats(GetStatsRequest) returns (GetStatsResponse) {}
   }
   ```

2. **Regenerate Code**
   ```bash
   cd backend
   buf generate
   ```

3. **Implement Handler**
   ```go
   func (h *TodoHandler) GetStats(
       ctx context.Context,
       req *connect.Request[todov1.GetStatsRequest],
   ) (*connect.Response[todov1.GetStatsResponse], error) {
       stats, err := h.service.GetStats(ctx)
       if err != nil {
           return nil, connect.NewError(connect.CodeInternal, err)
       }
       return connect.NewResponse(&todov1.GetStatsResponse{
           Total:     stats.Total,
           Completed: stats.Completed,
           Pending:   stats.Pending,
       }), nil
   }
   ```

4. **Implement Service Logic**
   ```go
   type Stats struct {
       Total     int32
       Completed int32
       Pending   int32
   }
   
   func (s *TodoService) GetStats(ctx context.Context) (*Stats, error) {
       // Add query to queries.sql
       // Use SQLC to implement
   }
   ```

5. **Deploy**
   ```bash
   docker build -t todo-backend:latest .
   kubectl delete pod -n todo-app -l app=backend
   ```

6. **Test**
   ```bash
   kubectl logs -n todo-app -l app=backend -f
   kubectl port-forward -n todo-app svc/backend 8080:8080
   # Test with frontend or curl
   ```

### Scenario 2: Add a Database Field

**Task**: "Add a 'due_date' field to todos"

**Your approach:**

1. **Create Migration**
   ```bash
   make migrate-create name=add_due_date
   ```

2. **Write Migration**
   ```sql
   -- +goose Up
   ALTER TABLE todos ADD COLUMN due_date TIMESTAMP;
   
   -- +goose Down
   ALTER TABLE todos DROP COLUMN due_date;
   ```

3. **Update SQL Queries**
   ```sql
   -- name: CreateTodo :one
   INSERT INTO todos (title, description, completed, due_date)
   VALUES ($1, $2, $3, $4)
   RETURNING *;
   ```

4. **Regenerate SQLC**
   ```bash
   sqlc generate
   ```

5. **Update Proto**
   ```protobuf
   message Todo {
     // ... existing fields
     string due_date = 7;
   }
   ```

6. **Update Service Layer**
   ```go
   func (s *TodoService) CreateTodo(ctx context.Context, title, description string, dueDate *time.Time) (*repo.Todo, error) {
       // Handle due_date
   }
   ```

7. **Redeploy**
   ```bash
   docker build -t todo-backend:latest .
   kubectl delete pod -n todo-app -l app=backend
   # Init container will run migrations automatically
   ```

### Scenario 3: Add Frontend Feature

**Task**: "Add a filter to show only completed/pending todos"

**Your approach:**

1. **Add State**
   ```javascript
   const filter = ref('all') // 'all' | 'completed' | 'pending'
   ```

2. **Add Computed Property**
   ```javascript
   const filteredTodos = computed(() => {
     if (filter.value === 'completed') {
       return todos.value.filter(t => t.completed)
     } else if (filter.value === 'pending') {
       return todos.value.filter(t => !t.completed)
     }
     return todos.value
   })
   ```

3. **Update Template**
   ```vue
   <div class="filters">
     <button @click="filter = 'all'">All</button>
     <button @click="filter = 'completed'">Completed</button>
     <button @click="filter = 'pending'">Pending</button>
   </div>
   
   <li v-for="todo in filteredTodos" :key="todo.id">
     <!-- todo item -->
   </li>
   ```

4. **Redeploy**
   ```bash
   docker build -t todo-frontend:latest .
   kubectl delete pod -n todo-app -l app=frontend
   ```

### Scenario 4: Debug Connection Issue

**Task**: "Frontend can't connect to backend"

**Your troubleshooting steps:**

1. **Check Pod Status**
   ```bash
   kubectl get pods -n todo-app
   # Ensure all pods are Running
   ```

2. **Check Backend Logs**
   ```bash
   kubectl logs -n todo-app -l app=backend
   # Look for errors
   ```

3. **Check Frontend Logs**
   ```bash
   kubectl logs -n todo-app -l app=frontend
   # Look for network errors
   ```

4. **Test Backend Health**
   ```bash
   kubectl port-forward -n todo-app svc/backend 8080:8080
   curl http://localhost:8080/health
   ```

5. **Check Service Connectivity**
   ```bash
   kubectl exec -n todo-app -l app=frontend -- wget -qO- http://backend:8080/health
   ```

6. **Verify CORS Headers**
   ```bash
   curl -H "Origin: http://localhost:3000" \
        -H "Access-Control-Request-Method: POST" \
        -X OPTIONS http://localhost:8080/todo.v1.TodoService/ListTodos
   ```

7. **Check Environment Variables**
   ```bash
   kubectl exec -n todo-app -l app=frontend -- env | grep VITE
   ```

## 💡 Communication Best Practices

### Think Aloud

✅ **Good:**
- "I'm going to add a new RPC method to the proto file first"
- "Let me check the logs to see what's happening"
- "I think the issue might be in the service layer, let me verify"
- "Should I handle this edge case, or is it okay to assume valid input?"

❌ **Avoid:**
- Silent coding for long periods
- Making assumptions without clarifying
- Getting stuck without asking for help

### Ask Clarifying Questions

✅ **Good questions:**
- "Should this field be required or optional?"
- "What should happen if the todo is not found?"
- "Do you want me to add validation for this?"
- "Should I add tests for this functionality?"

### Use AI Appropriately

✅ **Appropriate:**
- "Let me use AI to help write this boilerplate"
- "I'll check the syntax for this proto definition with AI"
- "AI can help me remember the SQLC query format"

❌ **Inappropriate:**
- Asking AI to implement entire features
- Not understanding AI-generated code
- Over-relying on AI for basic tasks

## 🎓 Key Concepts to Understand

### ConnectRPC

- **What it is**: gRPC-compatible RPC framework that works over HTTP/2
- **Why useful**: Type-safe APIs, auto-generated clients, works in browsers
- **Key files**: `.proto` definitions, generated code, handlers

### SQLC

- **What it is**: Generates type-safe Go code from SQL
- **Why useful**: No ORM overhead, compile-time safety, pure SQL
- **Key files**: `queries.sql`, generated `*.go` files

### Goose

- **What it is**: Database migration tool
- **Why useful**: Version control for database schema
- **Key files**: `migrations/*.sql` files

### Kubernetes Concepts

- **Pod**: Smallest deployable unit, runs containers
- **Deployment**: Manages pod replicas and updates
- **Service**: Network endpoint for accessing pods
- **ConfigMap**: Configuration data for pods
- **InitContainer**: Runs before main container (used for migrations)

## 🛠️ Quick Reference Commands

### During Development

```bash
# Generate proto code
buf generate

# Generate SQLC code
sqlc generate

# Create migration
make migrate-create name=<name>

# Run migrations locally
make migrate-up

# Build and test locally
go run cmd/main.go
npm run dev
```

### During Kubernetes Deployment

```bash
# Rebuild and redeploy backend
docker build -t todo-backend:latest . && \
kubectl delete pod -n todo-app -l app=backend

# Rebuild and redeploy frontend
docker build -t todo-frontend:latest . && \
kubectl delete pod -n todo-app -l app=frontend

# Watch pods
kubectl get pods -n todo-app -w

# Check logs
kubectl logs -n todo-app -l app=backend -f

# Port forward
kubectl port-forward -n todo-app svc/backend 8080:8080
```

### For Debugging

```bash
# Describe pod (see events)
kubectl describe pod -n todo-app <pod-name>

# Exec into pod
kubectl exec -it -n todo-app -l app=backend -- sh

# Check service endpoints
kubectl get endpoints -n todo-app

# View events
kubectl get events -n todo-app --sort-by='.lastTimestamp'
```

## 📝 Pre-Interview Checklist

### One Day Before

- [ ] Run through complete setup from scratch
- [ ] Practice adding a simple RPC endpoint
- [ ] Practice creating a migration
- [ ] Practice debugging a connection issue
- [ ] Review proto syntax
- [ ] Review SQLC query syntax
- [ ] Review Vue Composition API basics

### Morning Of Interview

- [ ] Ensure Docker Desktop is running
- [ ] Ensure Kubernetes cluster is accessible
- [ ] Deploy the application and verify it works
- [ ] Have multiple terminal windows ready
- [ ] Have documentation links bookmarked:
  - [ConnectRPC Docs](https://connectrpc.com/docs/go/getting-started)
  - [SQLC Docs](https://docs.sqlc.dev/en/latest/)
  - [Kubernetes Docs](https://kubernetes.io/docs/reference/kubectl/)
- [ ] Have your code open in VS Code
- [ ] Test your microphone and camera

### At Start of Interview

- [ ] Share your screen
- [ ] Show them the running application
- [ ] Give a brief architecture overview (2 minutes)
- [ ] Mention you're ready to extend it

## 🎯 Interview Success Criteria

The interviewers are looking for:

### ✅ Technical Skills

- Can extend the proto definition correctly
- Understands how to regenerate code
- Can implement business logic in Go
- Can work with SQL and database migrations
- Understands Kubernetes deployments
- Can debug issues systematically

### ✅ Problem-Solving

- Breaks down problems into steps
- Asks clarifying questions
- Considers edge cases
- Tests incrementally
- Debugs methodically

### ✅ AI Usage

- Uses AI for boilerplate and syntax
- Validates AI-generated code
- Explains AI-generated code
- Knows when NOT to use AI

### ✅ Communication

- Thinks aloud
- Explains reasoning
- Asks for help when stuck
- Receptive to feedback
- Collaborative attitude

## 🚫 Common Pitfalls to Avoid

1. **Silent coding**: Always narrate what you're doing
2. **Copying blindly**: Understand AI-generated code before using
3. **Not testing**: Test each change incrementally
4. **Ignoring errors**: Read error messages carefully
5. **Skipping basics**: Don't overcomplicate simple tasks
6. **Not asking for help**: Better to ask than be stuck
7. **Rigid thinking**: Be open to alternative approaches

## 🎊 You're Ready!

You have:
- ✅ A working full-stack application
- ✅ Experience with ConnectRPC
- ✅ A functional Kubernetes setup
- ✅ Knowledge of quick iteration workflows
- ✅ Debugging skills and tools
- ✅ Understanding of the tech stack

### Remember:

1. **They want you to succeed** - This is collaborative, not adversarial
2. **It's okay to ask questions** - Shows engagement and thoughtfulness
3. **It's okay to use AI** - Shows modern development practices
4. **It's okay to make mistakes** - Shows you can debug and iterate
5. **Breathe and stay calm** - You're well-prepared!

## 📞 Last-Minute Tips

- **Keep water nearby** - Stay hydrated
- **Have a notepad** - Jot down ideas or questions
- **Close distractions** - Silence notifications
- **Be yourself** - Show your personality and enthusiasm
- **Have fun** - This is an opportunity to code with experienced engineers!

---

## 🎉 Good Luck!

You've put in the work. You're prepared. Now go show them what you can do!

**Remember**: The goal isn't perfection—it's showing how you think, learn, and collaborate.

You've got this! 🚀

---

**When you're done with the interview, regardless of the outcome, be proud that you prepared thoroughly and gave it your best shot. That's what matters.**
