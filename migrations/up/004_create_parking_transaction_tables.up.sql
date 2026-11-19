-- 1. dat_parking_ticket
-- Transaksi kendaraan masuk dan keluar

CREATE TABLE dat_parking_ticket (
    parking_ticket_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('dat_parking_ticket'),
    parking_location_id BIGINT NOT NULL,
    vehicle_type_id BIGINT NOT NULL,
    plate_number VARCHAR(20) NOT NULL,
    entry_employee_id BIGINT NOT NULL,
    exit_employee_id BIGINT,

    entry_at TIMESTAMPTZ NOT NULL,
    exit_at TIMESTAMPTZ,

    hourly_rate_snapshot BIGINT NOT NULL,
    total_fee BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'PARKED',

    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    -- Foreign keys
    CONSTRAINT fk_parking_ticket_location
        FOREIGN KEY (parking_location_id)
        REFERENCES mst_parking_location (parking_location_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_parking_ticket_vehicle
        FOREIGN KEY (vehicle_type_id)
        REFERENCES mst_vehicle_type (vehicle_type_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_parking_ticket_entry_employee
        FOREIGN KEY (entry_employee_id)
        REFERENCES mst_employee (employee_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_parking_ticket_exit_employee
        FOREIGN KEY (exit_employee_id)
        REFERENCES mst_employee (employee_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    -- Validasi tarif dan biaya
    CONSTRAINT chk_parking_ticket_hourly_rate
        CHECK (hourly_rate_snapshot >= 0),

    CONSTRAINT chk_parking_ticket_total_fee
        CHECK (total_fee IS NULL OR total_fee >= 0),

    -- Validasi status
    CONSTRAINT chk_parking_ticket_status
        CHECK (status IN ('PARKED', 'PAID', 'COMPLETED')),

    -- Tiket yang sudah dibayar harus memiliki total_fee
    CONSTRAINT chk_parking_ticket_paid_fee
        CHECK (
            status = 'PARKED'
            OR total_fee IS NOT NULL
        ),

    -- Validasi waktu dan petugas keluar
    CONSTRAINT chk_parking_ticket_exit
        CHECK (
            (
                status IN ('PARKED', 'PAID')
                AND exit_at IS NULL
                AND exit_employee_id IS NULL
            )
            OR
            (
                status = 'COMPLETED'
                AND exit_at IS NOT NULL
                AND exit_employee_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_parking_ticket_is_active
        CHECK (is_active IN (0, 1))
);


-- Satu kendaraan tidak boleh memiliki lebih dari satu tiket aktif pada lokasi parkir yang sama.
-- Spasi pada nomor polisi diabaikan dan huruf dibuat uppercase.
CREATE UNIQUE INDEX uq_parking_ticket_active_plate
    ON dat_parking_ticket (
        parking_location_id,
        (
            REGEXP_REPLACE(
                UPPER(BTRIM(plate_number)),
                '\s+',
                '',
                'g'
            )
        )
    )
    WHERE status IN ('PARKED', 'PAID');


-- Index untuk pencarian transaksi
CREATE INDEX idx_parking_ticket_location_entry
    ON dat_parking_ticket (
        parking_location_id,
        entry_at DESC
    );

CREATE INDEX idx_parking_ticket_location_status
    ON dat_parking_ticket (
        parking_location_id,
        status
    );

CREATE INDEX idx_parking_ticket_entry_employee
    ON dat_parking_ticket (entry_employee_id);


-- 2. dat_payment
-- Transaksi pembayaran parkir
CREATE TABLE dat_payment (
    payment_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('dat_payment'),
    parking_ticket_id BIGINT NOT NULL,
    payment_employee_id BIGINT NOT NULL,

    payment_method VARCHAR(20) NOT NULL DEFAULT 'CASH',

    total_amount BIGINT NOT NULL,
    amount_paid BIGINT NOT NULL,
    change_amount BIGINT NOT NULL,

    paid_at TIMESTAMPTZ NOT NULL,

    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),

    is_active SMALLINT NOT NULL DEFAULT 1,

    -- Foreign keys
    CONSTRAINT fk_payment_parking_ticket
        FOREIGN KEY (parking_ticket_id)
        REFERENCES dat_parking_ticket (parking_ticket_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_payment_employee
        FOREIGN KEY (payment_employee_id)
        REFERENCES mst_employee (employee_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    -- Satu tiket hanya boleh memiliki satu pembayaran
    CONSTRAINT uq_payment_parking_ticket
        UNIQUE (parking_ticket_id),

    -- Validasi metode pembayaran
    CONSTRAINT chk_payment_method
        CHECK (payment_method = 'CASH'),

    -- Validasi nominal pembayaran
    CONSTRAINT chk_payment_total_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_payment_amount_paid
        CHECK (amount_paid >= total_amount),

    CONSTRAINT chk_payment_change_amount
        CHECK (
            change_amount = amount_paid - total_amount
            AND change_amount >= 0
        ),

    CONSTRAINT chk_payment_is_active
        CHECK (is_active IN (0, 1))
);


-- Index untuk laporan pembayaran
CREATE INDEX idx_payment_employee_paid_at
    ON dat_payment (
        payment_employee_id,
        paid_at DESC
    );

CREATE INDEX idx_payment_paid_at
    ON dat_payment (paid_at DESC);
