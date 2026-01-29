<script setup>
import { ref, onMounted, computed } from 'vue';
import { useVehicles } from '@/composables/useVehicles.js';
import VehicleEditor from '@/components/VehicleEditor.vue';

const { vehicles, loading, error, fetchVehicles, deleteVehicle, searchVehicles } = useVehicles();

const showVehicleEditor = ref(false);
const selectedVehicle = ref(null);
const searchTerm = ref('');
const isSearching = ref(false);

onMounted(() => {
  fetchVehicles();
});

const openVehicleEditor = (vehicle = null) => {
  selectedVehicle.value = vehicle ? { ...vehicle } : null;
  showVehicleEditor.value = true;
};

const handleVehicleSaved = () => {
  showVehicleEditor.value = false;
  selectedVehicle.value = null;
  fetchVehicles();
};

const handleDelete = async (vehicle) => {
  if (!confirm(`Are you sure you want to delete ${vehicle.make} ${vehicle.model} (${vehicle.registration || 'No Rego'})? This action cannot be undone.`)) {
    return;
  }

  try {
    await deleteVehicle(vehicle.id);
  } catch (err) {
    alert(`Error deleting vehicle: ${err.message}`);
  }
};

const handleSearch = async () => {
  isSearching.value = true;
  try {
    await searchVehicles(searchTerm.value);
  } catch (err) {
    console.error('Search error:', err);
  } finally {
    isSearching.value = false;
  }
};

const clearSearch = () => {
  searchTerm.value = '';
  fetchVehicles();
};

const vehicleDisplay = computed(() => {
  return vehicles.value.map(vehicle => ({
    ...vehicle,
    displayName: `${vehicle.year || ''} ${vehicle.make} ${vehicle.model}`.trim(),
    customerName: vehicle.customers?.name || 'No Customer'
  }));
});
</script>

<template>
  <div class="vehicles-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-2xl font-bold text-gray-900">Vehicles</h1>
        <button
          @click="openVehicleEditor()"
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
        >
          + New Vehicle
        </button>
      </div>

      <!-- Search Bar -->
      <div class="flex gap-2">
        <div class="flex-1 relative">
          <input
            v-model="searchTerm"
            @keyup.enter="handleSearch"
            type="text"
            placeholder="Search by VIN, registration, make, or model..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          />
          <button
            v-if="searchTerm"
            @click="clearSearch"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
        <button
          @click="handleSearch"
          :disabled="isSearching"
          class="px-6 py-2 bg-gray-800 hover:bg-gray-900 text-white font-semibold rounded-lg transition-colors disabled:opacity-50"
        >
          {{ isSearching ? 'Searching...' : 'Search' }}
        </button>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading && !isSearching" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading vehicles...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ error }}
    </div>

    <!-- Empty State -->
    <div v-else-if="vehicleDisplay.length === 0" class="text-center p-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No vehicles found</h3>
      <p class="mt-1 text-gray-500">
        {{ searchTerm ? 'Try a different search term' : 'Get started by adding a new vehicle' }}
      </p>
      <button
        v-if="!searchTerm"
        @click="openVehicleEditor()"
        class="mt-4 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors"
      >
        + New Vehicle
      </button>
    </div>

    <!-- Vehicles Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="vehicle in vehicleDisplay"
        :key="vehicle.id"
        class="bg-white rounded-lg shadow hover:shadow-lg transition-shadow p-5 cursor-pointer border border-gray-200"
        @click="openVehicleEditor(vehicle)"
      >
        <!-- Vehicle Header -->
        <div class="flex justify-between items-start mb-3">
          <div class="flex-1">
            <h3 class="text-lg font-bold text-gray-900">{{ vehicle.displayName }}</h3>
            <p class="text-sm text-gray-600">{{ vehicle.customerName }}</p>
          </div>
          <div class="flex gap-2">
            <button
              @click.stop="openVehicleEditor(vehicle)"
              class="text-purple-600 hover:text-purple-800 p-1"
              title="Edit"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </button>
            <button
              @click.stop="handleDelete(vehicle)"
              class="text-red-600 hover:text-red-800 p-1"
              title="Delete"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Vehicle Details -->
        <div class="space-y-2 text-sm">
          <div v-if="vehicle.registration" class="flex items-center gap-2">
            <span class="font-medium text-gray-700">Rego:</span>
            <span class="text-gray-900 font-mono">{{ vehicle.registration }}</span>
          </div>
          <div v-if="vehicle.vin" class="flex items-center gap-2">
            <span class="font-medium text-gray-700">VIN:</span>
            <span class="text-gray-900 font-mono text-xs">{{ vehicle.vin }}</span>
          </div>
          <div v-if="vehicle.color" class="flex items-center gap-2">
            <span class="font-medium text-gray-700">Color:</span>
            <span class="text-gray-900">{{ vehicle.color }}</span>
          </div>
          <div v-if="vehicle.odometer" class="flex items-center gap-2">
            <span class="font-medium text-gray-700">Odometer:</span>
            <span class="text-gray-900">{{ vehicle.odometer.toLocaleString() }} km</span>
          </div>
          <div v-if="vehicle.transmission" class="flex items-center gap-2">
            <span class="font-medium text-gray-700">Trans:</span>
            <span class="text-gray-900">{{ vehicle.transmission }}</span>
          </div>
        </div>

        <!-- Notes Preview -->
        <div v-if="vehicle.notes" class="mt-3 pt-3 border-t border-gray-200">
          <p class="text-xs text-gray-600 line-clamp-2">{{ vehicle.notes }}</p>
        </div>
      </div>
    </div>

    <!-- Summary Footer -->
    <div v-if="vehicleDisplay.length > 0" class="mt-6 bg-white rounded-lg shadow px-6 py-3">
      <p class="text-sm text-gray-700">
        Total: <span class="font-semibold">{{ vehicleDisplay.length }}</span> vehicle{{ vehicleDisplay.length !== 1 ? 's' : '' }}
        <span v-if="searchTerm" class="text-gray-500">(filtered)</span>
      </p>
    </div>

    <!-- Vehicle Editor Modal -->
    <VehicleEditor
      v-model="showVehicleEditor"
      :vehicle="selectedVehicle"
      @vehicleSaved="handleVehicleSaved"
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

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
