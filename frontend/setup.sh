#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Frontend...${NC}\n"

# Check if running from frontend directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: Please run this script from the frontend directory${NC}"
    exit 1
fi

# Step 1: Install npm dependencies
echo -e "${GREEN}Step 1: Installing npm dependencies...${NC}"
npm install

# Step 2: Generate TypeScript code from proto files
echo -e "\n${GREEN}Step 2: Generating TypeScript code from proto files...${NC}"
npx buf generate

echo -e "\n${GREEN}✓ Frontend setup complete!${NC}"
echo -e "\n${BLUE}To run the frontend:${NC}"
echo -e "  npm run dev"
echo -e "\n${BLUE}To build for production:${NC}"
echo -e "  npm run build"
