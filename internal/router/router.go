package router

import (
	"database/sql"
	"net/http"

	"backend-bayar-parkir-woi/internal/health"
)

func New(db *sql.DB) http.Handler {
	mux := http.NewServeMux()

	healthHandler := health.NewHandler(db)

	mux.HandleFunc("GET /health", healthHandler.Check)

	return mux
}
