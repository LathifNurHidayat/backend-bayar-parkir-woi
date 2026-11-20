package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"

	"backend-bayar-parkir-woi/internal/database"
	"backend-bayar-parkir-woi/internal/health"
)

func main() {
	_ = godotenv.Load()

	// @database connection
	dbCtx, dbCancel := context.WithTimeout(
		context.Background(),
		5*time.Second,
	)

	db, err := database.Open(dbCtx)
	dbCancel()

	if err != nil {
		log.Fatalf("Database connection failed: %v", err)
	}
	defer db.Close()

	log.Println("Database connected successfully")

	// @create new http router
	mux := http.NewServeMux()

	healthHandler := health.NewHandler(db)

	// @register health check endpoint
	mux.HandleFunc("GET /health", healthHandler.Check)

	// @HTTP server configuration
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	// @config http server
	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	// @graceful shutdown
	serverCtx, stop := signal.NotifyContext(
		context.Background(),
		os.Interrupt,
		syscall.SIGTERM,
	)
	defer stop()

	go func() {
		log.Printf("HTTP server listening on port %s", port)

		// @start running the HTTP server
		err := server.ListenAndServe()

		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("HTTP server failed: %v", err)
		}
	}()

	<-serverCtx.Done()

	log.Println("Shutting down HTTP server...")

	shutdownCtx, cancel := context.WithTimeout(
		context.Background(),
		10*time.Second,
	)
	defer cancel()

	// @shutdown server http
	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("HTTP server shutdown error: %v", err)
	}
}
