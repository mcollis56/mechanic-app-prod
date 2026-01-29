<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';
import CustomerEditor from '../components/CustomerEditor.vue';

const customers = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const showCustomerEditor = ref(false);
const selectedCustomer = ref(null);

const fetchCustomers = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    customers.value = data;
  } catch (err) {
    errorMsg.value = `Error fetching customers: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const openCustomerEditor = (customer = null) => {
  selectedCustomer.value = customer ? { ...customer } : {};
  showCustomerEditor.value = true;
};

const handleCustomerSaved = () => {
  showCustomerEditor.value = false;
  selectedCustomer.value = null;
  fetchCustomers();
};

const deleteCustomer = async (customer) => {
  if (!confirm(`Are you sure you want to delete ${customer.name}? This action cannot be undone.`)) {
    return;
  }

  try {
    const { error } = await supabase
      .from('customers')
      .delete()
      .eq('id', customer.id);

    if (error) throw error;

    // Refresh the list
    await fetchCustomers();
  } catch (err) {
    alert(`Error deleting customer: ${err.message}`);
    console.error('Error deleting customer:', err);
  }
};

onMounted(fetchCustomers);
</script>

<template>
  <div class="customers-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold text-gray-900">Customers</h1>
        <button
          @click="openCustomerEditor()"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
        >
          + New Customer
        </button>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading customers...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Empty State -->
    <div v-else-if="customers.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No customers</h3>
      <p class="mt-1 text-gray-500">Get started by creating a new customer.</p>
      <button
        @click="openCustomerEditor()"
        class="mt-4 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
      >
        + New Customer
      </button>
    </div>

    <!-- Customers Table -->
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Name
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Email
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Phone
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="customer in customers" :key="customer.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <router-link
                :to="`/customers/${customer.id}`"
                class="text-sm font-medium text-purple-600 hover:text-purple-900 transition-colors"
              >
                {{ customer.name }}
              </router-link>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">{{ customer.email }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">{{ customer.phone || '—' }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button
                @click="openCustomerEditor(customer)"
                class="text-purple-600 hover:text-purple-900 mr-4 transition-colors"
              >
                Edit
              </button>
              <button
                @click="deleteCustomer(customer)"
                class="text-red-600 hover:text-red-900 transition-colors"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Table Footer with Count -->
      <div class="bg-gray-50 px-6 py-3 border-t border-gray-200">
        <p class="text-sm text-gray-700">
          Total: <span class="font-semibold">{{ customers.length }}</span> customer{{ customers.length !== 1 ? 's' : '' }}
        </p>
      </div>
    </div>

    <!-- Customer Editor Modal -->
    <CustomerEditor
      v-model="showCustomerEditor"
      :customer="selectedCustomer"
      @customerSaved="handleCustomerSaved"
    />
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
