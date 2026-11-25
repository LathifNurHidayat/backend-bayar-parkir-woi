package auth

import (
	"context"
	"database/sql"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{
		db: db,
	}
}

func (r *Repository) FindByUsername(
	ctx context.Context,
	username string,
) (*User, error) {
	const query = `
		SELECT
			u.user_id,
			u.employee_id,
			u.username,
			u.password_hash,
			e.employee_code,
			e.employee_name
		FROM mst_user u
		JOIN mst_employee e
			ON e.employee_id = u.employee_id
		WHERE LOWER(u.username) = LOWER($1)
			AND u.is_active = 1
			AND e.is_active = 1
		LIMIT 1
	`

	user := &User{}

	err := r.db.QueryRowContext(ctx, query, username).Scan(
		&user.UserID,
		&user.EmployeeID,
		&user.Username,
		&user.PasswordHash,
		&user.EmployeeCode,
		&user.EmployeeName,
	)

	if err != nil {
		return nil, err
	}

	roles, err := r.findActiveRoles(ctx, user.UserID)

	user.Roles = roles

	return user, nil
}

func (r *Repository) findActiveRoles(
	ctx context.Context,
	userID int64,
) ([]Role, error) {
	const query = `
		SELECT
			r.role_code,
			r.role_name
		FROM dat_user_role ur
		JOIN mst_role r
			ON r.role_id = ur.role_id
		WHERE ur.user_id = $1
			AND ur.is_active = 1
			AND r.is_active = 1
		ORDER BY r.role_code
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	roles := make([]Role, 0)

	for rows.Next() {
		var role Role

		if err := rows.Scan(
			&role.RoleCode,
			&role.RoleName,
		); err != nil {
			return nil, err
		}

		roles = append(roles, role)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return roles, nil
}
