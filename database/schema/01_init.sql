-- ============================================================
-- SIGAP Baseline Database Schema (PostgreSQL)
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

-- 1. Tabel Konfigurasi Simpang
CREATE TABLE IF NOT EXISTS intersections (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Arah Masuk Simpang (4 Arah: Barat, Utara, Timur, Selatan)
CREATE TABLE IF NOT EXISTS approaches (
    id SERIAL PRIMARY KEY,
    intersection_id INT NOT NULL REFERENCES intersections(id) ON DELETE CASCADE,
    direction VARCHAR(20) NOT NULL CHECK (direction IN ('NORTH', 'SOUTH', 'EAST', 'WEST')),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabel Lajur Masuk (Per Arah: Lajur Luar dan Lajur Dalam)
CREATE TABLE IF NOT EXISTS lanes (
    id SERIAL PRIMARY KEY,
    approach_id INT NOT NULL REFERENCES approaches(id) ON DELETE CASCADE,
    lane_type VARCHAR(20) NOT NULL CHECK (lane_type IN ('OUTER_LANE', 'INNER_LANE')),
    movement_rules VARCHAR(100) NOT NULL, -- Contoh: 'LEFT_OR_STRAIGHT', 'STRAIGHT_OR_RIGHT'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabel Status Operasional Sistem (Simulator ATCS vs SIGAP)
CREATE TABLE IF NOT EXISTS system_status (
    id SERIAL PRIMARY KEY,
    current_mode VARCHAR(50) NOT NULL DEFAULT 'ATCS_NORMAL' 
        CHECK (current_mode IN ('SIGAP_ADAPTIVE', 'ATCS_NORMAL', 'FALLBACK_ATCS', 'OPERATOR_OVERRIDE')),
    is_ai_healthy BOOLEAN DEFAULT TRUE,
    is_cctv_healthy BOOLEAN DEFAULT TRUE,
    notes TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabel Riwayat Keputusan dan Fase Lampu (Simulator)
CREATE TABLE IF NOT EXISTS traffic_phase_logs (
    id BIGSERIAL PRIMARY KEY,
    intersection_id INT NOT NULL REFERENCES intersections(id) ON DELETE CASCADE,
    active_phase VARCHAR(50) NOT NULL, -- e.g., 'EAST_WEST', 'NORTH_SOUTH'
    phase_color VARCHAR(20) NOT NULL CHECK (phase_color IN ('GREEN', 'YELLOW', 'ALL_RED')),
    duration_seconds INT NOT NULL,
    mode VARCHAR(50) NOT NULL,
    decision_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Data Awal Simpang Jl. Ibrahim Adjie
-- ============================================================
INSERT INTO intersections (code, name, location, description)
VALUES (
    'BDG-IBR-ADJ-01',
    'Perempatan Jl. Ibrahim Adjie - Mall Tenth Avenue',
    'Bandung, Jawa Barat',
    'Simpang 4 lengan prototype modul pendukung ATCS adaptif SIGAP'
) ON CONFLICT (code) DO NOTHING;

-- Seed Arah Masuk
INSERT INTO approaches (intersection_id, direction, name)
SELECT id, 'NORTH', 'Arah Utara' FROM intersections WHERE code = 'BDG-IBR-ADJ-01'
ON CONFLICT DO NOTHING;

INSERT INTO approaches (intersection_id, direction, name)
SELECT id, 'SOUTH', 'Arah Selatan' FROM intersections WHERE code = 'BDG-IBR-ADJ-01'
ON CONFLICT DO NOTHING;

INSERT INTO approaches (intersection_id, direction, name)
SELECT id, 'EAST', 'Arah Timur' FROM intersections WHERE code = 'BDG-IBR-ADJ-01'
ON CONFLICT DO NOTHING;

INSERT INTO approaches (intersection_id, direction, name)
SELECT id, 'WEST', 'Arah Barat' FROM intersections WHERE code = 'BDG-IBR-ADJ-01'
ON CONFLICT DO NOTHING;

-- Seed Status Awal Sistem
INSERT INTO system_status (current_mode, is_ai_healthy, is_cctv_healthy, notes)
VALUES ('ATCS_NORMAL', TRUE, TRUE, 'Sistem awal berjalan dalam mode simulasi normal ATCS');

-- Komentar status inisialisasi basis data
COMMENT ON DATABASE current_database() IS 'SIGAP Database - Schema and tables managed by Laravel Migrations';
