<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase'

const route = useRoute()
const router = useRouter()
const id = route.params.id

const invoice = ref(null)
const items = ref([])
const loading = ref(false)
const err = ref('')

async function load() {
  loading.value = true
  err.value = ''
  try {
    const { data: inv, error: e1 } = await supabase
      .from('invoices')
      .select('id, job_id, status, subtotal, tax, total, created_at, updated_at')
      .eq('id', id)
      .maybeSingle()
    if (e1) throw e1
    invoice.value = inv

    const { data: it, error: e2 } = await supabase
      .from('invoice_items')  // adjust if your table name differs
      .select('id, description, qty, unit_price')
      .eq('invoice_id', id)
      .order('id', { ascending: true })
    if (e2) throw e2
    items.value = it ?? []
  } catch (e) {
    err.value = e.message ?? String(e)
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="wrap">
    <button class="link" @click="router.back()">← Back</button>

    <h1 v-if="invoice">Invoice #{{ invoice.id }}</h1>
    <p v-if="err" class="err">⚠️ {{ err }}</p>
    <p v-if="loading">Loading…</p>

    <div v-if="invoice" class="card">
      <div class="row"><b>Status:</b> {{ invoice.status }}</div>
      <div class="row"><b>Job ID:</b> {{ invoice.job_id }}</div>
      <div class="row"><b>Created:</b> {{ new Date(invoice.created_at).toLocaleString() }}</div>

      <h3>Items</h3>
      <table class="items">
        <thead><tr><th>Description</th><th>Qty</th><th>Unit</th><th>Amount</th></tr></thead>
        <tbody>
          <tr v-for="it in items" :key="it.id">
            <td>{{ it.description }}</td>
            <td class="num">{{ it.qty }}</td>
            <td class="num">{{ Number(it.unit_price).toFixed(2) }}</td>
            <td class="num">{{ (Number(it.qty) * Number(it.unit_price)).toFixed(2) }}</td>
          </tr>
          <tr v-if="!items.length"><td colspan="4" class="dim">No line items yet.</td></tr>
        </tbody>
      </table>

      <div class="totals">
        <div><span>Subtotal</span><b>{{ Number(invoice.subtotal||0).toFixed(2) }}</b></div>
        <div><span>Tax</span><b>{{ Number(invoice.tax||0).toFixed(2) }}</b></div>
        <div class="grand"><span>Total</span><b>{{ Number(invoice.total||0).toFixed(2) }}</b></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.wrap { padding: 24px; max-width: 900px; margin: 0 auto; }
.link { background:none; border:none; color:#2d6cdf; cursor:pointer; margin-bottom:10px; }
.err { color:#b00020; }
.card { border:1px solid #eee; border-radius:12px; padding:16px; background:#fff; }
.row { margin:4px 0; }
.items { width:100%; border-collapse:collapse; margin-top:10px; }
.items th, .items td { border-bottom:1px solid #eee; padding:8px; }
.items .num { text-align:right; width:90px; }
.dim { color:#777; text-align:center; }
.totals { margin-top:12px; display:grid; gap:6px; max-width:280px; margin-left:auto; }
.totals div { display:flex; justify-content:space-between; }
.grand { font-size:18px; }
</style>
