#!/bin/bash

# Colors for logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting application...${NC}"

# Function to check if port is in use
check_port() {
    lsof -i :$1 > /dev/null 2>&1
    return $?
}

# Installation des dépendances du backend
echo -e "${BLUE}📦 Installation des dépendances Go...${NC}"
cd backend
go mod download
go mod tidy

# Installation des dépendances du frontend
echo -e "${BLUE}📦 Installation des dépendances Node.js...${NC}"
cd ../frontend
npm install

# Démarrage du backend en arrière-plan
echo -e "${GREEN}🚀 Starting backend...${NC}"
cd ../backend
if check_port 8080; then
    echo "⚠️  Port 8080 is already in use. Stopping process..."
    lsof -ti:8080 | xargs kill -9
fi
go run cmd/api/main.go &
BACKEND_PID=$!

# Démarrage du frontend
echo -e "${GREEN}🚀 Starting frontend...${NC}"
cd ../frontend
if check_port 3000; then
    echo "⚠️  Port 3000 is already in use. Stopping process..."
    lsof -ti:3000 | xargs kill -9
fi
npm run dev &
FRONTEND_PID=$!

# Clean shutdown function (Ctrl+C)
cleanup() {
    echo -e "${BLUE}🛑 Stopping services...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Wait for user to stop script with Ctrl+C
echo -e "${GREEN}✅ Application started!${NC}"
echo -e "${BLUE}📝 Logs des services :${NC}"
wait 