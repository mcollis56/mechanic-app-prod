<template>
  <div class="container" style="padding-top:16px">
    <div class="admin-header">
      <h1>Admin</h1>
      <router-link to="/" class="button" style="margin-left:auto">← Back to Jobs</router-link>

      <div class="muted">Manage data • Import from CSV/clipboard • Quick fixes</div>
    </div>

    <div class="tabs">
      <button class="tab" :class="{active: tab==='data'}" @click="tab='data'">Data</button>
      <button class="tab" :class="{active: tab==='import'}" @click="tab='import'">Bulk import</button>
    </div>

    <!-- =========================
         DATA TAB
    ========================== -->
    <div v-if="tab==='data'" class="data-grid">
      <!-- CUSTOMERS -->
      <section class="panel">
        <div class="panel-head">
          <h3>Customers</h3>
          <div class="row gap8">
            <input class="input sm" v-model="filters.customers" placeholder="Search name / email / phone">
            <button class="button ghost sm" @click="loadCustomers">Refresh</button>
          </div>
        </div>
        <div class="panel-body">
          <div class="row gap8 wrap">
            <input class="input" placeholder="Name"  v-model="newCustomer.name">
            <input class="input" placeholder="Email" v-model="newCustomer.email">
            <input class="input" placeholder="Phone" v-model="newCustomer.phone">
            <button class="button primary" @click="saveCustomer()">Add</button>
          </div>

          <div v-if="state.loadingCustomers" class="empty">Loading…</div>
          <div v-else class="table">
            <div class="thead">
              <div>Name</div><div>Email</div><div>Phone</div><div class="right">Actions</div>
            </div>
            <div class="row" v-for="c in filteredCustomers" :key="c.id">
              <input class="cell" v-model="c.name"  />
              <input class="cell" v-model="c.email" />
              <input class="cell" v-model="c.phone" />
              <div class="cell right">
                <button class="button ghost sm"  @click="saveCustomer(c)">Save</button>
                <button class="button danger sm" @click="removeRow('customers', c.id)">Delete</button>
              </div>
            </div>
            <div class="tfoot muted">Rows: {{ customers.length }}</div>
          </div>
        </div>
      </section>

      <!-- VEHICLES -->
      <section class="panel">
        <div class="panel-head">
          <h3>Vehicles</h3>
          <div class="row gap8">
            <input class="input sm" v-model="filters.vehicles" placeholder="Search rego / vin / make / model">
            <button class="button ghost sm" @click="loadVehicles">Refresh</button>
          </div>
        </div>
        <div class="panel-body">
          <div class="row gap8 wrap">
            <input class="input" placeholder="Rego"  v-model="newVehicle.rego">
            <input class="input" placeholder="VIN"   v-model="newVehicle.vin">
            <input class="input" placeholder="Make"  v-model="newVehicle.make">
            <input class="input" placeholder="Model" v-model="newVehicle.model">
            <input class="input" placeholder="Year"  v-model="newVehicle.year">
            <button class="button primary" @click="saveVehicle()">Add</button>
          </div>

          <div v-if="state.loadingVehicles" class="empty">Loading…</div>
          <div v-else-if="vehicleTableMissing" class="empty">
            <div class="muted">Table <code>vehicles</code> not found — you can add it later; Jobs & Customers still work.</div>
          </div>
          <div v-else class="table">
            <div class="thead">
              <div>Rego</div><div>VIN</div><div>Make</div><div>Model</div><div>Year</div><div class="right">Actions</div>
            </div>
            <div class="row" v-for="v in filteredVehicles" :key="v.id">
              <input class="cell" v-model="v.rego"  />
              <input class="cell" v-model="v.vin"   />
              <input class="cell" v-model="v.make"  />
              <input class="cell" v-model="v.model" />
              <input class="cell" v-model="v.year"  />
              <div class="cell right">
                <button class="button ghost sm"  @click="saveVehicle(v)">Save</button>
                <button class="button danger sm" @click="removeRow('vehicles', v.id)">Delete</button>
              </div>
            </div>
            <div class="tfoot muted">Rows: {{ vehicles.length }}</div>
          </div>
        </div>
      </section>

      <!-- JOBS -->
      <section class="panel">
        <div class="panel-head">
          <h3>Jobs</h3>
          <div class="row gap8">
            <input class="input sm" v-model="filters.jobs" placeholder="Search description / customer / rego">
            <button class="button ghost sm" @click="loadJobs">Refresh</button>
          </div>
        </div>
        <div class="panel-body">
          <div class="row gap8 wrap">
            <select class="input" v-model="newJob.status">
              <option>Booking</option>
              <option>In progress</option>
              <option>Awaiting parts</option>
              <option>Complete</option>
            </select>
            <input class="input" placeholder="Problem description" v-model="newJob.problem_description">
            <select class="input" v-model="newJob.customer_id">
              <option :value="null" disabled>Select customer</option>
              <option v-for="o in customerOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
            </select>
            <select class="input" v-model="newJob.vehicle_id">
              <option :value="null" disabled>Select vehicle</option>
              <option v-for="o in vehicleOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
            </select>
            <button class="button primary" @click="saveJob()">Add</button>
          </div>

          <div v-if="state.loadingJobs" class="empty">Loading…</div>
          <div v-else class="table">
            <div class="thead">
              <div>Status</div><div>Description</div><div>Customer</div><div>Rego</div><div class="right">Actions</div>
            </div>
            <div class="row" v-for="j in filteredJobs" :key="j.id">
              <select class="cell" v-model="j.status">
                <option>Booking</option>
                <option>In progress</option>
                <option>Awaiting parts</option>
                <option>Complete</option>
              </select>
              <input class="cell" v-model="j.problem_description" />
              <div class="cell">{{ j.customer_name }}</div>
              <div class="cell">{{ j.vehicle_rego }}</div>
              <div class="cell right">
                <button class="button ghost sm"  @click="saveJob(j)">Save</button>
                <button class="button danger sm" @click="removeRow('jobs', j.id)">Delete</button>
              </div>
            </div>
            <div class="tfoot muted">Rows: {{ jobs.length }}</div>
          </div>
        </div>
      </section>
    </div>

    <!-- =========================
         IMPORT TAB
    ========================== -->
    <div v-else class="panel">
      <div class="panel-head">
        <h3>Bulk Import</h3>
        <div class="muted">Paste CSV / TSV or copy a table from Excel/Sheets.</div>
      </div>

      <div class="panel-body">
        <div class="row gap12 wrap">
          <select class="input" v-model="importKind" style="width:220px">
            <option value="customers">Customers</option>
            <option value="vehicles">Vehicles</option>
            <option value="jobs">Jobs</option>
          </select>
          <button class="button ghost" @click="sample">Load sample</button>
          <button class="button ghost" @click="pasteFromClipboard">Paste from clipboard</button>
        </div>

        <textarea class="textarea" rows="8" v-model="raw"
                  @input="onRawInput"
                  placeholder="Paste CSV / TSV / or a copied table…"></textarea>

        <div class="row gap12 wrap">
          <button class="button" @click="parse">Parse</button>
          <div class="muted" v-if="parsed.rows.length">Parsed {{ parsed.rows.length }} rows • columns: {{ parsed.headers.join(', ') }}</div>
        </div>

        <div v-if="parsed.rows.length" class="map">
          <h4>Column mapping <span class="muted">• Mapped {{ mapStats.n }}/{{ mapStats.total }}</span></h4>
          <div class="map-grid">
            <div v-for="(h,i) in parsed.headers" :key="i" class="map-row">
              <div class="muted">{{ h }}</div>
              <select class="input" v-model="mapping[h]">
                <option value="">(ignore)</option>
                <option v-for="col in allowedColumns[importKind]" :key="col" :value="col">{{ col }}</option>
              </select>
            </div>
          </div>
          <div class="row gap12 wrap">
            <button class="button primary" :disabled="state.importing" @click="runImport">
              {{ state.importing ? 'Importing…' : `Import ${parsed.rows.length} rows` }}
            </button>
            <div class="muted" v-if="resultMsg">{{ resultMsg }}</div>
          </div>

          <div class="hr"></div>
          <h4>Preview (first 10)</h4>
          <div class="table compact">
            <div class="thead">
              <div v-for="(h,i) in parsed.headers" :key="i">{{ h }}</div>
            </div>
            <div class="row" v-for="(r,ri) in parsed.rows.slice(0,10)" :key="ri">
              <div class="cell" v-for="(h,i) in parsed.headers" :key="i">{{ r[h] }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="state.error" class="error">{{ state.error }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from '@/supabase'

/* ---------- tabs ---------- */
const tab = ref('data') // 'data' | 'import'

/* ---------- state ---------- */
const state = reactive({
  error: null,
  loadingCustomers: false,
  loadingVehicles: false,
  loadingJobs: false,
  importing: false
})

/* ---------- data stores ---------- */
const customers = ref([])
const vehicles  = ref([])
const jobs      = ref([])

/* ---------- filters ---------- */
const filters = reactive({ customers:'', vehicles:'', jobs:'' })

/* ---------- new rows ---------- */
const newCustomer = reactive({ name:'', email:'', phone:'' })
const newVehicle  = reactive({ rego:'', vin:'', make:'', model:'', year:'' })
const newJob      = reactive({ status:'Booking', problem_description:'', customer_id:null, vehicle_id:null })

/* ---------- dropdown options ---------- */
const customerOptions = ref([])
const vehicleOptions  = ref([])

/* ---------- helpers ---------- */
function likeFilter(text, q){
  if(!q) return true
  const s = (text||'').toString().toLowerCase()
  return s.includes(q.toLowerCase())
}

/* ---------- delete (optimistic) ---------- */
async function removeRow(table, id){
  if(!confirm('Delete this row?')) return

  // Optimistic UI
  if(table === 'customers') customers.value = customers.value.filter(x => x.id !== id)
  if(table === 'vehicles')  vehicles.value  = vehicles.value.filter(x => x.id !== id)
  if(table === 'jobs')      jobs.value      = jobs.value.filter(x => x.id !== id)

  const { error } = await supabase.from(table).delete().eq('id', id)
  if(error){
    console.error('Delete error', { table, id, error })
    alert(error.message)
    // Reload only on error to resync
    if(table === 'customers') await loadCustomers()
    if(table === 'vehicles')  await loadVehicles()
    if(table === 'jobs')      await loadJobs()
  }
}

/* ---------- Customers CRUD ---------- */
async function loadCustomers(){
  state.loadingCustomers = true
  const { data, error } = await supabase.from('customers').select('*').order('created_at', { ascending:false }).limit(500)
  state.loadingCustomers = false
  if(error){ if(error.code==='42P01'){ customers.value=[] } else { state.error = error.message } ; return }
  customers.value = data || []
  // options
  customerOptions.value = (data||[]).map(c => ({ value: c.id, label: c.name || c.email || c.phone || c.id }))
}
async function saveCustomer(row){
  const payload = row ? { ...row } : { ...newCustomer }
  if(!payload.name) return alert('Name is required')

  // optional match by email if creating; avoid .single to dodge JSON object errors
  let existingId = payload.id
  if(!existingId && payload.email){
    const { data, error } = await supabase.from('customers').select('id').ilike('email', payload.email).limit(1)
    if(error){ alert(error.message); return }
    existingId = data?.[0]?.id
  }
  const q = existingId
    ? supabase.from('customers').update(payload).eq('id', existingId)
    : supabase.from('customers').insert(payload)
  const { error } = await q
  if(error) return alert(error.message)
  if(!row){ Object.keys(newCustomer).forEach(k => newCustomer[k]='') }
  await loadCustomers()
}

/* ---------- Vehicles CRUD ---------- */
const vehicleTableMissing = ref(false)
async function loadVehicles(){
  state.loadingVehicles = true
  const { data, error } = await supabase.from('vehicles').select('*').order('created_at', { ascending:false }).limit(500)
  state.loadingVehicles = false
  if(error){
    if(error.code==='42P01'){ vehicleTableMissing.value = true; vehicles.value = []; return }
    state.error = error.message; return
  }
  vehicleTableMissing.value = false
  vehicles.value = data || []
  // options
  vehicleOptions.value = (data||[]).map(v => ({
    value: v.id,
    label: v.rego || [v.make, v.model, v.year].filter(Boolean).join(' ') || v.vin || v.id
  }))
}
async function saveVehicle(row){
  if(vehicleTableMissing.value){ return alert('Vehicles table not found in this project yet.') }
  const payload = row ? { ...row } : { ...newVehicle }
  if(!payload.rego && !payload.vin) return alert('Need at least Rego or VIN')

  let existingId = payload.id
  if(!existingId && payload.rego){
    const { data, error } = await supabase.from('vehicles').select('id').ilike('rego', payload.rego).limit(1)
    if(error){ alert(error.message); return }
    existingId = data?.[0]?.id
  }
  const q = existingId
    ? supabase.from('vehicles').update(payload).eq('id', existingId)
    : supabase.from('vehicles').insert(payload)
  const { error } = await q
  if(error) return alert(error.message)
  if(!row){ Object.keys(newVehicle).forEach(k => newVehicle[k]='') }
  await loadVehicles()
}

/* ---------- Jobs CRUD ---------- */
async function loadJobs(){
  state.loadingJobs = true
  // read via view for joined labels
  const { data, error } = await supabase.from('job_cards').select('*').order('created_at', { ascending:false }).limit(500)
  state.loadingJobs = false
  if(error){ state.error = error.message; return }
  jobs.value = data || []
}
async function saveJob(row){
  try{
    if(row){ // update
      if(!row.problem_description) return alert('Description is required')
      const { error } = await supabase.from('jobs').update({
        status: row.status,
        problem_description: row.problem_description
      }).eq('id', row.id)
      if(error) throw error
    }else{   // create
      if(!newJob.problem_description) return alert('Description is required')
      if(!newJob.customer_id || !newJob.vehicle_id) return alert('Pick a customer and a vehicle')
      const { error } = await supabase.from('jobs').insert({
        status: newJob.status,
        problem_description: newJob.problem_description,
        customer_id: newJob.customer_id,
        vehicle_id: newJob.vehicle_id
      })
      if(error) throw error
      newJob.status='Booking'
      newJob.problem_description=''
      newJob.customer_id=null
      newJob.vehicle_id=null
    }
    await loadJobs()
  }catch(e){
    alert(e.message || String(e))
  }
}

/* ---------- computed filters ---------- */
const filteredCustomers = computed(() => {
  const q = filters.customers.trim()
  return customers.value.filter(c =>
    likeFilter(c.name,q) || likeFilter(c.email,q) || likeFilter(c.phone,q)
  )
})
const filteredVehicles = computed(() => {
  const q = filters.vehicles.trim()
  return vehicles.value.filter(v =>
    likeFilter(v.rego,q) || likeFilter(v.vin,q) || likeFilter(v.make,q) ||
    likeFilter(v.model,q) || likeFilter(v.year,q)
  )
})
const filteredJobs = computed(() => {
  const q = filters.jobs.trim()
  return jobs.value.filter(j =>
    likeFilter(j.problem_description,q) || likeFilter(j.customer_name,q) || likeFilter(j.vehicle_rego,q)
  )
})

/* ---------- initial load ---------- */
onMounted(async () => {
  await Promise.all([loadCustomers(), loadVehicles(), loadJobs()])
})

/* =======================
   BULK IMPORT
======================= */
const importKind = ref('customers')
const raw = ref('')
const parsed = reactive({ headers:[], rows:[] })
const mapping = reactive({})
const resultMsg = ref('')

const allowedColumns = {
  customers: ['name','email','phone'],
  vehicles:  ['rego','vin','make','model','year'],
  jobs:      ['status','problem_description','customer_id','vehicle_id']
}

const mapStats = computed(() => {
  const selected = allowedColumns[importKind.value] || []
  const total = parsed.headers.length
  const n = Object.entries(mapping).filter(([src,dst]) => dst && selected.includes(dst)).length
  return { n, total }
})

async function pasteFromClipboard(){
  try{
    const text = await navigator.clipboard.readText()
    if(!text) return alert('Clipboard is empty')
    raw.value = text
    parse()
  }catch(e){
    alert('Cannot read clipboard (browser permission): ' + (e.message || e))
  }
}
function onRawInput(){ if(raw.value.trim()) parse() }

function sample(){
  if(importKind.value==='customers'){
    raw.value = `name,email,phone
John Smith,john@example.com,0400123456
Mary Jones,mary@example.com,0400555123`
  }else if(importKind.value==='vehicles'){
    raw.value = `rego,vin,make,model,year
DYP49Y,JTDBR32E520123456,Toyota,Corolla,2015
ABC123,1HGCM82633A004352,Honda,Civic,2017`
  }else{
    raw.value = `status,problem_description,customer_id,vehicle_id
Booking,Engine light on,00000000-0000-0000-0000-000000000000,00000000-0000-0000-0000-000000000000`
  }
  parse()
}

/* simple CSV/TSV/table parser */
function parse(){
  parsed.headers = []; parsed.rows = []; resultMsg.value = ''; Object.keys(mapping).forEach(k => delete mapping[k])
  const text = raw.value.trim()
  if(!text){ return }
  const lines = text.split(/\r?\n/).filter(Boolean)
  if(!lines.length) return

  // detect delimiter
  const first = lines[0]
  let delim = ','
  if(first.includes('\t')) delim = '\t'
  else if(first.includes(';')) delim = ';'
  else if(first.split(',').length===1 && first.split(/\s{2,}/).length>1) delim = /\s{2,}/ // pasted table

  const cols = typeof delim==='string' ? first.split(delim).map(s => s.trim()) : first.split(delim)
  parsed.headers = cols

  // naive guesser reset
  cols.forEach(h => mapping[h] = '')

  for(let i=1;i<lines.length;i++){
    const parts = typeof delim==='string' ? lines[i].split(delim) : lines[i].split(delim)
    const row = {}
    cols.forEach((h,idx) => row[h] = (parts[idx]||'').trim())
    parsed.rows.push(row)
  }
}

async function runImport(){
  if(!parsed.rows.length) return
  state.importing = true
  resultMsg.value = ''
  try{
    const selected = allowedColumns[importKind.value]
    const rows = parsed.rows.map(r => {
      const o = {}
      for(const [src,dst] of Object.entries(mapping)){
        if(dst && selected.includes(dst)) o[dst] = r[src]
      }
      return o
    }).filter(r => Object.keys(r).length>0)

    let ok=0, fail=0
    if(importKind.value==='customers'){
      for(const r of rows){
        if(!r.name && !r.email && !r.phone){ fail++; continue }
        let id
        if(r.email){
          const { data, error } = await supabase.from('customers').select('id').ilike('email', r.email).limit(1)
          if(error){ fail++; continue }
          id = data?.[0]?.id
        }
        if(!id && r.phone){
          const { data, error } = await supabase.from('customers').select('id').ilike('phone', r.phone).limit(1)
          if(error){ fail++; continue }
          id = data?.[0]?.id
        }
        const q = id
          ? supabase.from('customers').update(r).eq('id', id)
          : supabase.from('customers').insert(r)
        const { error } = await q
        error ? fail++ : ok++
      }
      await loadCustomers()
    } else if(importKind.value==='vehicles'){
      if(vehicleTableMissing.value) throw new Error('Vehicles table not found in this project.')
      for(const r of rows){
        if(!r.rego && !r.vin){ fail++; continue }
        let id
        if(r.rego){
          const { data, error } = await supabase.from('vehicles').select('id').ilike('rego', r.rego).limit(1)
          if(error){ fail++; continue }
          id = data?.[0]?.id
        }
        const q = id
          ? supabase.from('vehicles').update(r).eq('id', id)
          : supabase.from('vehicles').insert(r)
        const { error } = await q
        error ? fail++ : ok++
      }
      await loadVehicles()
    } else {
      for(const r of rows){
        if(!r.problem_description || !r.customer_id || !r.vehicle_id){ fail++; continue }
        const { error } = await supabase.from('jobs').insert(r)
        error ? fail++ : ok++
      }
      await loadJobs()
    }

    resultMsg.value = `Done: ${ok} ok, ${fail} failed`
  }catch(e){
    resultMsg.value = `Error: ${e.message||e}`
  }finally{
    state.importing = false
  }
}
</script>

<style scoped>
.container{max-width:1100px;margin:0 auto}
.admin-header h1{margin:0}
.muted{color:#6b7280}
.tabs{display:flex;gap:8px;margin:12px 0 16px}
.tab{padding:8px 12px;border:1px solid #e5e7eb;background:#fff;border-radius:8px;cursor:pointer}
.tab.active{background:#eef2ff;border-color:#c7d2fe}
.data-grid{display:grid;grid-template-columns:1fr;gap:16px}
@media (min-width: 960px){.data-grid{grid-template-columns:1fr 1fr}}
.panel{border:1px solid #e5e7eb;border-radius:12px;background:#fff}
.panel-head{padding:12px 14px;border-bottom:1px dashed #e5e7eb;display:flex;align-items:center;justify-content:space-between;gap:12px}
.panel-body{padding:12px 14px}
.row{display:flex;align-items:center}
.wrap{flex-wrap:wrap}
.gap8{gap:8px} .gap12{gap:12px}
.input{border:1px solid #e5e7eb;border-radius:10px;padding:8px 10px;min-width:140px;background:#fff}
.input.sm{padding:6px 8px}
.textarea{width:100%;border:1px solid #e5e7eb;border-radius:10px;padding:10px;margin-top:10px}
.button{border:1px solid #d1d5db;background:#f9fafb;border-radius:10px;padding:8px 12px;cursor:pointer}
.button.primary{background:#2563eb;color:#fff;border-color:#2563eb}
.button.ghost{background:#fff}
.button.danger{background:#fee2e2;border-color:#fecaca;color:#b91c1c}
.button.sm{padding:4px 8px}
.table{display:grid;gap:6px;margin-top:10px}
.table.compact .cell{padding:4px 6px}
.thead,.row{display:grid;grid-template-columns: 1.3fr 1.2fr 1.1fr 1.1fr 0.8fr}
.table .thead{font-weight:600;color:#374151}
.table .row .cell, .table .thead > div{padding:6px;border:1px solid #f1f5f9;border-radius:8px;background:#fff}
.table .row input.cell, .table .row select.cell{padding:6px;border:1px solid #e5e7eb;border-radius:8px;background:#fff}
.table .tfoot{margin-top:6px}
.right{justify-self:end}
.empty{padding:12px;color:#6b7280}
.hr{height:1px;background:#e5e7eb;margin:10px 0}
.map-grid{display:grid;grid-template-columns:1fr 240px;gap:8px;max-width:620px}
.error{margin-top:12px;color:#ef4444}
</style>
