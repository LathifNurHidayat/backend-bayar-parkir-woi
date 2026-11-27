package auth

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

var (
	ErrInvalidCredentials = errors.New("username atau password salah")
	ErrNoActiveRole       = errors.New("user tidak memiliki role aktif")
)

type Service struct {
	repository *Repository
	jwtSecret  []byte
	tokenTTL   time.Duration
}

type LoginResult struct {
	AccessToken string    `json:"access_token"`
	TokenType   string    `json:"token_type"`
	ExpiredIn   int64     `json:"expires_in"`
	User        LoginUser `json:"user"`
}

type LoginUser struct {
	UserID       int64  `json:"user_id"`
	EmployeeID   int64  `json:"employee_id"`
	Username     string `json:"username"`
	EmployeeCode string `json:"employee_code"`
	EmployeeName string `'json:"employee_name"`
	Roles        []Role `json:"roles"`
}

func NewService(
	repository *Repository,
	jwtSecret string,
	tokenTTL time.Duration,
) (*Service, error) {
	if len(jwtSecret) < 32 {
		return nil, errors.New("JWT secret minimal harus 32 karakter")
	}

	if tokenTTL <= 0 {
		return nil, errors.New("JWT token TTL harus lebih dari 0")
	}

	return &Service{
		repository: repository,
		jwtSecret:  []byte(jwtSecret),
		tokenTTL:   tokenTTL,
	}, nil
}

func (s *Service) Login(
	ctx context.Context,
	username string,
	password string,
) (*LoginResult, error) {
	user, err := s.repository.FindByUsername(ctx, username)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrInvalidCredentials
		}

		return nil, fmt.Errorf("find user: %w", err)
	}

	if !VerifyPassword(password, user.PasswordHash) {
		return nil, ErrInvalidCredentials
	}

	if len(user.Roles) == 0 {
		return nil, ErrNoActiveRole
	}

	accessToken, err := GenerateToken(
		user,
		s.jwtSecret,
		s.tokenTTL,
	)

	if err != nil {
		return nil, fmt.Errorf("generate access token: %w", err)
	}

	roles := make([]Role, len(user.Roles))
	copy(roles, user.Roles)

	return &LoginResult{
		AccessToken: accessToken,
		TokenType:   "Bearer",
		ExpiredIn:   int64(s.tokenTTL.Seconds()),
		User: LoginUser{
			UserID:       user.UserID,
			EmployeeID:   user.EmployeeID,
			Username:     user.Username,
			EmployeeCode: user.EmployeeCode,
			EmployeeName: user.EmployeeName,
			Roles:        roles,
		},
	}, nil
}
