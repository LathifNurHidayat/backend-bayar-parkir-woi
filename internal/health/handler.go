package health

import (
	"context"
	"database/sql"
	"net/http"
	"time"

	"backend-bayar-parkir-woi/internal/response"
)

type Handler struct {
	db *sql.DB
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
		response.Error(
			w,
			http.StatusServiceUnavailable,
			"Database Connection Failed",
		)
		return
	}

	response.Success(
		w,
		http.StatusOK,
		"Service is healty",
		map[string]string{
			"status":   "Ok",
			"database": "Connected",
		},
	)
}
