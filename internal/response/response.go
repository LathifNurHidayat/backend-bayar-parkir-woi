package response

import (
	"encoding/json"
	"net/http"
)

type ApiResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data"`
}

func JSON(
	w http.ResponseWriter,
	statusCode int,
	success bool,
	message string,
	data any,
) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)

	response := ApiResponse{
		Success: success,
		Message: message,
		Data:    data,
	}

	_ = json.NewEncoder(w).Encode(response)
}

func Success(
	w http.ResponseWriter,
	statusCode int,
	message string,
	data any,
) {
	JSON(w, statusCode, true, message, data)
}

func Error(
	w http.ResponseWriter,
	statusCode int,
	message string,
) {
	JSON(w, statusCode, false, message, nil)
}
