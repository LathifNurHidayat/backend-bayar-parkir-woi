package auth

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"strconv"
	"strings"

	"golang.org/x/crypto/argon2"
)

const (
	argonMemory      uint32 = 19 * 1024
	argonIterations  uint32 = 2
	argonParallelism uint8  = 1
	argonSaltLength         = 16
	argonKeyLength          = 32
)

// HashPassword menghasilkan hash password menggunakan Argon2id.
func HashPassword(password string) (string, error) {
	salt := make([]byte, argonSaltLength)

	if _, err := rand.Read(salt); err != nil {
		return "", fmt.Errorf("generate password salt: %w", err)
	}

	hash := argon2.IDKey(
		[]byte(password),
		salt,
		argonIterations,
		argonMemory,
		argonParallelism,
		argonKeyLength,
	)

	encodedSalt := base64.RawStdEncoding.EncodeToString(salt)
	encodedHash := base64.RawStdEncoding.EncodeToString(hash)

	// Format PHC string.
	encoded := fmt.Sprintf(
		"$argon2id$v=19$m=%d,t=%d,p=%d$%s$%s",
		argonMemory,
		argonIterations,
		argonParallelism,
		encodedSalt,
		encodedHash,
	)

	return encoded, nil
}

// VerifyPassword memeriksa apakah password sesuai dengan hash.
func VerifyPassword(password, encodedHash string) bool {
	parts := strings.Split(encodedHash, "$")

	if len(parts) != 6 {
		return false
	}

	if parts[1] != "argon2id" || parts[2] != "v=19" {
		return false
	}

	// Baca parameter Argon2id.
	params := strings.Split(parts[3], ",")
	if len(params) != 3 {
		return false
	}

	memory, err := parseArgonParameter(params[0], "m=")
	if err != nil {
		return false
	}

	iterations, err := parseArgonParameter(params[1], "t=")
	if err != nil {
		return false
	}

	parallelism, err := parseArgonParameter(params[2], "p=")
	if err != nil {
		return false
	}

	// Batasi parameter untuk menghindari penggunaan resource
	// yang tidak wajar ketika membaca hash.
	if memory < 8*parallelism || memory > 64*1024 {
		return false
	}

	if iterations < 1 || iterations > 10 {
		return false
	}

	if parallelism < 1 || parallelism > 4 {
		return false
	}

	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil || len(salt) < 8 || len(salt) > 64 {
		return false
	}

	expectedHash, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil || len(expectedHash) < 16 || len(expectedHash) > 64 {
		return false
	}

	actualHash := argon2.IDKey(
		[]byte(password),
		salt,
		iterations,
		memory,
		uint8(parallelism),
		uint32(len(expectedHash)),
	)

	// Constant-time comparison untuk membandingkan hash.
	return subtle.ConstantTimeCompare(actualHash, expectedHash) == 1
}

func parseArgonParameter(value, prefix string) (uint32, error) {
	if !strings.HasPrefix(value, prefix) {
		return 0, fmt.Errorf("invalid parameter: %s", value)
	}

	parsed, err := strconv.ParseUint(
		strings.TrimPrefix(value, prefix),
		10,
		32,
	)
	if err != nil {
		return 0, fmt.Errorf("parse parameter: %w", err)
	}

	return uint32(parsed), nil
}
