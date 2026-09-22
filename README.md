# SIGAP (Sistem Pengaturan Fase Lampu Adaptif)

**SIGAP** adalah sistem pendukung keputusan (*Decision Support System*) untuk pengaturan fase lampu lalu lintas adaptif berbasis analisis video CCTV pada **Perempatan Jl. Ibrahim Adjie, sisi Mall Tenth Avenue, Bandung**.

> [!IMPORTANT]
> **Pernyataan Batasan Sistem:**
> SIGAP **bukan** pengganti sistem ATCS fisik Bandung Command Center dan **tidak terhubung** ke kontroler lampu lalu lintas asli di lapangan. Pada prototype ini, integrasi ATCS dimodelkan melalui **simulator mode operasi** dan **simulator siklus fase lampu**.
> 
> Sistem ini menghitung volume kendaraan anonim yang sedang berada pada zona antrean per arah dan per lajur. **Sistem TIDAK menggunakan *vehicle tracking*, tidak memiliki *tracking ID*, serta tidak memindai plat nomor maupun wajah pengendara.**

---

## 1. Arsitektur Singkat

SIGAP dibangun dengan pendekatan monorepo berbasis 4 service terisolasi:

1. **Frontend (`frontend/`):** Vue 3 + Vite. Bertanggung jawab murni atas dashboard visualisasi operator, pemantauan status 4 arah CCTV, diagram fase sinyal lampu, dan tombol intervensi (*operator override*).
2. **Backend Utama (`backend/`):** Laravel REST API. Menangani logika utama, registrasi simpang & geometrik lajur, database, algoritma heuristik pengaturan lampu, status sistem, transisi sinyal, dan logika *fallback* ke ATCS normal.
2. **Backend Utama (`backend/`):** Laravel REST API (Laravel 12 standar). Menangani logika konfigurasi geometrik simpang, relasi PostgreSQL, algoritma heuristik pengaturan lampu, status operasional sistem, transisi fase sinyal, dan logika *fallback* ke ATCS normal.
3. **AI Service (`ai-service/`):** Python FastAPI. Khusus menangani pembacaan video stream, inferensi deteksi kendaraan (YOLOv13 pada tahap lanjutan), penghitungan kendaraan per zona antrean, dan pengiriman payload ke Laravel.
4. **Database (`database/`):** PostgreSQL 16. Menyimpan seluruh data konfigurasi geometrik simpang, status operasional, serta riwayat keputusan dan fase lampu untuk bahan perbandingan evaluasi kinerja ATCS normal vs adaptif.
4. **Database (`database/`):** PostgreSQL 16. Menyimpan seluruh data konfigurasi geometrik simpang, status operasional, serta riwayat keputusan dan fase lampu untuk bahan perbandingan evaluasi kinerja ATCS normal vs adaptif. Seluruh skema dikelola melalui **Laravel Migrations** sebagai sumber kebenaran tunggal (*single source of truth*).

---

## 2. Struktur Direktori Monorepo

```
SIGAP/
├── frontend/                     # Vue 3 + Vite Operator Dashboard
│   ├── src/
│   │   ├── App.vue               # Komponen Dashboard Utama
│   │   ├── main.js
│   │   └── style.css
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   ├── nginx.conf                # Nginx config untuk container
│   └── Dockerfile
├── backend/                      # Laravel REST API & Simulator Heuristik
├── backend/                      # Laravel REST API Standar & Database Management
│   ├── app/
│   │   └── Http/Controllers/
│   │       └── HealthController.php
│   │   ├── Http/Controllers/
│   │   │   ├── HealthController.php
│   │   │   └── IntersectionController.php
│   │   ├── Http/Resources/       # Resource Transformer API
│   │   │   ├── IntersectionResource.php
│   │   │   ├── ApproachResource.php
│   │   │   ├── LaneResource.php
│   │   │   ├── CameraResource.php
│   │   │   ├── SystemStatusResource.php
│   │   │   └── SignalPhaseResource.php
│   │   └── Models/               # 9 Eloquent Models
│   │       ├── Intersection.php
│   │       ├── Approach.php
│   │       ├── Lane.php
│   │       ├── Camera.php
│   │       ├── SystemStatus.php
│   │       ├── TrafficMeasurement.php
│   │       ├── SignalPhase.php
│   │       ├── HeuristicDecision.php
│   │       └── SystemStatusLog.php
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   │   ├── migrations/           # 9 File Migrasi PostgreSQL
│   │   └── seeders/              # Seeder Simpang Jl. Ibrahim Adjie
│   ├── public/
│   │   └── index.php
│   │   └── index.php             # Request Runner Standar
│   ├── routes/
│   │   └── api.php               # Endpoint GET /api/health
│   ├── composer.json
│   │   └── api.php               # Rute Health & Konfigurasi Simpang
│   ├── tests/
│   │   ├── Feature/
│   │   │   ├── HealthTest.php
│   │   │   └── IntersectionApiTest.php
│   │   └── TestCase.php
│   ├── artisan                   # CLI Artisan Standar
│   ├── composer.json             # Dependensi Resmi Laravel
│   ├── phpunit.xml               # Konfigurasi Pengujian (pgsql)
│   ├── .env.example
│   └── Dockerfile
├── ai-service/                   # Python FastAPI AI Inference Service
│   ├── app/
│   │   ├── __init__.py
│   │   └── main.py               # Endpoint GET /health
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
├── database/                     # Skema & Rancangan Database PostgreSQL
│   ├── erd/
│   │   └── README.md             # Diagram Relasi Entitas (Mermaid)
│   │   └── README.md             # Diagram Relasi Entitas 9 Tabel (Mermaid)
│   └── schema/
│       └── 01_init.sql           # Inisialisasi Tabel & Seed Data Simpang
│       └── 01_init.sql           # Inisialisasi Ekstensi PostgreSQL
├── docs/                         # Dokumentasi Teknis & Arsitektur
│   ├── api.md                    # Dokumentasi Lengkap Endpoint REST API
│   └── architecture.md           # Arsitektur Lengkap & Alur Data
├── docker-compose.yml            # Orkestrasi Seluruh Service
├── .env.example                  # Template Variabel Lingkungan Global
├── README.md                     # Dokumentasi Utama
└── .gitignore
```

---

## 3. Prasyarat Sistem

Untuk menjalankan seluruh service secara terorkestrasi:
- **Docker Engine** (versi 24.0 atau lebih baru)
- **Docker Compose** (versi 2.20 atau lebih baru) / Docker Desktop
- Port lokal yang tersedia: `3000`, `8000`, `8001`, `5432`

*(Opsional untuk pengembangan lokal tanpa Docker):*
- Node.js >= 18 & npm >= 9
- Python >= 3.10
- PHP >= 8.2 dengan ekstensi `pdo_pgsql`
- PostgreSQL >= 15
- PHP >= 8.3 dengan ekstensi: `pdo_pgsql`, `pgsql`, `mbstring`, `curl`, `openssl`, `fileinfo`, `zip`
- Composer >= 2.8

---

## 4. Cara Menjalankan dengan Docker Compose
## 4. Cara Menjalankan Backend & Basis Data

1. **Salin file environment:**
### A. Menjalankan dengan Docker Compose (Direkomendasikan)
1. Salin environment:
   ```bash
   cp .env.example .env
   cp backend/.env.example backend/.env
   cp ai-service/.env.example ai-service/.env
   ```

2. **Build dan jalankan seluruh container:**
2. Jalankan database PostgreSQL:
   ```bash
   docker compose up --build -d
   docker compose up -d db
   ```

3. **Periksa status container:**
3. Jalankan migrasi dan seeder dari host atau container:
   ```bash
   docker compose ps
   docker compose run --rm backend php artisan migrate --seed
   ```
4. Jalankan seluruh container:
   ```bash
   docker compose up -d
   ```

4. **Hentikan service jika selesai:**
### B. Menjalankan Backend Secara Lokal (Host Development)
1. Masuk ke direktori backend dan siapkan environment:
   ```bash
   docker compose down
   cd backend
   cp .env.example .env
   php artisan key:generate
   ```
2. Setelah PostgreSQL aktif (baik via Docker `docker compose up -d db` atau PostgreSQL lokal port 5432):
   ```bash
   php artisan migrate --seed
   ```
3. Menjalankan server development:
   ```bash
   php artisan serve --port=8000
   ```
   Atau menggunakan PHP built-in server:
   ```bash
   php -S 0.0.0.0:8000 -t public
   ```

---

## 5. URL Lokal Layanan
## 5. Pengujian (Testing)

| Service | Port Host | URL / Endpoint | Keterangan |
| :--- | :--- | :--- | :--- |
| **Frontend Dashboard** | `3000` | [http://localhost:3000](http://localhost:3000) | Dashboard Operator Vue 3 |
| **Backend REST API** | `8000` | [http://localhost:8000/api/health](http://localhost:8000/api/health) | Endpoint Health & DB Check |
| **AI Service (FastAPI)** | `8001` | [http://localhost:8001/health](http://localhost:8001/health) | Endpoint Health AI Service |
| **Swagger AI Docs** | `8001` | [http://localhost:8001/docs](http://localhost:8001/docs) | Dokumentasi Interaktif FastAPI |
| **Database PostgreSQL** | `5432` | `localhost:5432` | DB: `sigap_db`, User: `sigap_user` |
Pengujian backend menggunakan PHPUnit standar Laravel dengan driver database PostgreSQL (`phpunit.xml`):

```bash
cd backend

# Menjalankan pengujian endpoint kesehatan (non-database / graceful offline check)
./vendor/bin/phpunit --filter HealthTest

# Menjalankan seluruh pengujian (memerlukan koneksi PostgreSQL aktif)
./vendor/bin/phpunit
```

> [!NOTE]
> Sesuai prinsip pelaporan transparan: jika service PostgreSQL belum aktif pada port 5432, pengujian migrasi dan integrasi database berstatus *unverified* hingga service PostgreSQL dinyalakan. Kami tidak mengganti konfigurasi PostgreSQL dengan SQLite dalam pengujian.

---

## 6. Status Implementasi Saat Ini (Tahap 1 - Baseline)
## 6. Daftar Endpoint REST API Read-Only (Tahap 2)

Dokumentasi lengkap contoh request dan respons JSON tersedia pada [docs/api.md](docs/api.md).

| Method | Endpoint | Keterangan |
|:---|:---|:---|
| `GET` | `/api/health` | Status kesehatan backend & konektivitas database |
| `GET` | `/api/intersections` | Daftar seluruh simpang terdaftar beserta detail geometrik |
| `GET` | `/api/intersections/{id}` | Detail geometrik 1 simpang spesifik |
| `GET` | `/api/intersections/{id}/approaches` | Daftar 4 arah masuk (*approaches*) & 8 lajur (*lanes*) |
| `GET` | `/api/intersections/{id}/cameras` | Daftar 4 kamera CCTV pada simpang |
| `GET` | `/api/intersections/{id}/system-status` | Status operasional terkini simpang |
| `GET` | `/api/intersections/{id}/signal-phases` | Konfigurasi fase lampu sinyal & parameter durasi |

---

## 7. Status Implementasi

### Tahap 1: Baseline Prototype
- [x] Struktur monorepo lengkap (`frontend`, `backend`, `ai-service`, `database`, `docs`).
- [x] Kontainerisasi Docker Compose untuk 4 service (`frontend`, `backend`, `ai-service`, `db`).
- [x] Endpoint `GET /api/health` pada Laravel Backend (verifikasi status API dan konektivitas PostgreSQL).
- [x] Endpoint `GET /health` pada FastAPI AI Service.
- [x] Halaman dashboard awal Vue 3 bertuliskan **“SIGAP Dashboard”** dengan indikator status konektivitas service dan visualisasi 4 sisi simpang.
- [x] Template skema database PostgreSQL (`database/schema/01_init.sql`) dan dokumentasi ERD (`database/erd/README.md`).
- [x] Konfigurasi environment (`.env.example` di root, `backend/.env.example`, `ai-service/.env.example`).
- [x] Dokumentasi arsitektur sistem komprehensif (`docs/architecture.md`).
- [x] **Kepatuhan Batasan:** Belum ada implementasi model YOLOv13, tracking ID, pembacaan plat nomor/wajah, ataupun logika heuristik fase penuh pada tahap ini.
- [x] Endpoint `GET /api/health` pada Laravel Backend dan `GET /health` pada FastAPI AI Service.
- [x] Halaman dashboard awal Vue 3 operator.
- [x] Dokumentasi arsitektur sistem awal.

### Tahap 2: Fondasi Backend Laravel, Migrasi PostgreSQL, Seeder, Model & REST API Simpang
- [x] Audit dan konversi backend menjadi aplikasi **Laravel standar** yang dapat dijalankan penuh melalui Composer dan Artisan.
- [x] Penegakan **Laravel Migrations sebagai single source of truth** struktur basis data.
- [x] 9 File migrasi tabel relasional PostgreSQL:
  - `intersections`
  - `approaches`
  - `lanes`
  - `cameras`
  - `system_statuses`
  - `traffic_measurements` (termasuk kolom komposisi kelas `vehicle_class_counts` & `occupancy_percentage`)
  - `signal_phases` (batas: hijau min 15s, max 60s, kuning 3s, all-red 2s)
  - `heuristic_decisions`
  - `system_status_logs`
- [x] 9 Eloquent Model dengan relasi lengkap dan type-casting.
- [x] Database Seeder konfigurasi awal simpang:
  - 1 Simpang: Perempatan Jl. Ibrahim Adjie Sisi Mall Tenth Avenue (`BDG-IBR-ADJ-01`).
  - 4 Arah Masuk: Barat, Utara, Timur, Selatan.
  - 8 Lajur: 2 lajur per arah (`outer` & `inner`).
  - 4 Kamera CCTV: `CCTV Barat`, `CCTV Utara`, `CCTV Timur`, `CCTV Selatan` (status awal: `UNCONFIGURED`, stream: `null`).
  - Status Awal: Mode `ATCS_NORMAL`, AI & CCTV healthy: `false` (kejujuran status belum tersambung ke kamera fisik).
  - Fase Lampu: Fase Barat-Timur aktif (durasi simulasi default 30 detik) dan Fase Utara-Selatan (durasi default 25 detik).
- [x] 7 Endpoint REST API read-only dengan Laravel API Resources.
- [x] Pengujian otomatis PHPUnit Feature test (`HealthTest` & `IntersectionApiTest`).
- [x] Dokumentasi API interaktif pada `docs/api.md` dan ERD pada `database/erd/README.md`.
- [x] **Kepatuhan Batasan Mutlak:**
  - Tidak ada model atau bobot YOLOv13.
  - Tidak ada pembacaan video stream CCTV.
  - Tidak ada vehicle tracking atau tracking ID.
  - Tidak ada implementasi algoritma heuristik.
  - Tidak ada data CCTV palsu di `traffic_measurements` maupun keputusan tiruan di `heuristic_decisions`.
  - Tidak ada koneksi fisik ke lampu lalu lintas asli.

---

## 7. Roadmap Pengembangan Tahap Berikutnya
## 8. Roadmap Pengembangan Tahap Berikutnya

1. **Tahap 2: Detail Geometrik Simpang & Visualisasi Dashboard**
   - Pemetaan poligon zona antrean untuk 4 arah (Barat, Utara, Timur, Selatan) dan 2 lajur per arah (luar & dalam).
   - Penyempurnaan antarmuka dashboard operator dengan kontrol simulator mode (Adaptive, Normal, Fallback, Override).
2. **Tahap 3: AI Service & Penghitungan Antrean**
1. **Tahap 3: AI Service & Penghitungan Antrean**
   - Integrasi model YOLOv13 untuk 6 kelas kendaraan (motor, mobil, bus, truk, ambulans, pemadam).
   - Logika penentuan posisi kendaraan dalam poligon zona antrean per lajur tanpa tracking ID.
   - Endpoint pengiriman payload periodik ke Laravel backend.
3. **Tahap 4: Logika Heuristik Lampu & Simulator ATCS di Laravel**
   - Endpoint pengiriman payload periodik ke tabel `traffic_measurements` di Laravel backend.
2. **Tahap 4: Logika Heuristik Lampu & Simulator ATCS di Laravel**
   - Implementasi formula skor antrean berbasis volume, bobot kendaraan, dan *waiting time*.
   - Logika transisi keselamatan sinyal (Hijau $\rightarrow$ Kuning $\rightarrow$ All-Red $\rightarrow$ Hijau).
   - Logika deteksi anomali untuk *automatic fallback* ke mode ATCS normal jika AI atau video tidak merespons.
4. **Tahap 5: Evaluasi & Komparasi Kinerja**
3. **Tahap 5: Dashboard Operator & Evaluasi Kinerja**
   - Integrasi visualisasi antarmuka operator dengan kontrol simulator mode (Adaptive, Normal, Fallback, Override).
   - Pencatatan log metrik dan visualisasi perbandingan efisiensi waktu tunggu antara mode ATCS normal *fixed-time* versus SIGAP adaptif.

