
package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"

	"backend-bayar-parkir-woi/internal/database"
)

func main() {
	// Load konfigurasi lokal dari .env.
	// Jika file tidak tersedia, gunakan environment variables.
	_ = godotenv.Load()

	ctx, cancel := context.WithTimeout(
		context.Background(),
		5*time.Second,
	)
	defer cancel()

	db, err := database.Open(ctx)
	if err != nil {
		log.Fatalf("Database connection failed: %v", err)
	}
	defer db.Close()

	log.Println("Database connected successfully")

	appPort := os.Getenv("APP_PORT")
	if appPort == "" {
		appPort = "8080"
	}

	log.Printf("Application configuration loaded. Port: %s", appPort)
}
