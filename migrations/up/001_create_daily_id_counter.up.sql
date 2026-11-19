-- ##
-- CREATE DAILY ID COUNTER

CREATE TABLE sys_daily_id_counter (
    id BIGSERIAL PRIMARY KEY,

    table_name VARCHAR(100) NOT NULL,
    counter_date DATE NOT NULL,
    last_number INTEGER NOT NULL,

    CONSTRAINT uq_daily_id_counter
        UNIQUE (table_name, counter_date),

    CONSTRAINT chk_daily_id_counter_last_number
        CHECK (last_number BETWEEN 1 AND 999999),

    CONSTRAINT chk_daily_id_counter_table_name
        CHECK (table_name ~ '^(mst|dat)_[a-z0-9_]+$')
);


-- ##
-- FUNCTION: GENERATE DAILY ID

CREATE OR REPLACE FUNCTION generate_daily_id(
    p_table_name VARCHAR(100)
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_counter_date DATE;
    v_next_number INTEGER;
    v_generated_id BIGINT;
BEGIN
    -- Validasi nama tabel.
    IF p_table_name !~ '^(mst|dat)_[a-z0-9_]+$' THEN
        RAISE EXCEPTION 'Invalid table name: %', p_table_name;
    END IF;

    -- Get tanggal by timezone Asia/Jakarta.
    v_counter_date :=
        (clock_timestamp() AT TIME ZONE 'Asia/Jakarta')::DATE;

    -- Atomic insert / update counter.
    INSERT INTO sys_daily_id_counter (
        table_name,
        counter_date,
        last_number
    )
    VALUES (
        p_table_name,
        v_counter_date,
        1
    )
    ON CONFLICT (table_name, counter_date)
    DO UPDATE SET
        last_number =
            sys_daily_id_counter.last_number + 1
    WHERE
        sys_daily_id_counter.last_number < 999999
    RETURNING last_number INTO v_next_number;

    -- jika nomor harian sudah habis.
    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Daily ID limit reached for table: %',
            p_table_name;
    END IF;

    -- generate format YYMMDDNNNNNN
    -- example : 261119000001
    v_generated_id := (
        TO_CHAR(v_counter_date, 'YYMMDD') ||
        LPAD(v_next_number::TEXT, 6, '0')
    )::BIGINT;

    RETURN v_generated_id;
END;
$$;
