
CREATE TABLE mst_sys_identitas (
    sys_identitas_id BIGINT PRIMARY KEY DEFAULT generate_daily_id('mst_sys_identitas'),
    sys_identitas_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(150),
    fax VARCHAR(30),
    address VARCHAR(150),
    logo TEXT,
    


    created_at TIMESTAMPTZ NOT NULL,
    created_by VARCHAR(150) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(150),
    is_active SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT uq_sys_identitas_code 
        UNIQUE (sys_identitas_code),

    CONSTRAINT chk_sys_identitas_is_active 
        CHECK (is_active IN (0, 1))
);