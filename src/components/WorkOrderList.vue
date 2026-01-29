<template>
  <div class="work-order-list p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold text-gray-900">Work Orders</h1>
        <router-link
          to="/work-orders/create"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
        >
          + New Work Order
        </router-link>
      </div>
    </header>

    <!-- Loading state -->
    <div v-if="loading" class="status-message">Loading work orders…</div>

    <!-- Error state -->
    <div v-else-if="error" class="error-message">
      <p>❌ Error: {{ error }}</p>
      <button @click="fetchWorkOrders">Retry</button>
    </div>

    <!-- Empty state -->
    <div v-else-if="workOrders.length === 0" class="empty-message">
      <p>No work orders found. Create your first work order!</p>
    </div>

    <!-- Table of work orders -->
    <div v-else>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Customer</th>
            <th>Vehicle</th>
            <th>Status</th>
            <th>Created</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="order in workOrders" :key="order.id">
            <!-- Clickable ID links to detail page -->
            <td>
              <router-link :to="`/work-orders/${order.id}`" class="text-purple-600 hover:text-purple-900">
                {{ order.id.slice(0, 8) }}...
              </router-link>
            </td>
            <td>{{ order.customers?.name || '-' }}</td>
            <td>
              <span v-if="order.vehicles">
                {{ order.vehicles.make }} {{ order.vehicles.model }}
                <span v-if="order.vehicles.rego" class="text-gray-500">({{ order.vehicles.rego }})</span>
              </span>
              <span v-else>-</span>
            </td>
            <td>
              <span class="px-2 py-1 text-xs font-medium rounded-full"
                :class="{
                  'bg-yellow-100 text-yellow-800': order.status === 'draft',
                  'bg-blue-100 text-blue-800': order.status === 'in_progress',
                  'bg-green-100 text-green-800': order.status === 'completed' || order.status === 'pink_slip_lodged',
                  'bg-orange-100 text-orange-800': order.status === 'awaiting_inspection',
                  'bg-red-100 text-red-800': order.status === 'inspection_failed'
                }">
                {{ order.status?.replace(/_/g, ' ') || 'unknown' }}
              </span>
            </td>
            <td>{{ new Date(order.created_at).toLocaleDateString('en-AU') }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabaseClient' // adjust this path if your Supabase client lives elsewhere

// reactive state
const workOrders = ref([])
const loading = ref(true)
const error = ref(null)

// fetch data from Supabase with customer and vehicle names
const fetchWorkOrders = async () => {
  try {
    const { data, error: fetchError } = await supabase
      .from('work_orders')
      .select('*, customers(name), vehicles(make, model, rego)')
      .order('created_at', { ascending: false })

    if (fetchError) {
      console.error('Error fetching work orders:', fetchError)
      error.value = fetchError.message
    } else {
      workOrders.value = data || []
    }
  } catch (err) {
    console.error('Unexpected error:', err)
    error.value = 'An unexpected error occurred while loading work orders'
  } finally {
    loading.value = false
  }
}

// run on component mount
onMounted(() => {
  fetchWorkOrders()
})
</script>

<style scoped>
.work-order-list {
  padding: 20px;
}

.status-message,
.error-message,
.empty-message {
  padding: 20px;
  margin: 20px 0;
  border-radius: 8px;
  text-align: center;
}

.status-message {
  background-color: #e3f2fd;
  color: #1976d2;
}

.error-message {
  background-color: #ffebee;
  color: #c62828;
}

.error-message button {
  margin-top: 10px;
  padding: 8px 16px;
  background-color: #c62828;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.error-message button:hover {
  background-color: #b71c1c;
}

.empty-message {
  background-color: #f5f5f5;
  color: #666;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  border-bottom: 1px solid #ddd;
}

/* Hover effect for better UX */
tr:hover {
  background-color: #f5f5f5;
}
</style>
