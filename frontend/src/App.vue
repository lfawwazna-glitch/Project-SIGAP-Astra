<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const backendStatus = ref('Mengecek...')
const backendDetails = ref(null)
const aiServiceStatus = ref('Mengecek...')
const aiServiceDetails = ref(null)
const activeMode = ref('SIMULASI_ATCS_NORMAL')

const backendUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api'
const aiServiceUrl = import.meta.env.VITE_AI_BASE_URL || 'http://localhost:8001'

const checkHealth = async () => {
  // Check Laravel Backend
  try {
    const res = await axios.get(`${backendUrl}/health`, { timeout: 3000 })
    backendStatus.value = 'ONLINE'
    backendDetails.value = res.data
    if (res.data.atcs_mode) {
      activeMode.value = res.data.atcs_mode
    }
  } catch (err) {
    backendStatus.value = 'OFFLINE / STANDBY'
    backendDetails.value = null
  }

  // Check FastAPI AI Service
  try {
    const res = await axios.get(`${aiServiceUrl}/health`, { timeout: 3000 })
    aiServiceStatus.value = 'ONLINE'
    aiServiceDetails.value = res.data
  } catch (err) {
    aiServiceStatus.value = 'OFFLINE / STANDBY'
    aiServiceDetails.value = null
  }
}

onMounted(() => {
  checkHealth()
  const interval = setInterval(checkHealth, 10000)
  return () => clearInterval(interval)
})
</script>

<template>
  <div class="dashboard-container">
    <!-- Header -->
    <header>
      <div class="title-group">
        <h1>🚦 SIGAP Dashboard</h1>
        <p>Sistem Pendukung Keputusan Pengaturan Fase Lampu Lalu Lintas Adaptif — Simpang Jl. Ibrahim Adjie (Mall Tenth Avenue), Bandung</p>
      </div>
      <div>
        <span class="badge badge-warning">Prototype Simulator ATCS</span>
      </div>
    </header>

    <!-- Status Cards Grid -->
    <div class="grid-cards">
      <!-- System Overview -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Status Operasi Simpang</span>
          <span class="badge badge-info">{{ activeMode }}</span>
        </div>
        <div class="status-row">
          <span class="status-label">Lokasi Simpang:</span>
          <span class="status-value">Jl. Ibrahim Adjie - Tenth Avenue</span>
        </div>
        <div class="status-row">
          <span class="status-label">Struktur Lengan:</span>
          <span class="status-value">4 Arah (B, U, T, S)</span>
        </div>
        <div class="status-row">
          <span class="status-label">Lajur Masuk:</span>
          <span class="status-value">2 Lajur / Arah (Luar & Dalam)</span>
        </div>
        <div class="status-row">
          <span class="status-label">Fase Aktif Saat Ini:</span>
          <span class="status-value">Barat - Timur (Simulator)</span>
        </div>
      </div>

      <!-- Service Health -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Konektivitas Service</span>
          <button @click="checkHealth" style="background: none; border: 1px solid var(--border-color); color: #cbd5e1; padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 0.75rem;">Refresh</button>
        </div>
        <div class="status-row">
          <span class="status-label">Laravel Backend API:</span>
          <span :class="backendStatus === 'ONLINE' ? 'status-online' : 'status-standby'" class="status-value">
            {{ backendStatus }}
          </span>
        </div>
        <div class="status-row">
          <span class="status-label">FastAPI AI Service:</span>
          <span :class="aiServiceStatus === 'ONLINE' ? 'status-online' : 'status-standby'" class="status-value">
            {{ aiServiceStatus }}
          </span>
        </div>
        <div class="status-row">
          <span class="status-label">PostgreSQL Database:</span>
          <span :class="backendDetails?.database?.connected ? 'status-online' : 'status-standby'" class="status-value">
            {{ backendDetails?.database?.connected ? 'CONNECTED' : 'STANDBY' }}
          </span>
        </div>
        <div class="status-row">
          <span class="status-label">Frontend (Vue 3 + Vite):</span>
          <span class="status-online status-value">RUNNING</span>
        </div>
      </div>

      <!-- Mode Info -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Mode Logika Lampu</span>
          <span class="badge badge-success">Simulasi Tahap 1</span>
        </div>
        <div class="status-row">
          <span class="status-label">Algoritma Keputusan:</span>
          <span class="status-value">Heuristik (di Backend)</span>
        </div>
        <div class="status-row">
          <span class="status-label">Siklus Transisi:</span>
          <span class="status-value">Hijau → Kuning → All-Red → Hijau</span>
        </div>
        <div class="status-row">
          <span class="status-label">Fallback Safety:</span>
          <span class="status-value">Auto Fallback ke ATCS Normal</span>
        </div>
        <div class="status-row">
          <span class="status-label">Model AI (Tahap Lanjutan):</span>
          <span class="status-value">YOLOv13 (Zona Antrean)</span>
        </div>
      </div>
    </div>

    <!-- 4 CCTV Feeds Monitor Placeholder (4 Directions) -->
    <h3 style="margin-bottom: 16px; font-size: 1.15rem; color: #f1f5f9;">Simulasi Feed CCTV Simpang (4 Arah)</h3>
    <div class="cctv-grid">
      <div class="cctv-box">
        <span class="cctv-title">CCTV 01 - UTARA</span>
        <div style="font-size: 2rem;">📹</div>
        <p class="cctv-placeholder-text">Lajur Luar: Belok Kiri / Lurus<br>Lajur Dalam: Lurus / Belok Kanan</p>
        <span class="badge badge-info" style="margin-top: 10px; font-size: 0.7rem;">Feed Simulator Standby</span>
      </div>

      <div class="cctv-box">
        <span class="cctv-title">CCTV 02 - SELATAN</span>
        <div style="font-size: 2rem;">📹</div>
        <p class="cctv-placeholder-text">Lajur Luar: Belok Kiri / Lurus<br>Lajur Dalam: Lurus / Belok Kanan</p>
        <span class="badge badge-info" style="margin-top: 10px; font-size: 0.7rem;">Feed Simulator Standby</span>
      </div>

      <div class="cctv-box">
        <span class="cctv-title">CCTV 03 - TIMUR</span>
        <div style="font-size: 2rem;">📹</div>
        <p class="cctv-placeholder-text">Lajur Luar: Belok Kiri / Lurus<br>Lajur Dalam: Lurus / Belok Kanan</p>
        <span class="badge badge-info" style="margin-top: 10px; font-size: 0.7rem;">Feed Simulator Standby</span>
      </div>

      <div class="cctv-box">
        <span class="cctv-title">CCTV 04 - BARAT</span>
        <div style="font-size: 2rem;">📹</div>
        <p class="cctv-placeholder-text">Lajur Luar: Belok Kiri / Lurus<br>Lajur Dalam: Lurus / Belok Kanan</p>
        <span class="badge badge-info" style="margin-top: 10px; font-size: 0.7rem;">Feed Simulator Standby</span>
      </div>
    </div>

    <!-- Notice / Disclaimer Banner -->
    <div class="alert-banner">
      <div style="font-size: 1.5rem;">ℹ️</div>
      <div class="alert-content">
        <h4>Catatan Penting Posisi Sistem & Privasi</h4>
        <p>
          SIGAP diposisikan sebagai modul riset pendukung ATCS, bukan pengganti sistem ATCS fisik Bandung Command Center.
          Sistem dirancang untuk menghitung volume antrean kendaraan secara anonim tanpa Vehicle Tracking, tanpa Tracking ID, serta tanpa pemindaian plat nomor maupun wajah.
        </p>
      </div>
    </div>

    <!-- Footer -->
    <footer>
      <p>SIGAP &copy; 2026 — Prototype Modul Pendukung ATCS Adaptif Simpang Jl. Ibrahim Adjie, Bandung</p>
    </footer>
  </div>
</template>
