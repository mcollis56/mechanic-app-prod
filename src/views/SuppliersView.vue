<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../supabaseClient.js';
import SupplierEditor from '../components/SupplierEditor.vue';

const suppliers = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const showSupplierEditor = ref(false);
const selectedSupplier = ref(null);
const categoryFilter = ref('all');

const fetchSuppliers = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error } = await supabase
      .from('suppliers')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    suppliers.value = data;
  } catch (err) {
    errorMsg.value = `Error fetching suppliers: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const categories = computed(() => {
  const cats = new Set(suppliers.value.map(s => s.category).filter(Boolean));
  return ['all', ...Array.from(cats).sort()];
});

const filteredSuppliers = computed(() => {
  if (categoryFilter.value === 'all') {
    return suppliers.value;
  }
  return suppliers.value.filter(s => s.category === categoryFilter.value);
});

const openSupplierEditor = (supplier = null) => {
  selectedSupplier.value = supplier ? { ...supplier } : {};
  showSupplierEditor.value = true;
};

const handleSupplierSaved = () => {
  showSupplierEditor.value = false;
  selectedSupplier.value = null;
  fetchSuppliers();
};

const deleteSupplier = async (supplier) => {
  if (!confirm(`Are you sure you want to delete ${supplier.name}? This action cannot be undone.`)) {
    return;
  }

  try {
    const { error } = await supabase
      .from('suppliers')
      .delete()
      .eq('id', supplier.id);

    if (error) throw error;

    await fetchSuppliers();
  } catch (err) {
    alert(`Error deleting supplier: ${err.message}`);
    console.error('Error deleting supplier:', err);
  }
};

onMounted(fetchSuppliers);
</script>

<template>
  <div class="suppliers-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Suppliers</h1>
          <p class="text-gray-600 mt-1">Manage your supplier contacts and information</p>
        </div>
        <button
          @click="openSupplierEditor()"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
        >
          + New Supplier
        </button>
      </div>
    </header>

    <!-- Category Filter -->
    <div v-if="!loading && suppliers.length > 0" class="mb-4">
      <label for="category-filter" class="block text-sm font-medium text-gray-700 mb-2">
        Filter by Category:
      </label>
      <select
        id="category-filter"
        v-model="categoryFilter"
        class="block px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
      >
        <option v-for="cat in categories" :key="cat" :value="cat">
          {{ cat === 'all' ? 'All Categories' : cat }}
        </option>
      </select>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading suppliers...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Empty State -->
    <div v-else-if="suppliers.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No suppliers</h3>
      <p class="mt-1 text-gray-500">Get started by creating a new supplier.</p>
      <button
        @click="openSupplierEditor()"
        class="mt-4 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
      >
        + New Supplier
      </button>
    </div>

    <!-- No Results State -->
    <div v-else-if="filteredSuppliers.length === 0" class="text-center p-8 bg-white rounded-lg shadow">
      <p class="text-gray-600">No suppliers found in this category.</p>
      <button
        @click="categoryFilter = 'all'"
        class="mt-2 text-purple-600 hover:text-purple-700 text-sm"
      >
        Clear filter
      </button>
    </div>

    <!-- Suppliers Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="supplier in filteredSuppliers"
        :key="supplier.id"
        class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow"
      >
        <!-- Supplier Header -->
        <div class="flex justify-between items-start mb-4">
          <div class="flex-1 min-w-0">
            <h3 class="text-lg font-semibold text-gray-900 truncate">{{ supplier.name }}</h3>
            <span
              v-if="supplier.category"
              class="inline-block mt-1 px-2 py-1 text-xs font-medium bg-purple-100 text-purple-700 rounded"
            >
              {{ supplier.category }}
            </span>
            <span
              v-if="supplier.is_prefilled"
              class="inline-block mt-1 ml-2 px-2 py-1 text-xs font-medium bg-blue-100 text-blue-700 rounded"
              title="Pre-filled supplier"
            >
              Recommended
            </span>
          </div>
        </div>

        <!-- Supplier Details -->
        <div class="space-y-2 text-sm text-gray-600 mb-4">
          <div v-if="supplier.phone" class="flex items-center">
            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            <span>{{ supplier.phone }}</span>
          </div>

          <div v-if="supplier.email" class="flex items-center">
            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            <span class="truncate">{{ supplier.email }}</span>
          </div>

          <div v-if="supplier.address" class="flex items-start">
            <svg class="w-4 h-4 mr-2 mt-0.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span class="flex-1">{{ supplier.address }}</span>
          </div>

          <div v-if="supplier.website" class="flex items-center">
            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
            </svg>
            <a :href="supplier.website" target="_blank" class="text-purple-600 hover:text-purple-700 truncate">
              Website
            </a>
          </div>

          <div v-if="supplier.notes" class="mt-3 pt-3 border-t border-gray-200">
            <p class="text-xs text-gray-500 italic">{{ supplier.notes }}</p>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-2 pt-4 border-t border-gray-200">
          <button
            @click="openSupplierEditor(supplier)"
            class="flex-1 px-3 py-2 text-sm text-purple-600 hover:bg-purple-50 border border-purple-200 rounded-md transition-colors"
          >
            Edit
          </button>
          <button
            @click="deleteSupplier(supplier)"
            class="flex-1 px-3 py-2 text-sm text-red-600 hover:bg-red-50 border border-red-200 rounded-md transition-colors"
          >
            Delete
          </button>
        </div>
      </div>
    </div>

    <!-- Summary Footer -->
    <div v-if="!loading && suppliers.length > 0" class="mt-6 bg-white rounded-lg shadow px-6 py-4">
      <div class="flex justify-between items-center text-sm">
        <p class="text-gray-700">
          Showing <span class="font-semibold">{{ filteredSuppliers.length }}</span> of
          <span class="font-semibold">{{ suppliers.length }}</span> supplier{{ suppliers.length !== 1 ? 's' : '' }}
        </p>
        <p v-if="categoryFilter !== 'all'" class="text-purple-600">
          Filtered by: {{ categoryFilter }}
        </p>
      </div>
    </div>

    <!-- Supplier Editor Modal -->
    <SupplierEditor
      v-model="showSupplierEditor"
      :supplier="selectedSupplier"
      @supplierSaved="handleSupplierSaved"
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

select:focus {
  outline: none;
}
</style>
