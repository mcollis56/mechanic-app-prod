<script setup>
import { onMounted, ref, computed } from "vue";
import { supabase } from "@/supabase";
import { useRouter } from "vue-router";
import JobDetailsModal from './JobDetailsModal.vue'

const router = useRouter();

const showModal = ref(false)
const selectedJob = ref(null)

function openNewJob() {
  selectedJob.value = null
  showModal.value = true
}

function openEditJob(job) {
  selectedJob.value = job
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedJob.value = null
}

function onJobSaved() {
  fetchJobs()
}

const columns = [
  { key: "booking",       title: "Booking" },
  { key: "in progress",   title: "In progress" },
  { key: "awaiting parts",title: "Awaiting parts" },
  { key: "complete",      title: "Complete" },
];

const jobs = ref([]);
const loading = ref(false);
const errorMsg = ref("");

function isUuid(v) {
  return typeof v === "string" &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
}

function showSendInvoice(job) {
  return isUuid(job.id) && String(job.status).toLowerCase() === "complete";
}

async function fetchJobs() {
  loading.value = true;
  errorMsg.value = "";
  
  // Query jobs table with joins to get VIN and Engine Code
  const { data, error } = await supabase
    .from("jobs")
    .select(`
      id, 
      status, 
      problem_description, 
      created_at,
      due_date,
      shop_id,
      customer_id,
      vehicle_id,
      customers (name),
      vehicles (rego, make, model, vin, engine_code)
    `)
    .order("created_at", { ascending: true });

  if (error) {
    errorMsg.value = error.message;
  } else {
    // Map data to match the expected structure for the board
    jobs.value = (data || []).map(j => ({
      id: j.id,
      status: j.status,
      problem_description: j.problem_description,
      created_at: j.created_at,
      due_date: j.due_date,
      shop_id: j.shop_id,
      customer_id: j.customer_id,
      vehicle_id: j.vehicle_id,
      customer_name: j.customers?.name || '—',
      vehicle_rego: j.vehicles?.rego || '—',
      vehicle_make_model: j.vehicles ? `${j.vehicles.make} ${j.vehicles.model}` : '—',
      vin: j.vehicles?.vin,
      engine_code: j.vehicles?.engine_code
    }));
  }
  loading.value = false;
}

const jobsByStatus = computed(() => {
  const buckets = Object.fromEntries(columns.map(c => [c.key, []]));
  for (const j of jobs.value) {
    const k = String(j.status || "").toLowerCase();
    if (buckets[k]) buckets[k].push(j);
  }
  return buckets;
});

async function ensureInvoice(job) {
  try {
    // Check if invoice already exists
    const { data: existing, error: checkErr } = await supabase
      .from("invoices")
      .select("id")
      .eq("job_id", job.id)
      .maybeSingle();

    if (checkErr) throw checkErr;

    let invoiceId = existing?.id;

    // Create if doesn't exist
    if (!invoiceId) {
      // Get the full job record with all IDs from jobs table
      const { data: jobData, error: jobErr } = await supabase
        .from("jobs")
        .select("*")
        .eq("id", job.id)
        .single();

      if (jobErr) throw jobErr;

      // Check required fields
      if (!jobData.shop_id || !jobData.customer_id || !jobData.vehicle_id) {
        throw new Error("Job is missing required shop_id, customer_id, or vehicle_id");
      }

      const invoiceNumber = `INV-${Date.now().toString().slice(-6)}`;

      const { data: newInv, error: createErr } = await supabase
        .from("invoices")
        .insert({
          job_id: job.id,
          shop_id: jobData.shop_id,
          customer_id: jobData.customer_id,
          vehicle_id: jobData.vehicle_id,
          invoice_number: invoiceNumber,
          status: "draft",
          subtotal: 0,
          tax: 0,
          total: 0,
          discount_amount: 0,
          discount_percentage: 0
        })
        .select("id")
        .single();

      if (createErr) throw createErr;
      invoiceId = newInv.id;
    }

    alert("Invoice created/updated 👍");

    if (invoiceId) {
      router.push({ name: "invoice", params: { id: invoiceId } });
    }
  } catch (e) {
    alert(`Could not create invoice: ${e.message || e}`);
    console.error("Invoice creation error:", e);
  }
}

onMounted(fetchJobs);
</script>

<template>
  <section class="board">
    <header class="board__header">
      <h1>Euro Motor Works</h1>
      <nav class="board__nav">
        <router-link to="/" class="nav-btn">Jobs</router-link>
        <router-link to="/customers" class="nav-btn">Customers</router-link>
        <router-link to="/invoices" class="nav-btn">Invoices</router-link>
        <router-link to="/reports" class="nav-btn">Reports</router-link>
        <router-link to="/admin" class="nav-btn">Admin</router-link>
      </nav>
      <div class="board__actions">
        <button @click="openNewJob" class="btn-new">+ New Job</button>
        <button @click="fetchJobs" :disabled="loading">Refresh</button>
      </div>
    </header>

    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>

    <div class="columns" v-if="!loading">
      <div v-for="col in columns" :key="col.key" class="col">
        <div class="col__title">
          {{ col.title }}
          <span class="badge">{{ jobsByStatus[col.key].length }}</span>
        </div>

        <div v-for="job in jobsByStatus[col.key]" :key="job.id"
             class="card"
             :class="{ 'card--legacy': !isUuid(job.id) }"
             @click="openEditJob(job)">
          <div class="card__line">
            <strong>{{ job.problem_description || '—' }}</strong>
          </div>
          <div class="card__sub">
            <span>{{ job.customer_name || '—' }}</span> •
            <span>{{ job.vehicle_rego || '—' }}</span> •
            <span>{{ job.vehicle_make_model || '—' }}</span>
          </div>
          <!-- VIN and Engine Code Visibility -->
          <div class="card__sub light" v-if="job.vin || job.engine_code">
            <span v-if="job.vin">VIN: {{ job.vin }}</span>
            <span v-if="job.vin && job.engine_code"> • </span>
            <span v-if="job.engine_code">Eng: {{ job.engine_code }}</span>
          </div>
          <div class="card__sub light">
            {{ new Date(job.created_at).toLocaleString() }}
          </div>

          <div class="card__actions">
            <!-- Only show on valid UUID jobs in the Complete column -->
            <button v-if="showSendInvoice(job)"
                    class="btn btn-outline"
                    @click.stop="ensureInvoice(job)">
              Send invoice
            </button>
            <!-- Hint for legacy numeric ids -->
            <small v-else-if="!isUuid(job.id)" class="hint">
              Legacy numeric ID — recreate via Admin → Quick fixes
            </small>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="loading">Loading…</div>

    <JobDetailsModal
      :visible="showModal"
      :job="selectedJob"
      @close="closeModal"
      @saved="onJobSaved"
    />
  </section>
</template>

<style scoped>
.board { padding: 1.25rem; }
.board__header { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1.5rem; background:#fff; padding:1rem; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.06); }
.board__nav { display:flex; gap:0.5rem; }
.nav-btn { padding:0.5rem 1rem; border-radius:8px; text-decoration:none; color:#333; background:#f5f5f5; transition:all 0.2s; }
.nav-btn:hover { background:#e5e5e5; }
.nav-btn.router-link-active { background:#111; color:#fff; }
.columns { display:grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; align-items:start; }
.col { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: .75rem; }
.col__title { font-weight: 600; margin-bottom: .5rem; display:flex; justify-content:space-between; }
.badge { background:#f3f3f3; border-radius: 999px; padding: 0 .5rem; font-size:.8rem; }
.card { border: 1px solid #ececec; border-radius: 12px; padding: .75rem; margin-bottom: .75rem; cursor: pointer; transition: all 0.2s; }
.card:hover { border-color: #999; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.card--legacy { border-style: dashed; }
.card__line { margin-bottom:.25rem; }
.card__sub { font-size:.9rem; }
.card__sub.light { color:#666; }
.card__actions { margin-top:.5rem; display:flex; gap:.5rem; align-items:center; }
.btn { padding: .4rem .7rem; border-radius: 10px; border: none; background: #111; color:#fff; cursor:pointer; }
.btn:disabled { opacity:.6; cursor:not-allowed; }
.btn.btn-outline { background: transparent; color:#111; border:1px solid #111; }
.hint { color:#b45400; }
.error { color:#b00020; margin:.5rem 0; }
.loading { opacity:.7; }
.btn-new { background:#111; color:#fff; font-weight:600; }
</style>
