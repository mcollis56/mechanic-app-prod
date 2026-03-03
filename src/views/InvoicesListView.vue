<script setup>
import { ref, computed, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';
import { useRouter } from 'vue-router';

const router = useRouter();
const invoices = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const statusFilter = ref('all');

// Quick Invoice modal state
const showQuickInvoice = ref(false);
const customers = ref([]);
const customerSearch = ref('');
const selectedCustomerId = ref('');
const quickInvoiceCreating = ref(false);
let customerDebounce = null;

const searchCustomers = () => {
  if (customerDebounce) clearTimeout(customerDebounce);
  customerDebounce = setTimeout(async () => {
    const q = customerSearch.value.trim();
    if (!q) { customers.value = []; return; }
    const { data } = await supabase
      .from('customers')
      .select('id, name, email')
      .ilike('name', `%${q}%`)
      .order('name', { ascending: true })
      .limit(20);
    customers.value = data || [];
  }, 300);
};

const createQuickInvoice = async () => {
  if (!selectedCustomerId.value) {
    alert('Please select a customer');
    return;
  }

  try {
    quickInvoiceCreating.value = true;

    // Generate invoice number
    const invoiceNumber = `INV-${Date.now().toString(36).toUpperCase()}`;

    // Calculate due date (30 days from now)
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 30);

    const { data: invoice, error } = await supabase
      .from('invoices')
      .insert({
        customer_id: selectedCustomerId.value,
        invoice_number: invoiceNumber,
        status: 'draft',
        due_date: dueDate.toISOString().split('T')[0],
        notes: 'Quick invoice'
      })
      .select()
      .single();

    if (error) throw error;

    showQuickInvoice.value = false;
    router.push(`/invoice/${invoice.id}`);
  } catch (err) {
    alert(`Error creating invoice: ${err.message}`);
    console.error(err);
  } finally {
    quickInvoiceCreating.value = false;
  }
};

const closeQuickInvoice = () => {
  showQuickInvoice.value = false;
  customerSearch.value = '';
  customers.value = [];
  selectedCustomerId.value = '';
};

const fetchInvoices = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error } = await supabase
      .from('invoices')
      .select(`
        *,
        customers (
          id,
          name,
          email
        )
      `)
      .order('created_at', { ascending: false });

    if (error) throw error;
    invoices.value = data || [];
  } catch (err) {
    errorMsg.value = `Error fetching invoices: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const filteredInvoices = computed(() => {
  if (statusFilter.value === 'all') {
    return invoices.value;
  }
  return invoices.value.filter(inv => inv.status === statusFilter.value);
});

const statusCounts = computed(() => {
  return {
    all: invoices.value.length,
    draft: invoices.value.filter(i => i.status === 'draft').length,
    sent: invoices.value.filter(i => i.status === 'sent').length,
    paid: invoices.value.filter(i => i.status === 'paid').length,
    cancelled: invoices.value.filter(i => i.status === 'cancelled').length
  };
});

const getStatusColor = (status) => {
  const colors = {
    draft: 'bg-gray-100 text-gray-700',
    sent: 'bg-blue-100 text-blue-700',
    paid: 'bg-green-100 text-green-700',
    cancelled: 'bg-red-100 text-red-700'
  };
  return colors[status] || 'bg-gray-100 text-gray-700';
};

const viewInvoice = (invoiceId) => {
  router.push(`/invoice/${invoiceId}`);
};

onMounted(fetchInvoices);
</script>

<template>
  <div class="invoices-list p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Invoices</h1>
          <p class="text-gray-600 mt-1">Manage and track all invoices</p>
        </div>
        <div class="flex gap-3">
          <button
            @click="showQuickInvoice = true"
            class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white font-semibold rounded-lg transition-colors"
          >
            + Quick Invoice
          </button>
          <button
            @click="fetchInvoices"
            :disabled="loading"
            class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50"
          >
            {{ loading ? 'Loading...' : 'Refresh' }}
          </button>
        </div>
      </div>
    </header>

    <!-- Status Filter Tabs -->
    <div class="mb-6 bg-white rounded-lg shadow p-2 flex gap-2">
      <button
        @click="statusFilter = 'all'"
        :class="statusFilter === 'all' ? 'bg-purple-100 text-purple-700' : 'text-gray-600 hover:bg-gray-100'"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        All ({{ statusCounts.all }})
      </button>
      <button
        @click="statusFilter = 'draft'"
        :class="statusFilter === 'draft' ? 'bg-purple-100 text-purple-700' : 'text-gray-600 hover:bg-gray-100'"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        Draft ({{ statusCounts.draft }})
      </button>
      <button
        @click="statusFilter = 'sent'"
        :class="statusFilter === 'sent' ? 'bg-purple-100 text-purple-700' : 'text-gray-600 hover:bg-gray-100'"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        Sent ({{ statusCounts.sent }})
      </button>
      <button
        @click="statusFilter = 'paid'"
        :class="statusFilter === 'paid' ? 'bg-purple-100 text-purple-700' : 'text-gray-600 hover:bg-gray-100'"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        Paid ({{ statusCounts.paid }})
      </button>
      <button
        @click="statusFilter = 'cancelled'"
        :class="statusFilter === 'cancelled' ? 'bg-purple-100 text-purple-700' : 'text-gray-600 hover:bg-gray-100'"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
      >
        Cancelled ({{ statusCounts.cancelled }})
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8 bg-white rounded-lg shadow">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading invoices...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredInvoices.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No invoices found</h3>
      <p class="mt-1 text-gray-500">
        {{ statusFilter !== 'all' ? `No ${statusFilter} invoices.` : 'Get started by completing a job and generating an invoice.' }}
      </p>
    </div>

    <!-- Invoices Table -->
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Invoice #</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Due Date</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="invoice in filteredInvoices" :key="invoice.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="text-sm font-medium text-gray-900">{{ invoice.invoice_number }}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900">{{ invoice.customers?.name || 'N/A' }}</div>
              <div class="text-xs text-gray-500">{{ invoice.customers?.email || '' }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span
                class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="getStatusColor(invoice.status)"
              >
                {{ invoice.status }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
              {{ new Date(invoice.created_at).toLocaleDateString() }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
              {{ invoice.due_date ? new Date(invoice.due_date).toLocaleDateString() : 'N/A' }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium text-gray-900">
              ${{ parseFloat(invoice.total_amount || 0).toFixed(2) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button
                @click="viewInvoice(invoice.id)"
                class="text-purple-600 hover:text-purple-900 transition-colors"
              >
                View
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Table Footer -->
      <div class="bg-gray-50 px-6 py-3 border-t border-gray-200">
        <div class="flex justify-between items-center text-sm">
          <p class="text-gray-700">
            Showing <span class="font-semibold">{{ filteredInvoices.length }}</span> of
            <span class="font-semibold">{{ invoices.length }}</span> invoice{{ invoices.length !== 1 ? 's' : '' }}
          </p>
          <p class="text-gray-700">
            Total: <span class="font-semibold">${{ filteredInvoices.reduce((sum, inv) => sum + parseFloat(inv.total_amount || 0), 0).toFixed(2) }}</span>
          </p>
        </div>
      </div>
    </div>
    <!-- Quick Invoice Modal -->
    <div v-if="showQuickInvoice" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
        <div class="flex justify-between items-center p-6 border-b border-gray-200">
          <h2 class="text-xl font-bold text-gray-900">New Quick Invoice</h2>
          <button @click="closeQuickInvoice" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="p-6 space-y-4">
          <p class="text-sm text-gray-600">Create a blank invoice for a customer. You can add line items on the next screen.</p>

          <!-- Customer Search -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Customer <span class="text-red-500">*</span></label>
            <input
              v-model="customerSearch"
              @input="searchCustomers"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500 text-sm"
              placeholder="Type to search customers..."
            />
            <!-- Customer Results -->
            <div v-if="customers.length > 0 && !selectedCustomerId" class="mt-1 border border-gray-200 rounded-md max-h-40 overflow-y-auto">
              <button
                v-for="c in customers"
                :key="c.id"
                @click="selectedCustomerId = c.id; customerSearch = c.name"
                class="w-full text-left px-3 py-2 text-sm hover:bg-purple-50 transition-colors border-b border-gray-100 last:border-b-0"
              >
                <span class="font-medium text-gray-900">{{ c.name }}</span>
                <span v-if="c.email" class="text-gray-500 ml-2">{{ c.email }}</span>
              </button>
            </div>
            <!-- Selected indicator -->
            <div v-if="selectedCustomerId" class="mt-1 flex items-center gap-2">
              <span class="text-sm text-green-700 font-medium">Customer selected</span>
              <button @click="selectedCustomerId = ''; customerSearch = ''; customers = []" class="text-xs text-red-600 hover:text-red-800">Change</button>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-3 pt-4">
            <button
              @click="closeQuickInvoice"
              class="flex-1 px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              @click="createQuickInvoice"
              :disabled="!selectedCustomerId || quickInvoiceCreating"
              class="flex-1 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ quickInvoiceCreating ? 'Creating...' : 'Create Invoice' }}
            </button>
          </div>
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
