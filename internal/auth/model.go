package auth

type User struct {
	UserID       int64
	EmployeeID   int64
	Username     string
	PasswordHash string
	EmployeeCode string
	EmployeeName string
	Roles        []Role
}

type Role struct {
	RoleCode string
	RoleName string
}
