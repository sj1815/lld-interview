#!/bin/bash

# Verification script to test the application
# Run this after deployment to ensure everything works

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         GoHighLevel Interview - Verification Test          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

FAILED=0

# Test 1: Check if kubectl is accessible
echo -e "${YELLOW}Test 1: Checking Kubernetes cluster...${NC}"
if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible\n"
else
    echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster\n"
    FAILED=$((FAILED+1))
fi

# Test 2: Check namespace exists
echo -e "${YELLOW}Test 2: Checking namespace...${NC}"
if kubectl get namespace todo-app > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Namespace 'todo-app' exists\n"
else
    echo -e "${RED}✗${NC} Namespace 'todo-app' not found\n"
    FAILED=$((FAILED+1))
fi

# Test 3: Check pods are running
echo -e "${YELLOW}Test 3: Checking pods...${NC}"
PODS=$(kubectl get pods -n todo-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$PODS" -ge 3 ]; then
    echo -e "${GREEN}✓${NC} All pods are running ($PODS/3)\n"
    kubectl get pods -n todo-app
    echo ""
else
    echo -e "${RED}✗${NC} Not all pods are running ($PODS/3)\n"
    kubectl get pods -n todo-app
    echo ""
    FAILED=$((FAILED+1))
fi

# Test 4: Check services exist
echo -e "${YELLOW}Test 4: Checking services...${NC}"
SERVICES=$(kubectl get svc -n todo-app --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$SERVICES" -ge 3 ]; then
    echo -e "${GREEN}✓${NC} All services exist ($SERVICES/3)\n"
else
    echo -e "${RED}✗${NC} Not all services exist ($SERVICES/3)\n"
    FAILED=$((FAILED+1))
fi

# Test 5: Check backend health
echo -e "${YELLOW}Test 5: Testing backend health endpoint...${NC}"
kubectl port-forward -n todo-app svc/backend 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend health check passed\n"
else
    echo -e "${RED}✗${NC} Backend health check failed\n"
    FAILED=$((FAILED+1))
fi

kill $PF_PID 2>/dev/null || true

# Test 6: Check if frontend is accessible
echo -e "${YELLOW}Test 6: Testing frontend accessibility...${NC}"
kubectl port-forward -n todo-app svc/frontend 3000:80 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

if curl -sf http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Frontend is accessible\n"
else
    echo -e "${RED}✗${NC} Frontend is not accessible\n"
    FAILED=$((FAILED+1))
fi

kill $PF_PID 2>/dev/null || true

# Test 7: Check Docker images
echo -e "${YELLOW}Test 7: Checking Docker images...${NC}"
BACKEND_IMG=$(docker images todo-backend:latest --format "{{.Repository}}" 2>/dev/null | wc -l | tr -d ' ')
FRONTEND_IMG=$(docker images todo-frontend:latest --format "{{.Repository}}" 2>/dev/null | wc -l | tr -d ' ')

if [ "$BACKEND_IMG" -ge 1 ] && [ "$FRONTEND_IMG" -ge 1 ]; then
    echo -e "${GREEN}✓${NC} Both Docker images exist\n"
else
    echo -e "${RED}✗${NC} Docker images missing\n"
    docker images | grep todo || echo "No todo images found"
    echo ""
    FAILED=$((FAILED+1))
fi

# Test 8: Check if migrations ran
echo -e "${YELLOW}Test 8: Checking database migrations...${NC}"
POD=$(kubectl get pod -n todo-app -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD" ]; then
    INIT_LOGS=$(kubectl logs -n todo-app $POD -c run-migrations 2>/dev/null | grep -i "completed" || echo "")
    if [ ! -z "$INIT_LOGS" ]; then
        echo -e "${GREEN}✓${NC} Migrations completed successfully\n"
    else
        echo -e "${YELLOW}⚠${NC}  Cannot verify migrations (check init container logs)\n"
    fi
else
    echo -e "${RED}✗${NC} Cannot find backend pod\n"
    FAILED=$((FAILED+1))
fi

# Summary
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your application is ready! 🎉${NC}\n"
    echo -e "${BLUE}Access your application:${NC}"
    echo -e "  Frontend:  ${GREEN}http://localhost:30080${NC}"
    echo -e "  Or use:    ${GREEN}kubectl port-forward -n todo-app svc/frontend 3000:80${NC}"
    echo -e "             ${GREEN}http://localhost:3000${NC}\n"
else
    echo -e "${RED}✗ $FAILED test(s) failed. Please check the output above.${NC}\n"
    echo -e "${YELLOW}Troubleshooting tips:${NC}"
    echo -e "  1. Check pod logs: ${BLUE}kubectl logs -n todo-app <pod-name>${NC}"
    echo -e "  2. Describe pods:  ${BLUE}kubectl describe pod -n todo-app <pod-name>${NC}"
    echo -e "  3. Check events:   ${BLUE}kubectl get events -n todo-app${NC}"
    echo -e "  4. Review setup:   ${BLUE}./setup.sh${NC}\n"
    exit 1
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
