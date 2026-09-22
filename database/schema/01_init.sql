-- ============================================================
-- SIGAP Baseline Database Initialization (PostgreSQL)
-- Simpang Jl. Ibrahim Adjie - Mall Tenth Avenue, Bandung
-- ============================================================
-- Catatan Arsitektur (Tahap 2):
-- Seluruh tabel inti SIGAP (intersections, approaches, lanes,
-- cameras, system_statuses, traffic_measurements, signal_phases,
-- heuristic_decisions, system_status_logs) dan seeder geometrik
-- dikelola sepenuhnya oleh Laravel Migration & Seeder sebagai
-- SINGLE SOURCE OF TRUTH skema basis data aplikasi.
--
-- File init SQL ini hanya bertugas menyiapkan ekstensi PostgreSQL
-- yang dibutuhkan database sebelum migrasi Laravel dijalankan.
-- ============================================================

-- Ekstensi UUID jika diperlukan untuk identifier unik
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Komentar status inisialisasi basis data
COMMENT ON DATABASE current_database() IS 'SIGAP Database - Schema and tables managed by Laravel Migrations';
