package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	todov1connect "github.com/saurabhj/lld-interview/backend/gen/proto/todo/v1/todov1connect"
	"github.com/saurabhj/lld-interview/backend/internal/adapter/postgresql"
	"github.com/saurabhj/lld-interview/backend/internal/env"
	"github.com/saurabhj/lld-interview/backend/internal/implementation"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

type Server struct {
	config *env.Config
	router *http.ServeMux
}

func NewServer(config *env.Config) (*Server, error) {
	return &Server{
		config: config,
		router: http.NewServeMux(),
	}, nil
}

func (s *Server) Start(ctx context.Context) error {
	// Initialize database connection
	pool, err := postgresql.NewPool(ctx, s.config.DatabaseURL)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer pool.Close()

	log.Println("Successfully connected to database")

	// Initialize service and handler
	todoService := implementation.NewTodoService(pool)
	todoHandler := implementation.NewTodoHandler(todoService)

	// Register ConnectRPC handlers
	path, handler := todov1connect.NewTodoServiceHandler(todoHandler)
	s.router.Handle(path, handler)

	// Add health check endpoint
	s.router.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	// Enable CORS for local development and frontend access
	corsHandler := corsMiddleware(s.router)

	// Start HTTP server with h2c support (HTTP/2 without TLS)
	addr := fmt.Sprintf(":%s", s.config.ServerPort)
	log.Printf("Starting server on %s", addr)

	server := &http.Server{
		Addr:         addr,
		Handler:      h2c.NewHandler(corsHandler, &http2.Server{}),
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	return server.ListenAndServe()
}

// corsMiddleware adds CORS headers to allow frontend access
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Set CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Connect-Protocol-Version, Connect-Timeout-Ms")
		w.Header().Set("Access-Control-Expose-Headers", "Connect-Protocol-Version, Connect-Timeout-Ms")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
