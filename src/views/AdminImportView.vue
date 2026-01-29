<script setup>
import { ref } from 'vue'
import { supabase } from '@/supabase'

const kind = ref('customers') // customers | vehicles | jobs
const raw = ref('')
const rows = ref([])
const parsing = ref(false)
const importing = ref(false)
const parseErr = ref(null)
const importMsg = ref(null)

// simple CSV -> array of objects
function parseCSV(text) {
  const lines = text.split(/\r?\n/).filter(l => l.trim().length)
  if (!lines.length) return []
  const headers = lines[0].split(',').map(h => h.trim())
  return lines.slice(1).map(line => {
    const cols = line.split(',').map(c => c.trim())
    const obj = {}
    headers.forEach((h, i) => obj[h] = cols[i] ?? '')
    return obj
  })
}

function tryParse() {
  parsing.value = true
  parseErr.value = null
  importMsg.value = null
  try {
    const txt = raw.value.trim()
    if (!txt) { rows.value = []; return }
    if (txt.startsWith('[') || txt.startsWith('{')) {
      // JSON
      const data = JSON.parse(txt)
      rows.value = Array.isArray(data) ? data : [data]
    } else {
      // CSV
      rows.value = parseCSV(txt)
    }
  } catch (e) {
    parseErr.value = e.message || String(e)
  } finally {
    parsing.value = false
  }
}

async function importRows() {
  importMsg.value = null
  if (!rows.value.length) { importMsg.value = 'Nothing to import.'; return }
  importing.value = true
  try {
    // Map each kind to its table + minimal column normalization
    let table = ''
    let mapped = []

    if (kind.value === 'customers') {
      table = 'customers'
      mapped = rows.value.map(r => ({
        name: (r.name ?? r.customer_name ?? '').trim() || null,
        email: (r.email ?? '').trim() || null,
        phone: (r.phone ?? '').trim() || null,
      }))
    } else if (kind.value === 'vehicles') {
      table = 'vehicles'
      mapped = rows.value.map(r => ({
        rego: (r.rego ?? r.plate ?? '').trim() || null,
        make: (r.make ?? '').trim() || null,
        model: (r.model ?? '').trim() || null,
        vin: (r.vin ?? '').trim() || null,
      }))
    } else {
      table = 'jobs'
      mapped = rows.value.map(r => ({
        status: r.status ?? 'Booking',
        problem_description: r.problem_description ?? r.description ?? '',
        customer_name: r.customer_name ?? r.customer ?? null,
        vehicle_rego: r.vehicle_rego ?? r.rego ?? null,
        created_at: r.created_at ?? null,
      }))
    }

    // chunk to avoid payload limits
    const chunk = 500
    let inserted = 0
    for (let i = 0; i < mapped.length; i += chunk) {
      const slice = mapped.slice(i, i + chunk)
      // upsert if table has unique constraints (email, rego, etc.)
      const q = supabase.from(table)
      const { error } = await q.upsert(slice, { onConflict: table === 'customers' ? 'email' : table === 'vehicles' ? 'rego' : undefined })
      if (error) throw error
      inserted += slice.length
    }
    importMsg.value = `Imported ${inserted} ${kind.value}.`
  } catch (e) {
    importMsg.value = `Import failed: ${e.message || e}`
  } finally {
    importing.value = false
  }
}
</script>

<template>
  <div class="card">
    <h3>Bulk import</h3>

    <div class="row">
      <label>Data type</label>
      <select v-model="kind" class="select">
        <option value="customers">Customers</option>
        <option value="vehicles">Vehicles</option>
        <option value="jobs">Jobs</option>
      </select>
    </div>

    <div class="row">
      <label>Paste CSV or JSON</label>
      <textarea class="area" v-model="raw" placeholder="CSV headers example:
customers: name,email,phone
vehicles: rego,make,model,vin
jobs: status,problem_description,customer_name,vehicle_rego,created_at"></textarea>
    </div>

    <div class="row" style="gap:8px">
      <button class="button" @click="tryParse" :disabled="parsing">Validate</button>
      <button class="button primary" @click="importRows" :disabled="!rows.length || importing">Import {{ rows.length ? '('+rows.length+')' : '' }}</button>
    </div>

    <div v-if="parseErr" class="msg err">{{ parseErr }}</div>
    <div v-if="importMsg" class="msg">{{ importMsg }}</div>

    <div v-if="rows.length" class="preview">
      <div class="small">Preview (first 10)</div>
      <pre>{{ rows.slice(0,10) }}</pre>
    </div>
  </div>
</template>

<style scoped>
.card{ background:#fff; border:1px solid rgba(0,0,0,.06); border-radius:12px; padding:16px; }
.row{ display:flex; gap:12px; align-items:center; margin:12px 0; }
.row label{ width:120px; color:#6b7280; font-size:14px; }
.select{ padding:8px 10px; border:1px solid #e5e7eb; border-radius:8px; }
.area{ width:100%; min-height:220px; padding:10px; border:1px solid #e5e7eb; border-radius:8px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
.button{ padding:8px 12px; border-radius:8px; border:1px solid #e5e7eb; background:#f8fafc; }
.button.primary{ background:#2563eb; color:#fff; border-color:#2563eb; }
.msg{ margin-top:8px; color:#111827; }
.msg.err{ color:#ef4444; }
.preview{ margin-top:16px; }
.small{ color:#6b7280; font-size:12px; }
</style>
