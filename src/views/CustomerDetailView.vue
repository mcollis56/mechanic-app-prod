<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../supabaseClient.js';

const route = useRoute();
const router = useRouter();

const customer = ref(null);
const vehicles = ref([]);
const workOrders = ref([]);
const loading = ref(true);
const errorMsg = ref('');

const fetchCustomerData = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';
    const customerId = route.params.id;

    // Fetch customer details
    const { data: customerData, error: customerError } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customerId)
      .single();

    if (customerError) throw customerError;
    customer.value = customerData;

    // Fetch customer's vehicles
    const { data: vehiclesData, error: vehiclesError } = await supabase
      .from('vehicles')
      .select('*')
      .eq('customer_id', customerId)
      .order('make', { ascending: true });

    if (!vehiclesError) {
      vehicles.value = vehiclesData || [];
    }

    // Fetch customer's work orders (via vehicles)
    if (vehicles.value.length > 0) {
      const vehicleIds = vehicles.value.map(v => v.id);
      const { data: workOrdersData, error: workOrdersError } = await supabase
        .from('work_orders')
        .select('*, vehicles(make, model, registration)')
        .in('vehicle_id', vehicleIds)
        .order('created_at', { ascending: false });

      if (!workOrdersError) {
        workOrders.value = workOrdersData || [];
      }
    }

  } catch (err) {
    errorMsg.value = `Error loading customer: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const goBack = () => {
  router.push('/customers');
};

const formatDate = (dateString) => {
  if (!dateString) return '-';
  return new Date(dateString).toLocaleDateString('en-AU', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  });
};

const getStatusClass = (status) => {
  switch (status) {
    case 'draft':
      return 'bg-yellow-100 text-yellow-800';
    case 'in_progress':
      return 'bg-blue-100 text-blue-800';
    case 'completed':
      return 'bg-green-100 text-green-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

const totalWorkOrders = computed(() => workOrders.value.length);
const completedWorkOrders = computed(() =>
  workOrders.value.filter(wo => wo.status === 'completed').length
);

onMounted(fetchCustomerData);
</script>

<template>
  <div class="customer-detail-view p-6">
    <!-- Back Button -->
    <button
      @click="goBack"
      class="mb-6 flex items-center text-gray-600 hover:text-gray-900 transition-colors"
    >
      <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
      Back to Customers
    </button>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading customer details...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Customer Details -->
    <div v-else-if="customer" class="space-y-6">
      <!-- Customer Header Card -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-start">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{{ customer.name }}</h1>
            <p v-if="customer.company" class="text-lg text-gray-600 mt-1">{{ customer.company }}</p>
          </div>
          <div class="text-right">
            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800">
              {{ totalWorkOrders }} Work Order{{ totalWorkOrders !== 1 ? 's' : '' }}
            </span>
          </div>
        </div>

        <!-- Contact Information -->
        <div class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div v-if="customer.email" class="flex items-start">
            <svg class="w-5 h-5 text-gray-400 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            <div>
              <p class="text-sm text-gray-500">Email</p>
              <a :href="'mailto:' + customer.email" class="text-purple-600 hover:text-purple-800">
                {{ customer.email }}
              </a>
            </div>
          </div>

          <div v-if="customer.phone" class="flex items-start">
            <svg class="w-5 h-5 text-gray-400 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            <div>
              <p class="text-sm text-gray-500">Phone</p>
              <a :href="'tel:' + customer.phone" class="text-purple-600 hover:text-purple-800">
                {{ customer.phone }}
              </a>
            </div>
          </div>

          <div v-if="customer.address" class="flex items-start">
            <svg class="w-5 h-5 text-gray-400 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <div>
              <p class="text-sm text-gray-500">Address</p>
              <p class="text-gray-900">{{ customer.address }}</p>
            </div>
          </div>
        </div>

        <!-- Notes -->
        <div v-if="customer.notes" class="mt-6 pt-6 border-t border-gray-200">
          <p class="text-sm text-gray-500 mb-2">Notes</p>
          <p class="text-gray-700">{{ customer.notes }}</p>
        </div>
      </div>

      <!-- Vehicles Section -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-xl font-bold text-gray-900">Vehicles</h2>
          <span class="text-sm text-gray-500">{{ vehicles.length }} vehicle{{ vehicles.length !== 1 ? 's' : '' }}</span>
        </div>

        <div v-if="vehicles.length === 0" class="text-center py-8 bg-gray-50 rounded-lg">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
          </svg>
          <p class="mt-2 text-gray-500">No vehicles registered for this customer</p>
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="vehicle in vehicles"
            :key="vehicle.id"
            class="border border-gray-200 rounded-lg p-4 hover:border-purple-300 transition-colors"
          >
            <div class="flex justify-between items-start">
              <div>
                <h3 class="font-semibold text-gray-900">{{ vehicle.make }} {{ vehicle.model }}</h3>
                <p v-if="vehicle.year" class="text-sm text-gray-500">{{ vehicle.year }}</p>
              </div>
              <span v-if="vehicle.registration" class="px-2 py-1 bg-gray-100 text-gray-700 text-xs font-medium rounded">
                {{ vehicle.registration }}
              </span>
            </div>
            <div v-if="vehicle.vin" class="mt-2 text-xs text-gray-400">
              VIN: {{ vehicle.vin }}
            </div>
          </div>
        </div>
      </div>

      <!-- Work Orders Section -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-xl font-bold text-gray-900">Work Order History</h2>
          <div class="text-sm text-gray-500">
            {{ completedWorkOrders }} of {{ totalWorkOrders }} completed
          </div>
        </div>

        <div v-if="workOrders.length === 0" class="text-center py-8 bg-gray-50 rounded-lg">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          <p class="mt-2 text-gray-500">No work orders for this customer</p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Vehicle</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Summary</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="wo in workOrders" :key="wo.id" class="hover:bg-gray-50">
                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-600">
                  {{ formatDate(wo.created_at) }}
                </td>
                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                  <span v-if="wo.vehicles">
                    {{ wo.vehicles.make }} {{ wo.vehicles.model }}
                    <span v-if="wo.vehicles.registration" class="text-gray-500 ml-1">({{ wo.vehicles.registration }})</span>
                  </span>
                  <span v-else class="text-gray-400">-</span>
                </td>
                <td class="px-4 py-4 text-sm text-gray-600 max-w-xs truncate">
                  {{ wo.summary || '-' }}
                </td>
                <td class="px-4 py-4 whitespace-nowrap">
                  <span
                    :class="getStatusClass(wo.status)"
                    class="px-2 py-1 text-xs font-medium rounded-full"
                  >
                    {{ wo.status?.replace('_', ' ') || 'unknown' }}
                  </span>
                </td>
                <td class="px-4 py-4 whitespace-nowrap text-right text-sm">
                  <router-link
                    :to="`/work-orders/${wo.id}`"
                    class="text-purple-600 hover:text-purple-900"
                  >
                    View
                  </router-link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes spin {
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style>
