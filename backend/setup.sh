#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up GoHighLevel Interview Backend...${NC}\n"

# Check if running from backend directory
if [ ! -f "go.mod" ]; then
    echo -e "${RED}Error: Please run this script from the backend directory${NC}"
    exit 1
fi

# Step 1: Install required tools
echo -e "${GREEN}Step 1: Installing required tools...${NC}"
go install github.com/bufbuild/buf/cmd/buf@latest
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
go install github.com/pressly/goose/v3/cmd/goose@latest

# Step 2: Download Go dependencies
echo -e "\n${GREEN}Step 2: Downloading Go dependencies...${NC}"
go mod download
go mod tidy

# Step 3: Generate protobuf code
echo -e "\n${GREEN}Step 3: Generating protobuf and ConnectRPC code...${NC}"
buf generate

# Step 4: Generate sqlc code
echo -e "\n${GREEN}Step 4: Generating sqlc database code...${NC}"
sqlc generate

# Step 5: Start PostgreSQL
echo -e "\n${GREEN}Step 5: Starting PostgreSQL with Docker Compose...${NC}"
docker-compose up -d

# Wait for PostgreSQL to be ready
echo -e "${BLUE}Waiting for PostgreSQL to be ready...${NC}"
sleep 5

# Step 6: Run migrations
echo -e "\n${GREEN}Step 6: Running database migrations...${NC}"
goose -dir internal/adapter/postgresql/migrations postgres "postgresql://postgres:postgres@localhost:5432/ecom?sslmode=disable" up

echo -e "\n${GREEN}✓ Setup complete!${NC}"
echo -e "\n${BLUE}To run the backend:${NC}"
echo -e "  make run"
echo -e "\n${BLUE}To build Docker image:${NC}"
echo -e "  make docker-build"
