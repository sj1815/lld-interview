#!/bin/bash

# Master setup script for GoHighLevel Interview Project
# This script sets up the entire project from scratch

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     GoHighLevel Interview - Full Stack Setup               ║"
echo "║     Todo Application with Go, Vue, and Kubernetes          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}\n"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Go
if command_exists go; then
    echo -e "${GREEN}✓${NC} Go $(go version | awk '{print $3}')"
else
    echo -e "${RED}✗${NC} Go not found. Please install Go 1.23+"
    exit 1
fi

# Check Node
if command_exists node; then
    echo -e "${GREEN}✓${NC} Node $(node --version)"
else
    echo -e "${RED}✗${NC} Node.js not found. Please install Node.js 20+"
    exit 1
fi

# Check Docker
if command_exists docker; then
    echo -e "${GREEN}✓${NC} Docker $(docker --version | awk '{print $3}' | tr -d ',')"
else
    echo -e "${RED}✗${NC} Docker not found. Please install Docker Desktop"
    exit 1
fi

# Check kubectl
if command_exists kubectl; then
    echo -e "${GREEN}✓${NC} kubectl $(kubectl version --client --short 2>/dev/null | awk '{print $3}')"
else
    echo -e "${RED}✗${NC} kubectl not found. Please install kubectl"
    exit 1
fi

echo -e "\n${GREEN}All prerequisites satisfied!${NC}\n"

# Ask user what they want to setup
echo -e "${BLUE}What would you like to setup?${NC}"
echo "1) Backend only"
echo "2) Frontend only"
echo "3) Both (Recommended)"
echo "4) Full setup including Kubernetes deployment"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "\n${BLUE}Setting up Backend...${NC}\n"
        cd backend
        chmod +x setup.sh
        ./setup.sh
        echo -e "\n${GREEN}✓ Backend setup complete!${NC}"
        echo -e "${YELLOW}To run: cd backend && make run${NC}"
        ;;
    2)
        echo -e "\n${BLUE}Setting up Frontend...${NC}\n"
        cd frontend
        chmod +x setup.sh
        ./setup.sh
        echo -e "\n${GREEN}✓ Frontend setup complete!${NC}"
        echo -e "${YELLOW}To run: cd frontend && npm run dev${NC}"
        ;;
    3)
        echo -e "\n${BLUE}Setting up Backend...${NC}\n"
        cd backend
        chmod +x setup.sh
        ./setup.sh
        
        echo -e "\n${BLUE}Setting up Frontend...${NC}\n"
        cd ../frontend
        chmod +x setup.sh
        ./setup.sh
        
        echo -e "\n${GREEN}✓ Backend and Frontend setup complete!${NC}"
        echo -e "\n${YELLOW}To run locally:${NC}"
        echo -e "  Terminal 1: ${BLUE}cd backend && make run${NC}"
        echo -e "  Terminal 2: ${BLUE}cd frontend && npm run dev${NC}"
        echo -e "  Browser:    ${BLUE}http://localhost:3000${NC}"
        ;;
    4)
        echo -e "\n${BLUE}Full setup with Kubernetes deployment...${NC}\n"
        
        # Backend setup
        echo -e "${BLUE}Step 1/6: Setting up Backend...${NC}\n"
        cd backend
        chmod +x setup.sh
        ./setup.sh
        
        # Frontend setup
        echo -e "\n${BLUE}Step 2/6: Setting up Frontend...${NC}\n"
        cd ../frontend
        chmod +x setup.sh
        ./setup.sh
        
        # Build Docker images
        echo -e "\n${BLUE}Step 3/6: Building Docker images...${NC}\n"
        cd ..
        echo "Building backend image..."
        docker build -t todo-backend:latest backend/
        echo "Building frontend image..."
        docker build -t todo-frontend:latest frontend/
        
        # Verify Kubernetes
        echo -e "\n${BLUE}Step 4/6: Verifying Kubernetes cluster...${NC}\n"
        if kubectl cluster-info > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible"
        else
            echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster"
            echo "Please ensure Kubernetes is enabled in Docker Desktop or Minikube is running"
            exit 1
        fi
        
        # Deploy to Kubernetes
        echo -e "\n${BLUE}Step 5/6: Deploying to Kubernetes...${NC}\n"
        kubectl apply -f k8s/namespace.yaml
        kubectl apply -f k8s/postgres-config.yaml
        kubectl apply -f k8s/postgres.yaml
        
        echo "Waiting for PostgreSQL to be ready..."
        kubectl wait --for=condition=ready pod -l app=postgres -n todo-app --timeout=120s
        
        kubectl apply -f k8s/backend.yaml
        
        echo "Waiting for backend to be ready..."
        kubectl wait --for=condition=ready pod -l app=backend -n todo-app --timeout=120s
        
        kubectl apply -f k8s/frontend.yaml
        
        # Verify deployment
        echo -e "\n${BLUE}Step 6/6: Verifying deployment...${NC}\n"
        kubectl get pods -n todo-app
        
        echo -e "\n${GREEN}✓ Full setup complete!${NC}"
        echo -e "\n${YELLOW}Your application is now running on Kubernetes!${NC}"
        echo -e "\n${BLUE}Access your application:${NC}"
        echo -e "  NodePort:       ${BLUE}http://localhost:30080${NC}"
        echo -e "  Port Forward:   ${BLUE}kubectl port-forward -n todo-app svc/frontend 3000:80${NC}"
        echo -e "                  ${BLUE}http://localhost:3000${NC}"
        echo -e "\n${BLUE}Useful commands:${NC}"
        echo -e "  Check status:   ${BLUE}kubectl get pods -n todo-app${NC}"
        echo -e "  View logs:      ${BLUE}kubectl logs -n todo-app -l app=backend -f${NC}"
        echo -e "  Delete all:     ${BLUE}kubectl delete namespace todo-app${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                    Setup Complete! 🎉                      ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  1. Review the documentation in ${YELLOW}docs/${NC} folder"
echo -e "  2. Read ${YELLOW}docs/INTERVIEW_PREP.md${NC} for interview tips"
echo -e "  3. Practice adding features and redeploying"
echo -e "\n${BLUE}Good luck with your GoHighLevel interview! 🚀${NC}\n"
