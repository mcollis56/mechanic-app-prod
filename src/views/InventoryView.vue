<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../supabaseClient.js';
import InventoryEditor from '../components/InventoryEditor.vue';

const inventory = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const showInventoryEditor = ref(false);
const selectedItem = ref(null);
const searchQuery = ref('');

const fetchInventory = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error } = await supabase
      .from('inventory')
      .select('*')
      .order('description', { ascending: true });

    if (error) throw error;
    inventory.value = data;
    console.log('Inventory columns:', data.length > 0 ? Object.keys(data[0]) : 'No data');
  } catch (err) {
    errorMsg.value = `Error fetching inventory: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const filteredInventory = computed(() => {
  if (!searchQuery.value.trim()) {
    return inventory.value;
  }
  const query = searchQuery.value.toLowerCase();
  return inventory.value.filter(item =>
    item.description?.toLowerCase().includes(query) ||
    item.part_number?.toLowerCase().includes(query) ||
    item.category?.toLowerCase().includes(query) ||
    item.supplier?.toLowerCase().includes(query)
  );
});

const openInventoryEditor = (item = null) => {
  selectedItem.value = item ? { ...item } : {};
  showInventoryEditor.value = true;
};

const handleItemSaved = () => {
  showInventoryEditor.value = false;
  selectedItem.value = null;
  fetchInventory();
};

const deleteItem = async (item) => {
  if (!confirm(`Are you sure you want to delete "${item.description}"? This action cannot be undone.`)) {
    return;
  }

  try {
    const { error } = await supabase
      .from('inventory')
      .delete()
      .eq('id', item.id);

    if (error) throw error;

    await fetchInventory();
  } catch (err) {
    alert(`Error deleting item: ${err.message}`);
    console.error('Error deleting item:', err);
  }
};

const getStockStatus = (quantity, minStock) => {
  if (quantity <= 0) return { label: 'Out of Stock', class: 'bg-red-100 text-red-700' };
  if (quantity <= (minStock || 5)) return { label: 'Low Stock', class: 'bg-yellow-100 text-yellow-700' };
  return { label: 'In Stock', class: 'bg-green-100 text-green-700' };
};

const formatCurrency = (value) => {
  if (value == null) return '-';
  return new Intl.NumberFormat('en-AU', { style: 'currency', currency: 'AUD' }).format(value);
};

onMounted(fetchInventory);
</script>

<template>
  <div class="inventory-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Inventory</h1>
          <p class="text-gray-600 mt-1">Manage your parts and supplies</p>
        </div>
        <button
          @click="openInventoryEditor()"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
        >
          + New Part
        </button>
      </div>
    </header>

    <!-- Search Bar -->
    <div class="mb-6">
      <div class="relative">
        <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search by part name, number, category, or supplier..."
          class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-purple-500 focus:border-purple-500"
        />
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading inventory...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Empty State -->
    <div v-else-if="inventory.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No inventory items</h3>
      <p class="mt-1 text-gray-500">Get started by adding your first part.</p>
      <button
        @click="openInventoryEditor()"
        class="mt-4 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
      >
        + New Part
      </button>
    </div>

    <!-- No Search Results -->
    <div v-else-if="filteredInventory.length === 0" class="text-center p-8 bg-white rounded-lg shadow">
      <p class="text-gray-600">No items found matching "{{ searchQuery }}"</p>
      <button
        @click="searchQuery = ''"
        class="mt-2 text-purple-600 hover:text-purple-700 text-sm"
      >
        Clear search
      </button>
    </div>

    <!-- Inventory Table -->
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Description
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Part Number
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Category
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Quantity
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Unit Price
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Supplier
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="item in filteredInventory" :key="item.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">{{ item.description }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ item.part_number || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span v-if="item.category" class="px-2 py-1 text-xs font-medium bg-purple-100 text-purple-700 rounded">
                  {{ item.category }}
                </span>
                <span v-else class="text-sm text-gray-400">-</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ item.quantity ?? 0 }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  :class="getStockStatus(item.quantity, item.min_stock).class"
                  class="px-2 py-1 text-xs font-medium rounded"
                >
                  {{ getStockStatus(item.quantity, item.min_stock).label }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ formatCurrency(item.unit_price) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ item.supplier || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button
                  @click="openInventoryEditor(item)"
                  class="text-purple-600 hover:text-purple-900 mr-3"
                >
                  Edit
                </button>
                <button
                  @click="deleteItem(item)"
                  class="text-red-600 hover:text-red-900"
                >
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Summary Footer -->
    <div v-if="!loading && inventory.length > 0" class="mt-6 bg-white rounded-lg shadow px-6 py-4">
      <div class="flex justify-between items-center text-sm">
        <p class="text-gray-700">
          Showing <span class="font-semibold">{{ filteredInventory.length }}</span> of
          <span class="font-semibold">{{ inventory.length }}</span> item{{ inventory.length !== 1 ? 's' : '' }}
        </p>
        <p v-if="searchQuery" class="text-purple-600">
          Searching: "{{ searchQuery }}"
        </p>
      </div>
    </div>

    <!-- Inventory Editor Modal -->
    <InventoryEditor
      v-model="showInventoryEditor"
      :item="selectedItem"
      @itemSaved="handleItemSaved"
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

input:focus {
  outline: none;
}
</style>
