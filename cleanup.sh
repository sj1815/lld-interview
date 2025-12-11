#!/bin/bash

# Cleanup script - Stop everything and remove all resources
# Use this to reset your environment before running setup.sh again

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 Cleanup Script                              ║${NC}"
echo -e "${BLUE}║     Stopping all services and removing resources           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

# Step 1: Delete Kubernetes resources
echo -e "${YELLOW}Step 1: Deleting Kubernetes resources...${NC}"
if kubectl get namespace todo-app > /dev/null 2>&1; then
    kubectl delete namespace todo-app --timeout=60s 2>/dev/null || echo "Namespace already deleted or doesn't exist"
    echo -e "${GREEN}✓${NC} Kubernetes namespace deleted\n"
else
    echo -e "${BLUE}ℹ${NC} Kubernetes namespace doesn't exist\n"
fi

# Step 2: Stop and remove Docker Compose services
echo -e "${YELLOW}Step 2: Stopping Docker Compose services...${NC}"
if [ -f "backend/docker-compose.yaml" ]; then
    cd backend
    docker-compose down -v 2>/dev/null || echo "Docker Compose already stopped"
    cd ..
    echo -e "${GREEN}✓${NC} Docker Compose services stopped\n"
else
    echo -e "${BLUE}ℹ${NC} Docker Compose file not found\n"
fi

# Step 3: Remove Docker containers
echo -e "${YELLOW}Step 3: Removing Docker containers...${NC}"
CONTAINERS=$(docker ps -a --filter "name=ecom-postgres" --filter "name=todo-" -q)
if [ ! -z "$CONTAINERS" ]; then
    docker rm -f $CONTAINERS 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Containers removed\n"
else
    echo -e "${BLUE}ℹ${NC} No containers to remove\n"
fi

# Step 4: Remove Docker images
echo -e "${YELLOW}Step 4: Removing Docker images...${NC}"
IMAGES=$(docker images | grep -E "todo-backend|todo-frontend" | awk '{print $3}')
if [ ! -z "$IMAGES" ]; then
    docker rmi -f $IMAGES 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Docker images removed\n"
else
    echo -e "${BLUE}ℹ${NC} No images to remove\n"
fi

# Step 5: Clean up generated code
echo -e "${YELLOW}Step 5: Cleaning up generated code...${NC}"
rm -rf backend/gen 2>/dev/null || true
rm -rf frontend/src/gen 2>/dev/null || true
rm -rf frontend/node_modules 2>/dev/null || true
echo -e "${GREEN}✓${NC} Generated code cleaned up\n"

# Step 6: Stop any running processes on common ports
echo -e "${YELLOW}Step 6: Checking for processes on common ports...${NC}"
for PORT in 3000 8080 5432; do
    PID=$(lsof -ti:$PORT 2>/dev/null || true)
    if [ ! -z "$PID" ]; then
        echo -e "${YELLOW}  Killing process on port $PORT (PID: $PID)${NC}"
        kill -9 $PID 2>/dev/null || true
    fi
done
echo -e "${GREEN}✓${NC} Port cleanup complete\n"

# Step 7: Optional - Clean Docker system
echo -e "${YELLOW}Step 7: Docker system cleanup (optional)...${NC}"
read -p "Do you want to run 'docker system prune' to clean unused resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
    echo -e "${GREEN}✓${NC} Docker system cleaned\n"
else
    echo -e "${BLUE}ℹ${NC} Skipped Docker system prune\n"
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                  Cleanup Complete! ✨                      ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${BLUE}Your environment is now clean and ready for a fresh start!${NC}\n"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Run ${GREEN}./setup.sh${NC} to set up everything again"
echo -e "  2. Or manually start services as needed\n"

echo -e "${BLUE}What was cleaned:${NC}"
echo -e "  ✓ Kubernetes namespace and all resources"
echo -e "  ✓ Docker Compose services and volumes"
echo -e "  ✓ Docker containers (ecom-postgres, todo-*)"
echo -e "  ✓ Docker images (todo-backend, todo-frontend)"
echo -e "  ✓ Generated code (backend/gen, frontend/src/gen)"
echo -e "  ✓ Node modules (frontend/node_modules)"
echo -e "  ✓ Processes on ports 3000, 8080, 5432\n"
