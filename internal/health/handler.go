package health

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"time"
)

type Handler struct {
	db *sql.DB
}

type Response struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data"`
}

func NewHandler(db *sql.DB) *Handler {
	return &Handler{
		db: db,
	}
}

func (h *Handler) Check(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
	defer cancel()

	err := h.db.PingContext(ctx)

	if err != nil {
		writeJSON(w, http.StatusServiceUnavailable, Response{
			Success: false,
			Message: "Service unavailable",
			Data:    nil,
		})
		return
	}

	writeJSON(w, http.StatusOK, Response{
		Success: true,
		Message: "Service is healthy",
		Data: map[string]string{
			"status":   "ok",
			"database": "connected",
		},
	})
}

func writeJSON(w http.ResponseWriter, status int, response Response) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	_ = json.NewEncoder(w).Encode(response)
}
