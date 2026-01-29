<script setup>
import { ref, onMounted, watch } from 'vue'
import { fetchCustomerOptions, fetchVehicleOptions, createJob, updateJob, deleteRow } from '@/api/jobs.api'

const props = defineProps({
  job: Object, // null for new job
  visible: Boolean
})

const emit = defineEmits(['close', 'saved'])

const form = ref({
  status: 'booking',
  problem_description: '',
  customer_id: null,
  vehicle_id: null,
  shop_id: null
})

const customers = ref([])
const vehicles = ref([])
const loading = ref(false)
const deleting = ref(false)

const statuses = ['booking', 'in progress', 'awaiting parts', 'complete']

async function loadOptions() {
  try {
    const [c, v] = await Promise.all([
      fetchCustomerOptions(),
      fetchVehicleOptions()
    ])
    customers.value = c
    vehicles.value = v
  } catch (e) {
    alert('Error loading options: ' + e.message)
  }
}

watch(() => props.job, (newJob) => {
  if (newJob) {
    form.value = {
      status: newJob.status || 'booking',
      problem_description: newJob.problem_description || '',
      customer_id: newJob.customer_id || null,
      vehicle_id: newJob.vehicle_id || null,
      shop_id: newJob.shop_id || null
    }
  } else {
    form.value = {
      status: 'booking',
      problem_description: '',
      customer_id: null,
      vehicle_id: null,
      shop_id: null
    }
  }
}, { immediate: true })

async function save() {
  loading.value = true
  try {
    if (props.job) {
      await updateJob({ id: props.job.id, ...form.value })
    } else {
      await createJob(form.value)
    }
    emit('saved')
    emit('close')
  } catch (e) {
    alert('Error saving: ' + e.message)
  } finally {
    loading.value = false
  }
}

async function deleteJob() {
  if (!confirm('Delete this job?')) return
  deleting.value = true
  try {
    await deleteRow('jobs', props.job.id)
    emit('saved')
    emit('close')
  } catch (e) {
    alert('Error deleting: ' + e.message)
  } finally {
    deleting.value = false
  }
}

onMounted(loadOptions)
</script>

<template>
  <div v-if="visible" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal">
      <div class="modal-header">
        <h2>{{ job ? 'Edit Job' : 'New Job' }}</h2>
        <button class="close" @click="$emit('close')">×</button>
      </div>

      <div class="modal-body">
        <div class="field">
          <label>Status</label>
          <select v-model="form.status">
            <option v-for="s in statuses" :key="s" :value="s">{{ s }}</option>
          </select>
        </div>

        <div class="field">
          <label>Customer</label>
          <select v-model="form.customer_id">
            <option :value="null">Select customer...</option>
            <option v-for="c in customers" :key="c.value" :value="c.value">{{ c.label }}</option>
          </select>
        </div>

        <div class="field">
          <label>Vehicle</label>
          <select v-model="form.vehicle_id">
            <option :value="null">Select vehicle...</option>
            <option v-for="v in vehicles" :key="v.value" :value="v.value">{{ v.label }}</option>
          </select>
        </div>

        <div class="field">
          <label>Problem Description</label>
          <textarea v-model="form.problem_description" rows="4"></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button v-if="job" @click="deleteJob" :disabled="deleting" class="btn-danger">Delete</button>
        <button @click="$emit('close')" class="btn-ghost">Cancel</button>
        <button @click="save" :disabled="loading" class="btn-primary">{{ loading ? 'Saving...' : 'Save' }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: #fff;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem;
  border-bottom: 1px solid #eee;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
}

.close {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #999;
  line-height: 1;
}

.modal-body {
  padding: 1.25rem;
}

.field {
  margin-bottom: 1rem;
}

.field label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 600;
  font-size: 0.9rem;
}

.field input,
.field select,
.field textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-family: inherit;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 1rem 1.25rem;
  border-top: 1px solid #eee;
}

button {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  font-weight: 500;
}

.btn-primary {
  background: #111;
  color: #fff;
}

.btn-ghost {
  background: #f5f5f5;
  color: #333;
}

.btn-danger {
  background: #ef4444;
  color: #fff;
  margin-right: auto;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
