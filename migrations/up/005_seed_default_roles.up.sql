-- MIGRATION 005
-- Seed default roles

INSERT INTO mst_role (
    role_code,
    role_name,
    description,
    created_at,
    created_by
)
VALUES
(
    'ADMIN',
    'Administrator',
    'Memiliki akses administrasi ke seluruh lokasi parkir.',
    NOW(),
    'SYSTEM - MIGRATION'
),
(
    'OPERATOR',
    'Operator',
    'Memiliki akses operasional berdasarkan penempatan lokasi parkir.',
    NOW(),
    'SYSTEM - MIGRATION'
)
ON CONFLICT (role_code) DO NOTHING;
