package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/saurabhj/lld-interview/backend/internal/env"
)

func main() {
	// Load configuration
	config, err := env.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	log.Printf("Starting application in %s mode", config.Environment)

	// Create server
	server, err := NewServer(config)
	if err != nil {
		log.Fatalf("Failed to create server: %v", err)
	}

	// Setup context with cancellation for graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Setup signal handling for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-sigChan
		log.Println("Shutting down gracefully...")
		cancel()
	}()

	// Start server
	log.Println("Server starting...")
	if err := server.Start(ctx); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
