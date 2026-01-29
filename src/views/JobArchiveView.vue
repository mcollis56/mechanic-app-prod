<script setup>
import { ref, computed, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';
import { useRouter } from 'vue-router';

const router = useRouter();
const jobs = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const searchQuery = ref('');
const dateFilter = ref('all');
const customerFilter = ref('all');

const fetchArchivedJobs = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    // First get all invoices with their job_id
    const { data: invoicesData, error: invError } = await supabase
      .from('invoices')
      .select('job_id');

    if (invError) throw invError;

    const jobIds = invoicesData.map(inv => inv.job_id).filter(id => id !== null);

    if (jobIds.length === 0) {
      jobs.value = [];
      return;
    }

    // Then get all jobs that have invoices
    const { data, error } = await supabase
      .from('jobs')
      .select(`
        *,
        customers (
          id,
          name,
          email
        ),
        vehicles (
          id,
          make,
          model,
          rego
        ),
        invoices (
          id,
          invoice_number,
          status,
          created_at
        )
      `)
      .in('id', jobIds)
      .order('created_at', { ascending: false });

    if (error) throw error;
    jobs.value = data || [];
  } catch (err) {
    errorMsg.value = `Error fetching archived jobs: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const filteredJobs = computed(() => {
  let filtered = jobs.value;

  // Search filter
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(job => {
      const customerName = job.customers?.name?.toLowerCase() || '';
      const vehicleRego = job.vehicles?.rego?.toLowerCase() || '';
      const description = (job.problem_description || job.description || '').toLowerCase();
      const invoiceNumber = job.invoices?.[0]?.invoice_number?.toLowerCase() || '';

      return customerName.includes(query) ||
             vehicleRego.includes(query) ||
             description.includes(query) ||
             invoiceNumber.includes(query);
    });
  }

  // Date filter
  if (dateFilter.value !== 'all') {
    const now = new Date();
    const filterDate = new Date();

    switch (dateFilter.value) {
      case 'week':
        filterDate.setDate(now.getDate() - 7);
        break;
      case 'month':
        filterDate.setMonth(now.getMonth() - 1);
        break;
      case 'quarter':
        filterDate.setMonth(now.getMonth() - 3);
        break;
      case 'year':
        filterDate.setFullYear(now.getFullYear() - 1);
        break;
    }

    filtered = filtered.filter(job => {
      const jobDate = job.invoices?.[0]?.created_at
        ? new Date(job.invoices[0].created_at)
        : new Date(job.created_at);
      return jobDate >= filterDate;
    });
  }

  // Customer filter
  if (customerFilter.value !== 'all') {
    filtered = filtered.filter(job => job.customer_id === customerFilter.value);
  }

  return filtered;
});

const uniqueCustomers = computed(() => {
  const customers = jobs.value
    .map(job => job.customers)
    .filter(c => c !== null && c !== undefined);

  const unique = Array.from(
    new Map(customers.map(c => [c.id, c])).values()
  );

  return unique.sort((a, b) => {
    const nameA = a?.name || '';
    const nameB = b?.name || '';
    return nameA.localeCompare(nameB);
  });
});

const viewInvoice = (invoiceId) => {
  router.push(`/invoice/${invoiceId}`);
};

const viewJob = (jobId) => {
  router.push(`/?job=${jobId}`);
};

onMounted(fetchArchivedJobs);
</script>

<template>
  <div class="archive-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Job Archive</h1>
          <p class="text-gray-600 mt-1">Complete job history with invoices</p>
        </div>
        <button
          @click="fetchArchivedJobs"
          :disabled="loading"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50"
        >
          {{ loading ? 'Loading...' : 'Refresh' }}
        </button>
      </div>
    </header>

    <!-- Filters Section -->
    <div class="bg-white rounded-lg shadow p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Search -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Search</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Customer, rego, job description..."
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
          />
        </div>

        <!-- Date Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Time Period</label>
          <select
            v-model="dateFilter"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
            <option value="all">All Time</option>
            <option value="week">Last 7 Days</option>
            <option value="month">Last Month</option>
            <option value="quarter">Last 3 Months</option>
            <option value="year">Last Year</option>
          </select>
        </div>

        <!-- Customer Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Customer</label>
          <select
            v-model="customerFilter"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
            <option value="all">All Customers</option>
            <option v-for="customer in uniqueCustomers" :key="customer.id" :value="customer.id">
              {{ customer.name }}
            </option>
          </select>
        </div>
      </div>

      <!-- Results Count -->
      <div class="mt-3 text-sm text-gray-600">
        Showing {{ filteredJobs.length }} of {{ jobs.length }} archived job{{ jobs.length !== 1 ? 's' : '' }}
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8 bg-white rounded-lg shadow">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading archived jobs...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredJobs.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No archived jobs found</h3>
      <p class="mt-1 text-gray-500">
        {{ searchQuery || dateFilter !== 'all' || customerFilter !== 'all'
          ? 'Try adjusting your filters.'
          : 'Complete jobs will appear here.' }}
      </p>
    </div>

    <!-- Jobs Table -->
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Job #</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Vehicle</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Completed</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Invoice</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="job in filteredJobs" :key="job.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="text-sm font-medium text-gray-900">#{{ job.id }}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900">{{ job.customers?.name || 'N/A' }}</div>
              <div class="text-xs text-gray-500">{{ job.customers?.email || '' }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900">{{ job.vehicles?.rego || 'N/A' }}</div>
              <div class="text-xs text-gray-500">{{ job.vehicles?.make }} {{ job.vehicles?.model }}</div>
            </td>
            <td class="px-6 py-4">
              <div class="text-sm text-gray-900 max-w-xs truncate">
                {{ job.problem_description || job.description || 'N/A' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
              {{ job.invoices?.[0]?.created_at
                ? new Date(job.invoices[0].created_at).toLocaleDateString()
                : new Date(job.created_at).toLocaleDateString() }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div v-if="job.invoices && job.invoices.length > 0">
                <button
                  @click="viewInvoice(job.invoices[0].id)"
                  class="text-purple-600 hover:text-purple-900 font-medium text-sm"
                >
                  {{ job.invoices[0].invoice_number }}
                </button>
                <div class="text-xs text-gray-500 capitalize">
                  {{ job.invoices[0].status }}
                </div>
              </div>
              <span v-else class="text-sm text-gray-400">No invoice</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button
                @click="viewJob(job.id)"
                class="text-gray-600 hover:text-gray-900 transition-colors"
              >
                View Job
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Table Footer -->
      <div class="bg-gray-50 px-6 py-3 border-t border-gray-200">
        <div class="flex justify-between items-center text-sm">
          <p class="text-gray-700">
            Total archived jobs: <span class="font-semibold">{{ filteredJobs.length }}</span>
          </p>
          <p class="text-gray-700">
            With invoices: <span class="font-semibold">{{
              filteredJobs.filter(j => j.invoices && j.invoices.length > 0).length
            }}</span>
          </p>
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
