package auth

import (
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type TokenClaims struct {
	UserID     int64    `json:"user_id"`
	EmployeeID int64    `json:"employee_id"`
	Roles      []string `json:"roles"`

	jwt.RegisteredClaims
}

func GenerateToken(
	user *User,
	secret []byte,
	expiredsIn time.Duration,
) (string, error) {
	now := time.Now().UTC()
	expiresAt := now.Add(expiredsIn)

	roles := make([]string, 0, len(user.Roles))
	for _, role := range user.Roles {
		roles = append(roles, role.RoleCode)
	}

	claims := TokenClaims{
		UserID:     user.UserID,
		EmployeeID: user.EmployeeID,
		Roles:      roles,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   strconv.FormatInt(user.UserID, 10),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString(secret)
}
