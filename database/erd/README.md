# Entity Relationship Diagram (ERD) - SIGAP Database

Dokumen ini menjelaskan rancangan skema basis data PostgreSQL untuk prototype sistem **SIGAP** (Sistem Pendukung Keputusan Pengaturan Fase Lampu Lalu Lintas Adaptif) pada Perempatan Jl. Ibrahim Adjie - Mall Tenth Avenue, Bandung.

---

## 1. Diagram ERD (Mermaid)

```mermaid
erDiagram
    INTERSECTIONS ||--o{ APPROACHES : "memiliki 4 arah"
    INTERSECTIONS ||--o{ TRAFFIC_PHASE_LOGS : "mencatat riwayat fase"
    APPROACHES ||--o{ LANES : "memiliki 2 lajur"

    INTERSECTIONS {
        int id PK
        varchar code UK "BDG-IBR-ADJ-01"
        varchar name "Perempatan Jl. Ibrahim Adjie"
        varchar location "Bandung, Jawa Barat"
        text description
        timestamp created_at
        timestamp updated_at
    }

    APPROACHES {
        int id PK
        int intersection_id FK
        varchar direction "NORTH | SOUTH | EAST | WEST"
        varchar name
        timestamp created_at
    }

    LANES {
        int id PK
        int approach_id FK
        varchar lane_type "OUTER_LANE | INNER_LANE"
        varchar movement_rules "LEFT_OR_STRAIGHT | STRAIGHT_OR_RIGHT"
        timestamp created_at
    }

    SYSTEM_STATUS {
        int id PK
        varchar current_mode "SIGAP_ADAPTIVE | ATCS_NORMAL | FALLBACK_ATCS | OPERATOR_OVERRIDE"
        boolean is_ai_healthy
        boolean is_cctv_healthy
        text notes
        timestamp recorded_at
    }

    TRAFFIC_PHASE_LOGS {
        bigint id PK
        int intersection_id FK
        varchar active_phase "EAST_WEST | NORTH_SOUTH"
        varchar phase_color "GREEN | YELLOW | ALL_RED"
        int duration_seconds
        varchar mode
        text decision_reason
        timestamp created_at
    }
```

---

## 2. Penjelasan Entitas & Batasan Desain

1. **`intersections`**: Menyimpan identitas simpang fisik yang disimulasikan.
2. **`approaches`**: Merepresentasikan empat arah masuk simpang (Barat, Utara, Timur, Selatan).
3. **`lanes`**: Merepresentasikan dua lajur per arah (Lajur Luar: belok kiri / lurus; Lajur Dalam: lurus / belok kanan).
4. **`system_status`**: Mencatat status operasional aktif dan kondisi kesehatan komponen (AI, kamera, koneksi) untuk memicu logika fallback simulasi.
5. **`traffic_phase_logs`**: Menyimpan riwayat perubahan fase lampu (Hijau $\rightarrow$ Kuning $\rightarrow$ Semua Merah $\rightarrow$ Hijau) beserta alasan pengambilan keputusan untuk perbandingan evaluasi mode adaptif vs normal.

> [!IMPORTANT]
> **Privasi & Regulasi:**
> Skema database **TIDAK** menyimpan nomor plat kendaraan, gambar wajah, maupun ID pelacakan (*tracking ID*). Sistem hanya berfokus pada agregasi jumlah kendaraan dalam antrean.
