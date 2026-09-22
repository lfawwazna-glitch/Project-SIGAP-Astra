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
3. **AI Service (`ai-service/`):** Python FastAPI. Khusus menangani pembacaan video stream, inferensi deteksi kendaraan (YOLOv13 pada tahap lanjutan), penghitungan kendaraan per zona antrean, dan pengiriman payload ke Laravel.
4. **Database (`database/`):** PostgreSQL 16. Menyimpan seluruh data konfigurasi geometrik simpang, status operasional, serta riwayat keputusan dan fase lampu untuk bahan perbandingan evaluasi kinerja ATCS normal vs adaptif.

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
│   ├── app/
│   │   └── Http/Controllers/
│   │       └── HealthController.php
│   ├── bootstrap/
│   ├── config/
│   ├── public/
│   │   └── index.php
│   ├── routes/
│   │   └── api.php               # Endpoint GET /api/health
│   ├── composer.json
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
│   └── schema/
│       └── 01_init.sql           # Inisialisasi Tabel & Seed Data Simpang
├── docs/                         # Dokumentasi Teknis & Arsitektur
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

---

## 4. Cara Menjalankan dengan Docker Compose

1. **Salin file environment:**
   ```bash
   cp .env.example .env
   cp backend/.env.example backend/.env
   cp ai-service/.env.example ai-service/.env
   ```

2. **Build dan jalankan seluruh container:**
   ```bash
   docker compose up --build -d
   ```

3. **Periksa status container:**
   ```bash
   docker compose ps
   ```

4. **Hentikan service jika selesai:**
   ```bash
   docker compose down
   ```

---

## 5. URL Lokal Layanan

| Service | Port Host | URL / Endpoint | Keterangan |
| :--- | :--- | :--- | :--- |
| **Frontend Dashboard** | `3000` | [http://localhost:3000](http://localhost:3000) | Dashboard Operator Vue 3 |
| **Backend REST API** | `8000` | [http://localhost:8000/api/health](http://localhost:8000/api/health) | Endpoint Health & DB Check |
| **AI Service (FastAPI)** | `8001` | [http://localhost:8001/health](http://localhost:8001/health) | Endpoint Health AI Service |
| **Swagger AI Docs** | `8001` | [http://localhost:8001/docs](http://localhost:8001/docs) | Dokumentasi Interaktif FastAPI |
| **Database PostgreSQL** | `5432` | `localhost:5432` | DB: `sigap_db`, User: `sigap_user` |

---

## 6. Status Implementasi Saat Ini (Tahap 1 - Baseline)

- [x] Struktur monorepo lengkap (`frontend`, `backend`, `ai-service`, `database`, `docs`).
- [x] Kontainerisasi Docker Compose untuk 4 service (`frontend`, `backend`, `ai-service`, `db`).
- [x] Endpoint `GET /api/health` pada Laravel Backend (verifikasi status API dan konektivitas PostgreSQL).
- [x] Endpoint `GET /health` pada FastAPI AI Service.
- [x] Halaman dashboard awal Vue 3 bertuliskan **“SIGAP Dashboard”** dengan indikator status konektivitas service dan visualisasi 4 sisi simpang.
- [x] Template skema database PostgreSQL (`database/schema/01_init.sql`) dan dokumentasi ERD (`database/erd/README.md`).
- [x] Konfigurasi environment (`.env.example` di root, `backend/.env.example`, `ai-service/.env.example`).
- [x] Dokumentasi arsitektur sistem komprehensif (`docs/architecture.md`).
- [x] **Kepatuhan Batasan:** Belum ada implementasi model YOLOv13, tracking ID, pembacaan plat nomor/wajah, ataupun logika heuristik fase penuh pada tahap ini.

---

## 7. Roadmap Pengembangan Tahap Berikutnya

1. **Tahap 2: Detail Geometrik Simpang & Visualisasi Dashboard**
   - Pemetaan poligon zona antrean untuk 4 arah (Barat, Utara, Timur, Selatan) dan 2 lajur per arah (luar & dalam).
   - Penyempurnaan antarmuka dashboard operator dengan kontrol simulator mode (Adaptive, Normal, Fallback, Override).
2. **Tahap 3: AI Service & Penghitungan Antrean**
   - Integrasi model YOLOv13 untuk 6 kelas kendaraan (motor, mobil, bus, truk, ambulans, pemadam).
   - Logika penentuan posisi kendaraan dalam poligon zona antrean per lajur tanpa tracking ID.
   - Endpoint pengiriman payload periodik ke Laravel backend.
3. **Tahap 4: Logika Heuristik Lampu & Simulator ATCS di Laravel**
   - Implementasi formula skor antrean berbasis volume, bobot kendaraan, dan *waiting time*.
   - Logika transisi keselamatan sinyal (Hijau $\rightarrow$ Kuning $\rightarrow$ All-Red $\rightarrow$ Hijau).
   - Logika deteksi anomali untuk *automatic fallback* ke mode ATCS normal jika AI atau video tidak merespons.
4. **Tahap 5: Evaluasi & Komparasi Kinerja**
   - Pencatatan log metrik dan visualisasi perbandingan efisiensi waktu tunggu antara mode ATCS normal *fixed-time* versus SIGAP adaptif.
