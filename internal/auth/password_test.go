package auth

import "testing"

func TestHashPassword(t *testing.T) {
	password := "password123"

	hash, err := HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword() error = %v", err)
	}

	if hash == "" {
		t.Fatal("HashPassword() returned empty hash")
	}

	if hash == password {
		t.Fatal("password must not be stored as plain text")
	}

	if !VerifyPassword(password, hash) {
		t.Fatal("VerifyPassword() should accept correct password")
	}
}

func TestVerifyPasswordWrongPassword(t *testing.T) {
	password := "password123"

	hash, err := HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword() error = %v", err)
	}

	if VerifyPassword("wrong-password", hash) {
		t.Fatal("VerifyPassword() should reject wrong password")
	}
}

func TestHashPasswordProducesDifferentHashes(t *testing.T) {
	password := "password123"

	hash1, err := HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword() error = %v", err)
	}

	hash2, err := HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword() error = %v", err)
	}

	if hash1 == hash2 {
		t.Fatal("same password should produce different hashes")
	}
}
