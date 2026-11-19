
-- 1. dat_user_role
CREATE TABLE dat_user_role (
    user_role_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('dat_user_role'),
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
        REFERENCES mst_user (user_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_user_role_role
        FOREIGN KEY (role_id)
        REFERENCES mst_role (role_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT uq_user_role
        UNIQUE (user_id, role_id),

    CONSTRAINT chk_user_role_is_active
        CHECK (is_active IN (0, 1))
);

CREATE INDEX idx_user_role_role_id
    ON dat_user_role (role_id);


-- 2. dat_employee_parking_location
-- Relasi pegawai dengan lokasi parkir
CREATE TABLE dat_employee_parking_location (
    employee_parking_location_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('dat_employee_parking_location'),
    employee_id BIGINT NOT NULL,
    parking_location_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT fk_employee_location_employee
        FOREIGN KEY (employee_id)
        REFERENCES mst_employee (employee_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_employee_location_parking
        FOREIGN KEY (parking_location_id)
        REFERENCES mst_parking_location (parking_location_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT uq_employee_parking_location
        UNIQUE (employee_id, parking_location_id),

    CONSTRAINT chk_employee_location_is_active
        CHECK (is_active IN (0, 1))
);

CREATE INDEX idx_employee_parking_location_location
    ON dat_employee_parking_location (parking_location_id);


-- 3. mst_parking_tariff
-- Tarif per lokasi dan jenis kendaraan

CREATE TABLE mst_parking_tariff (
    parking_tariff_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_parking_tariff'),
    parking_location_id BIGINT NOT NULL,
    vehicle_type_id BIGINT NOT NULL,
    hourly_rate BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT fk_parking_tariff_location
        FOREIGN KEY (parking_location_id)
        REFERENCES mst_parking_location (parking_location_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_parking_tariff_vehicle
        FOREIGN KEY (vehicle_type_id)
        REFERENCES mst_vehicle_type (vehicle_type_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT uq_parking_tariff_location_vehicle
        UNIQUE (parking_location_id, vehicle_type_id),

    CONSTRAINT chk_parking_tariff_hourly_rate
        CHECK (hourly_rate >= 0),

    CONSTRAINT chk_parking_tariff_is_active
        CHECK (is_active IN (0, 1))
);

CREATE INDEX idx_parking_tariff_vehicle_type
    ON mst_parking_tariff (vehicle_type_id);
