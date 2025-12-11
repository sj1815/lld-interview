# Build stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates curl

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/main .

# Copy migrations for init container
COPY --from=builder /app/internal/adapter/postgresql/migrations /migrations

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]
