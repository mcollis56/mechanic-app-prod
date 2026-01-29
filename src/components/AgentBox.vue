<template>
  <section :style="card">
    <header :style="header">
      <span :style="dot"></span>
      <span :style="title">Agent • ai</span>
      <span v-if="loading" :style="pill">Thinking…</span>
      <span v-if="mode === 'safe'" :style="pillMuted" title="OPENAI_API_KEY not set on Edge Function">safe</span>
    </header>

    <div v-if="error" :style="errorBox">
      {{ error }}
    </div>

    <div v-else>
      <div v-if="result && result.summary" :style="summary">
        {{ result.summary }}
      </div>

      <ol v-if="(result?.steps || []).length" :style="stepsWrap">
        <li v-for="(s, i) in result.steps" :key="i" :style="step">
          <span :style="stepNum">{{ i + 1 }}</span>
          <span>{{ s }}</span>
        </li>
      </ol>

      <div v-if="(result?.actions || []).length" :style="actionsWrap">
        <button
          v-for="(a, i) in result.actions"
          :key="i"
          :style="btn"
          @click="handleAction(a)"
        >
          {{ labelFor(a) }}
        </button>
      </div>

      <details v-if="debug" :style="debugBox">
        <summary>Debug</summary>
        <pre>{{ result }}</pre>
      </details>
    </div>
  </section>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  loading: { type: Boolean, default: false },
  error: { type: String, default: '' },
  mode: { type: String, default: '' }, // "ai" or "safe"
  result: { type: Object, default: () => ({ summary: '', steps: [], actions: [] }) },
  debug: { type: Boolean, default: false }
})

const emit = defineEmits(['create-job', 'add-note'])

function handleAction(a) {
  if (!a || !a.type) return
  if (a.type === 'create_job') emit('create-job', a.payload || {})
  if (a.type === 'add_note') emit('add-note', a.payload || {})
}

function labelFor(a) {
  if (!a) return 'Do action'
  if (a.type === 'create_job') return 'Create job'
  if (a.type === 'add_note') return 'Add note'
  return 'Do action'
}

/* inline styles to avoid extra deps */
const card = {
  background: '#fff',
  border: '1px solid #e5e7eb',
  borderRadius: '12px',
  padding: '14px',
  boxShadow: '0 1px 2px rgba(16,24,40,0.04)',
  marginTop: '8px'
}
const header = { display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }
const dot = { width: '8px', height: '8px', borderRadius: '50%', background: '#10b981', display: 'inline-block' }
const title = { fontSize: '14px', fontWeight: 600, color: '#111827' }
const pill = { marginLeft: 'auto', fontSize: '12px', padding: '2px 8px', borderRadius: '9999px', background: '#eef2ff', color: '#3730a3' }
const pillMuted = { marginLeft: 'auto', fontSize: '12px', padding: '2px 8px', borderRadius: '9999px', background: '#f3f4f6', color: '#6b7280' }
const errorBox = { background: '#fef2f2', color: '#991b1b', border: '1px solid #fecaca', borderRadius: '8px', padding: '8px', fontSize: '14px' }
const summary = { fontSize: '14px', color: '#111827', lineHeight: 1.5, marginBottom: '8px' }
const stepsWrap = { listStyle: 'none', padding: 0, margin: '0 0 8px 0', display: 'grid', gap: '6px' }
const step = { display: 'grid', gridTemplateColumns: '24px 1fr', alignItems: 'start', gap: '8px', fontSize: '14px', color: '#111827' }
const stepNum = { width: '20px', height: '20px', borderRadius: '9999px', background: '#f3f4f6', color: '#111827', display: 'inline-grid', placeItems: 'center', fontSize: '12px', fontWeight: 600 }
const actionsWrap = { display: 'flex', gap: '8px', marginTop: '8px', flexWrap: 'wrap' }
const btn = {
  fontSize: '13px',
  padding: '8px 12px',
  borderRadius: '10px',
  border: '1px solid #d1d5db',
  background: '#ffffff',
  cursor: 'pointer'
}
const debugBox = { marginTop: '8px', background: '#f9fafb', border: '1px dashed #e5e7eb', borderRadius: '8px', padding: '8px' }
</script>
