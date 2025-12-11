.PHONY: proto sqlc migrate-up migrate-down migrate-create docker-build docker-run help

# Default target
help:
	@echo "Available targets:"
	@echo "  proto         - Generate protobuf and ConnectRPC code"
	@echo "  sqlc          - Generate sqlc code"
	@echo "  migrate-up    - Run database migrations up"
	@echo "  migrate-down  - Run database migrations down"
	@echo "  migrate-create - Create new migration (usage: make migrate-create name=migration_name)"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-run    - Run docker-compose"
	@echo "  run           - Run the application locally"
	@echo "  test          - Run tests"

# Generate protobuf code
proto:
	buf generate

# Generate sqlc code
sqlc:
	sqlc generate

# Run migrations up
migrate-up:
	goose -dir internal/adapter/postgresql/migrations postgres "postgresql://postgres:postgres@localhost:5432/ecom?sslmode=disable" up

# Run migrations down
migrate-down:
	goose -dir internal/adapter/postgresql/migrations postgres "postgresql://postgres:postgres@localhost:5432/ecom?sslmode=disable" down

# Create new migration
migrate-create:
	goose -dir internal/adapter/postgresql/migrations create $(name) sql

# Build Docker image
docker-build:
	docker build -t todo-backend:latest .

# Run docker-compose
docker-run:
	docker-compose up -d

# Stop docker-compose
docker-stop:
	docker-compose down

# Run the application
run:
	go run cmd/main.go

# Run tests
test:
	go test -v ./...

# Install dependencies
deps:
	go mod download
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	go install github.com/pressly/goose/v3/cmd/goose@latest

# Clean generated files
clean:
	rm -rf gen/
