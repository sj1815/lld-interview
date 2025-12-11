package env

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DatabaseURL string
	ServerPort  string
	Environment string
}

func LoadConfig() (*Config, error) {
	// Load .env file if it exists (for local development)
	_ = godotenv.Load()

	config := &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/ecom?sslmode=disable"),
		ServerPort:  getEnv("SERVER_PORT", "8080"),
		Environment: getEnv("ENVIRONMENT", "development"),
	}

	if config.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	return config, nil
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
