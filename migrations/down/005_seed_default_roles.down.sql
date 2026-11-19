-- ROLLBACK MIGRATION 005
-- !!hanya dapat dijalanan jika role belum digunakan.
DELETE FROM mst_role
WHERE role_code IN ('ADMIN', 'OPERATOR');
