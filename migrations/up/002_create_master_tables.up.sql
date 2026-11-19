-- 1. mst_employee

CREATE TABLE mst_employee (
    employee_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_employee'),
    employee_code VARCHAR(30) NOT NULL,
    employee_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_employee_code 
        UNIQUE (employee_code),

    CONSTRAINT chk_employee_is_active 
        CHECK (is_active IN (0, 1))
);


-- 2. mst_user

CREATE TABLE mst_user (
    user_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_user'),
    employee_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_user_employee 
        UNIQUE (employee_id),

    CONSTRAINT fk_user_employee FOREIGN KEY (employee_id) 
        REFERENCES mst_employee (employee_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_user_is_active
        CHECK (is_active IN (0, 1))
);

-- Username tidak membedakan huruf besar dan kecil
CREATE UNIQUE INDEX uq_user_username_lower
    ON mst_user (LOWER(username));


-- 3. mst_role
CREATE TABLE mst_role (
    role_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_role'),
    role_code VARCHAR(30) NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_role_code
        UNIQUE (role_code),

    CONSTRAINT chk_role_is_active
        CHECK (is_active IN (0, 1))
);


-- 4. mst_parking_location
CREATE TABLE mst_parking_location (
    parking_location_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_parking_location'),
    location_code VARCHAR(30) NOT NULL,
    location_name VARCHAR(150) NOT NULL,
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_parking_location_code
        UNIQUE (location_code),

    CONSTRAINT chk_parking_location_is_active
        CHECK (is_active IN (0, 1))
);


-- 5. mst_vehicle_type
CREATE TABLE mst_vehicle_type (
    vehicle_type_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_vehicle_type'),
    vehicle_code VARCHAR(30) NOT NULL,
    vehicle_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_vehicle_type_code
        UNIQUE (vehicle_code),

    CONSTRAINT chk_vehicle_type_is_active
        CHECK (is_active IN (0, 1))
);