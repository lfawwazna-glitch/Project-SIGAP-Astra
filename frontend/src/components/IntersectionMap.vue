<script setup>
import AppIcon from './AppIcon.vue'

// Coordinates transcribed from the supplied B/U/T/S reference. Each arm
// has two incoming lanes and two outgoing lanes; all four corners stay square.
const colors = { blue: '#4884d8', red: '#d16669', green: '#54a482', cream: '#c9a475', orange: '#db9861', gray: '#8995a5' }
const flows = [
  { color: 'blue', d: 'M36 322H736' },
  { color: 'blue', d: 'M36 322H270Q335 322 335 257V35' },
  { color: 'blue', d: 'M451 35V736' },
  { color: 'blue', d: 'M451 35V273Q451 335 516 335H736' },
  { color: 'blue', d: 'M736 451H36' },
  { color: 'blue', d: 'M736 451H500Q438 451 438 514V736' },
  { color: 'blue', d: 'M322 736V35' },
  { color: 'blue', d: 'M322 736V500Q322 438 260 438H36' },
  { color: 'red', d: 'M36 365H736' },
  { color: 'red', d: 'M408 35V736' },
  { color: 'red', d: 'M736 408H36' },
  { color: 'red', d: 'M365 736V35' },
  { color: 'green', d: 'M285 365C352 365 408 415 408 480V736' },
  { color: 'cream', d: 'M408 284C408 368 367 402 303 402H36' },
  { color: 'orange', d: 'M489 408C410 408 369 363 369 286V35' },
  { color: 'gray', d: 'M365 489C365 410 410 365 489 365H736' },
]
const approaches = [
  { label: 'Barat', code: 'B', color: 'green', left: 'Utara', straight: 'Timur', right: 'Selatan', className: 'west' },
  { label: 'Utara', code: 'U', color: 'cream', left: 'Timur', straight: 'Selatan', right: 'Barat', className: 'north' },
  { label: 'Selatan', code: 'S', color: 'gray', left: 'Barat', straight: 'Utara', right: 'Timur', className: 'south' },
  { label: 'Timur', code: 'T', color: 'orange', left: 'Selatan', straight: 'Barat', right: 'Utara', className: 'east' },
]
</script>

<template>
  <section id="peta-simpang" class="card map-card" tabindex="-1" aria-labelledby="map-title">
    <div class="card-heading">
      <div><h2 id="map-title">Peta Persimpangan &amp; Fase Aktif</h2><p>Lajur luar: kiri / lurus · Lajur dalam: lurus / kanan</p></div>
      <span class="badge badge-neutral"><AppIcon name="map" :size="13" />4 arah · 2 lajur</span>
    </div>
    <div class="map-canvas">
      <svg class="intersection-svg" viewBox="0 0 772 772" role="img" aria-labelledby="intersection-title intersection-desc">
        <title id="intersection-title">Peta arus persimpangan Barat, Utara, Timur, Selatan</title>
        <desc id="intersection-desc">Geometri silang siku-siku sesuai referensi. Lajur luar biru untuk lurus atau belok kiri. Lajur dalam merah untuk lurus, dengan belok kanan hijau dari Barat, krem dari Utara, oranye dari Timur, dan abu-abu dari Selatan. Warna arus tidak menunjukkan status lampu.</desc>
        <defs>
          <marker v-for="(color, key) in colors" :id="`flow-${key}`" :key="key" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">
            <path d="m2 1 6 4-6 4" fill="none" :stroke="color" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
          </marker>
          <g id="lane-outer" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M0 13V-13m-5 5 5-5 5 5M0 4h-9v-8m-4 4 4-4 4 4" />
          </g>
          <g id="lane-inner" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M0 13V-13m-5 5 5-5 5 5M0 4h9v-8m-4 4 4-4 4 4" />
          </g>
        </defs>

        <!-- Road edges and markings retain the geometry of the supplied map. -->
        <path d="M300 0H472V300H772V472H472V772H300V472H0V300H300Z" fill="#dce3ec" />
        <path d="M300 0V300H0M472 0V300H772M772 472H472V772M300 772V472H0" fill="none" stroke="#aebdce" stroke-width="3" />
        <g stroke="#fff" stroke-width="2.4" stroke-dasharray="12 11" stroke-linecap="round">
          <path d="M343 35V292M429 35V292M343 480V736M429 480V736M35 343H292M35 429H292M480 343H736M480 429H736" />
        </g>
        <path d="M386 35V300M386 472V736M35 386H300M472 386H736" fill="none" stroke="#c9ac60" stroke-width="2.6" />

        <g class="flow-lines" fill="none" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
          <path v-for="(flow, index) in flows" :key="index" :d="flow.d" :stroke="colors[flow.color]" :marker-end="`url(#flow-${flow.color})`" />
        </g>

        <!-- White lane signs are distinct from the colored route overlays. -->
        <g opacity="0.95">
          <use href="#lane-outer" transform="translate(200 322) rotate(90)" />
          <use href="#lane-inner" transform="translate(200 365) rotate(90)" />
          <use href="#lane-outer" transform="translate(451 200) rotate(180)" />
          <use href="#lane-inner" transform="translate(408 200) rotate(180)" />
          <use href="#lane-outer" transform="translate(572 451) rotate(-90)" />
          <use href="#lane-inner" transform="translate(572 408) rotate(-90)" />
          <use href="#lane-outer" transform="translate(322 572)" />
          <use href="#lane-inner" transform="translate(365 572)" />
        </g>

        <g class="map-direction-labels" text-anchor="middle">
          <g transform="translate(386 16)"><rect x="-14" y="-13" width="28" height="26" rx="5" /><text y="5">U</text></g>
          <g transform="translate(16 386)"><rect x="-13" y="-13" width="26" height="26" rx="5" /><text y="5">B</text></g>
          <g transform="translate(756 386)"><rect x="-13" y="-13" width="26" height="26" rx="5" /><text y="5">T</text></g>
          <g transform="translate(386 756)"><rect x="-14" y="-13" width="28" height="26" rx="5" /><text y="5">S</text></g>
        </g>
      </svg>

      <div class="map-compass" aria-label="Kompas: Utara atas, Barat kiri, Timur kanan, Selatan bawah">
        <svg viewBox="0 0 66 66" aria-hidden="true"><circle cx="33" cy="33" r="20" /><path d="M33 15v36M15 33h36M33 18l-3 6h6Z" /><text x="33" y="10">U</text><text x="6" y="37">B</text><text x="60" y="37">T</text><text x="33" y="64">S</text></svg>
      </div>
      <div v-for="approach in approaches" :key="approach.code" :class="['approach-key', approach.className]">
        <strong><span>{{ approach.code }}</span>Arah {{ approach.label }}</strong>
        <p><i :style="{ background: colors.blue }"></i>Kiri ke {{ approach.left }} / lurus</p>
        <p><i :style="{ background: colors.red }"></i>Lurus ke {{ approach.straight }}</p>
        <p><i :style="{ background: colors[approach.color] }"></i>Kanan ke {{ approach.right }}</p>
      </div>
    </div>
    <div class="phase-strip">
      <span><AppIcon name="traffic" :size="17" /><strong>Fase Aktif: Barat–Timur</strong><span class="phase-simulator">· Simulator</span></span>
      <div class="phase-lights"><span><i class="status-dot green"></i>B–T aktif</span><span><i class="status-dot red"></i>U–S berhenti</span></div>
    </div>
    <div class="map-footnote"><AppIcon name="info" :size="13" />Warna jalur menunjukkan arah arus, bukan status lampu.</div>
  </section>
</template>
