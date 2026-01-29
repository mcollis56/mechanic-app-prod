<template>
  <section class="p-4">
    <h1>Debug</h1>
    <div style="display:flex;gap:8px;margin:8px 0">
      <button @click="deleteFirst" style="padding:6px 10px;border-radius:6px;border:1px solid #ccc;background:#fff;cursor:pointer">
        Delete first job
      </button>
      <button @click="load" style="padding:6px 10px;border-radius:6px;border:1px solid #ccc;background:#fff;cursor:pointer">
        Refresh
      </button>
    </div>

    <div v-if="loading">Loading…</div>
    <div v-else-if="error"><pre>{{ show(error) }}</pre></div>
    <div v-else>
      <div>Rows: {{ rows?.length || 0 }}</div>
      <details style="margin-top:12px"><summary>Response</summary><pre>{{ show(rows) }}</pre></details>
      <details style="margin-top:12px"><summary>Meta</summary><pre>{{ show(meta) }}</pre></details>
      <details style="margin-top:12px"><summary>Last Action</summary><pre>{{ show(lastAction) }}</pre></details>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const rows = ref([])
const loading = ref(true)
const error = ref(null)
const meta = ref({})
const lastAction = ref({})

const show = v => { try { return JSON.stringify(v, null, 2) } catch { return String(v) } }

async function load() {
  loading.value = true
  error.value = null
  try {
    const url = import.meta.env.VITE_SUPABASE_URL
    const key = import.meta.env.VITE_SUPABASE_ANON_KEY
    const endpoint = `${url}/rest/v1/jobs?select=id,created_at,status,problem_description&order=created_at.asc&limit=50`
    const res = await fetch(endpoint, { headers: { apikey: key, Authorization: `Bearer ${key}` } })
    const text = await res.text()
    let json = []; try { json = JSON.parse(text) } catch {}
    meta.value = { status: res.status, ok: res.ok }
    if (!res.ok) throw new Error(`${res.status} ${text}`)
    rows.value = json
  } catch (e) {
    error.value = e
  } finally {
    loading.value = false
  }
}

async function deleteFirst() {
  try {
    await load()
    if (!rows.value.length) { lastAction.value = { note: 'no rows to delete' }; return }
    const id = rows.value[0].id
    const url = import.meta.env.VITE_SUPABASE_URL
    const key = import.meta.env.VITE_SUPABASE_ANON_KEY
    const endpoint = `${url}/rest/v1/jobs?id=eq.${id}`
    const res = await fetch(endpoint, {
      method: 'DELETE',
      headers: { apikey: key, Authorization: `Bearer ${key}`, Prefer: 'return=minimal' }
    })
    const text = await res.text()
    lastAction.value = { deleteId: id, status: res.status, ok: res.ok, body: text }
    await load()
  } catch (e) {
    lastAction.value = { error: String(e) }
  }
}

onMounted(load)
</script>
