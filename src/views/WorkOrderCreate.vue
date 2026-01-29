<template>
  <div class="p-6 max-w-2xl mx-auto">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Create Work Order</h1>
      <p class="text-gray-600 mt-1">Create a new work order for a customer vehicle</p>
    </div>

    <form @submit.prevent="createWorkOrder" class="bg-white rounded-lg shadow p-6 space-y-6">
      <!-- Customer Selection -->
      <div>
        <label for="customer" class="block text-sm font-medium text-gray-700 mb-1">
          Customer <span class="text-red-500">*</span>
        </label>
        <select
          id="customer"
          v-model="selectedCustomer"
          @change="onCustomerChange"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          required
        >
          <option value="">Select a customer...</option>
          <option v-for="customer in customers" :key="customer.id" :value="customer.id">
            {{ customer.name }}
          </option>
        </select>
      </div>

      <!-- Vehicle Selection -->
      <div>
        <label for="vehicle" class="block text-sm font-medium text-gray-700 mb-1">
          Vehicle <span class="text-red-500">*</span>
        </label>
        <select
          id="vehicle"
          v-model="selectedVehicle"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          :disabled="!selectedCustomer || filteredVehicles.length === 0"
          required
        >
          <option value="">{{ selectedCustomer ? (filteredVehicles.length > 0 ? 'Select a vehicle...' : 'No vehicles found') : 'Select a customer first' }}</option>
          <option v-for="vehicle in filteredVehicles" :key="vehicle.id" :value="vehicle.id">
            {{ vehicle.registration || vehicle.rego }} - {{ vehicle.make }} {{ vehicle.model }} ({{ vehicle.year || 'N/A' }})
          </option>
        </select>
        <p v-if="selectedCustomer && filteredVehicles.length === 0" class="text-sm text-orange-600 mt-1">
          No vehicles found for this customer
        </p>
      </div>

      <!-- Job Type -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Job Type</label>
        <div class="flex gap-4">
          <label class="flex items-center">
            <input
              type="radio"
              v-model="jobType"
              value="standard"
              class="w-4 h-4 text-purple-600 border-gray-300 focus:ring-purple-500"
            />
            <span class="ml-2 text-gray-700">Standard Service</span>
          </label>
          <label class="flex items-center">
            <input
              type="radio"
              v-model="jobType"
              value="rego_renewal"
              class="w-4 h-4 text-purple-600 border-gray-300 focus:ring-purple-500"
            />
            <span class="ml-2 text-gray-700">Rego Renewal / Pink Slip</span>
          </label>
        </div>
      </div>

      <!-- Pink Slip Info Box -->
      <div v-if="jobType === 'rego_renewal'" class="bg-purple-50 border border-purple-200 rounded-lg p-4">
        <div class="flex items-start">
          <svg class="w-5 h-5 text-purple-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h4 class="font-medium text-purple-800">eSafety Inspection (Pink Slip)</h4>
            <p class="text-sm text-purple-700 mt-1">
              This work order will include the eSafety inspection workflow. After completing any required work, you'll be able to record the inspection result and issue the Pink Slip.
            </p>
          </div>
        </div>
      </div>

      <!-- Summary -->
      <div>
        <label for="summary" class="block text-sm font-medium text-gray-700 mb-1">
          Summary <span class="text-red-500">*</span>
        </label>
        <textarea
          id="summary"
          v-model="summary"
          rows="3"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          placeholder="Describe the work to be done..."
          required
        ></textarea>
      </div>

      <!-- Error Message -->
      <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
        {{ errorMsg }}
      </div>

      <!-- Actions -->
      <div class="flex justify-end gap-4 pt-4 border-t border-gray-200">
        <button
          type="button"
          @click="router.push('/work-orders')"
          class="px-6 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors"
        >
          Cancel
        </button>
        <button
          type="submit"
          :disabled="isSubmitting"
          class="px-6 py-2 bg-purple-600 text-white font-semibold rounded-lg hover:bg-purple-700 disabled:bg-purple-400 disabled:cursor-not-allowed transition-colors"
        >
          {{ isSubmitting ? 'Creating...' : 'Create Work Order' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { supabase } from '@/supabaseClient.js'
import { useRouter } from 'vue-router'

const router = useRouter()
const customers = ref([])
const vehicles = ref([])
const selectedCustomer = ref('')
const selectedVehicle = ref('')
const summary = ref('')
const jobType = ref('standard')
const isSubmitting = ref(false)
const errorMsg = ref('')

// Filter vehicles by selected customer
const filteredVehicles = computed(() => {
  return vehicles.value
})

// Watch for customer changes to fetch their vehicles
watch(selectedCustomer, async (newCustomerId) => {
  selectedVehicle.value = ''
  if (!newCustomerId) {
    vehicles.value = []
    return
  }

  try {
    const { data, error } = await supabase
      .from('vehicles')
      .select('*')
      .eq('customer_id', newCustomerId)
      .order('rego', { ascending: true })
    
    if (error) throw error
    vehicles.value = data || []
  } catch (err) {
    console.error('Error fetching vehicles for customer:', err)
    errorMsg.value = 'Failed to load vehicles for the selected customer.'
  }
})

const onCustomerChange = () => {
  // Reset vehicle selection when customer changes
  selectedVehicle.value = ''
}

const fetchCustomers = async () => {
  const { data, error } = await supabase
    .from('customers')
    .select('*')
    .order('name', { ascending: true })
  if (!error) {
    customers.value = data || []
  }
}

const createWorkOrder = async () => {
  errorMsg.value = ''

  if (!selectedCustomer.value || !selectedVehicle.value || !summary.value.trim()) {
    errorMsg.value = 'Please fill out all required fields.'
    return
  }

  isSubmitting.value = true

  try {
    // Determine initial status based on job type
    const initialStatus = jobType.value === 'rego_renewal' ? 'awaiting_inspection' : 'draft'

    const { data, error } = await supabase
      .from('work_orders')
      .insert({
        customer_id: selectedCustomer.value,
        vehicle_id: selectedVehicle.value,
        summary: summary.value.trim(),
        status: initialStatus,
        job_type: jobType.value === 'rego_renewal' ? 'rego_renewal' : null
      })
      .select()
      .single()

    if (error) throw error

    // Navigate to the new work order
    router.push(`/work-orders/${data.id}`)

  } catch (err) {
    console.error('Error creating work order:', err)
    errorMsg.value = `Error creating work order: ${err.message}`
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  fetchCustomers()
})
</script>
