<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../supabaseClient.js';

const route = useRoute();
const router = useRouter();
const appName = import.meta.env.VITE_APP_NAME || 'Mechanic App';
const currentUser = ref(null);
const isLoadingProfile = ref(true);
const isSidebarOpen = ref(false);

// Search State
const searchQuery = ref('');
const isSearching = ref(false);
const showDropdown = ref(false);
const searchResults = ref({ customers: [], vehicles: [] });
const searchContainer = ref(null);
let debounceTimer = null;

const fetchCurrentUser = async () => {
  try {
    isLoadingProfile.value = true;
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) {
      currentUser.value = null;
      return;
    }

    // Set initial fallback data from auth session immediately
    // so we don't show "Loading..." if the profile fetch is slow or missing
    currentUser.value = {
      email: user.email,
      role: 'mechanic'
    };

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    // Only update if we successfully got a profile row
    if (profile && !profileError) {
      currentUser.value = profile;
    }
  } catch (err) {
    console.error('Error fetching current user:', err);
  } finally {
    isLoadingProfile.value = false;
  }
};

const handleLogout = async () => {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    router.push('/login');
  } catch (err) {
    alert(`Error logging out: ${err.message}`);
    console.error('Error logging out:', err);
  }
};

// Search Logic
const performSearch = async () => {
  const query = searchQuery.value.trim();
  if (query.length < 2) {
    searchResults.value = { customers: [], vehicles: [] };
    return;
  }

  isSearching.value = true;
  showDropdown.value = true;

  try {
    // Search Customers
    const customerQuery = supabase
      .from('customers')
      .select('id, first_name, last_name, phone, email')
      .or(`first_name.ilike.%${query}%,last_name.ilike.%${query}%,phone.ilike.%${query}%,email.ilike.%${query}%`)
      .limit(5);

    // Search Vehicles
    const vehicleQuery = supabase
      .from('vehicles')
      .select('id, customer_id, rego, vin, make, model')
      .or(`rego.ilike.%${query}%,vin.ilike.%${query}%,make.ilike.%${query}%,model.ilike.%${query}%`)
      .limit(5);

    const [customersRes, vehiclesRes] = await Promise.all([customerQuery, vehicleQuery]);

    searchResults.value = {
      customers: customersRes.data || [],
      vehicles: vehiclesRes.data || []
    };
  } catch (err) {
    console.error('Global search error:', err);
  } finally {
    isSearching.value = false;
  }
};

const handleSearchInput = () => {
  if (debounceTimer) clearTimeout(debounceTimer);
  
  if (!searchQuery.value.trim()) {
    showDropdown.value = false;
    searchResults.value = { customers: [], vehicles: [] };
    return;
  }

  debounceTimer = setTimeout(performSearch, 300);
};

const navigateToResult = (type, item) => {
  if (type === 'customer') {
    router.push(`/customers/${item.id}`);
  } else if (type === 'vehicle') {
    router.push(`/customers/${item.customer_id}`);
  }
  
  // Reset search
  searchQuery.value = '';
  showDropdown.value = false;
  searchResults.value = { customers: [], vehicles: [] };
};

const handleClickOutside = (event) => {
  if (searchContainer.value && !searchContainer.value.contains(event.target)) {
    showDropdown.value = false;
  }
};

onMounted(() => {
  fetchCurrentUser();
  window.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  window.removeEventListener('click', handleClickOutside);
});
</script>

<template>
  <div class="main-layout flex h-screen bg-gray-50 relative">
    <!-- Mobile Sidebar Overlay -->
    <div
      v-if="isSidebarOpen"
      class="fixed inset-0 bg-gray-600 bg-opacity-75 z-40 md:hidden"
      @click="isSidebarOpen = false"
    ></div>

    <!-- Sidebar -->
    <aside
      class="bg-white border-r border-gray-200 flex-col fixed inset-y-0 left-0 z-50 w-64 transform transition-transform duration-300 ease-in-out md:translate-x-0 md:relative md:flex"
      :class="isSidebarOpen ? 'translate-x-0' : '-translate-x-full'"
    >
      <!-- Logo/Header -->
      <div class="h-16 flex items-center px-6 border-b border-gray-200 justify-between">
        <h1 class="text-xl font-bold text-gray-900">{{ appName }}</h1>
        <button class="md:hidden text-gray-500 hover:text-gray-700" @click="isSidebarOpen = false">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
        <RouterLink
          to="/"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          Jobs Board
        </RouterLink>

        <RouterLink
          to="/work-orders"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path.startsWith('/work-orders')
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-5 8l2 2 4-4" />
          </svg>
          Work Orders
        </RouterLink>

        <RouterLink
          to="/calendar"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/calendar'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          Calendar
        </RouterLink>

        <RouterLink
          to="/customers"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/customers'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
          Customers
        </RouterLink>

        <RouterLink
          to="/suppliers"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/suppliers'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
          Suppliers
        </RouterLink>

        <RouterLink
          to="/inventory"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/inventory'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
          </svg>
          Inventory
        </RouterLink>

        <RouterLink
          to="/invoices"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/invoices'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Invoices
        </RouterLink>

        <RouterLink
          to="/archive"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/archive'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
          </svg>
          Archive
        </RouterLink>

        <RouterLink
          to="/reports"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/reports'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
          Reports
        </RouterLink>

        <RouterLink
          to="/admin"
          class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
          :class="route.path === '/admin'
            ? 'bg-purple-50 text-purple-700'
            : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'"
          @click="isSidebarOpen = false"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Admin
        </RouterLink>
      </nav>

      <!-- User Section -->
      <div class="px-4 py-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="flex items-center flex-1 min-w-0">
            <div class="w-8 h-8 bg-purple-600 rounded-full flex items-center justify-center text-white text-sm font-medium">
              {{ currentUser?.email?.[0]?.toUpperCase() || (isLoadingProfile ? '?' : 'U') }}
            </div>
            <div class="ml-3 flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-700 truncate">
                {{ currentUser?.email || (isLoadingProfile ? 'Loading...' : 'Not logged in') }}
              </p>
              <p class="text-xs text-gray-500 capitalize">
                {{ currentUser?.role || (isLoadingProfile ? '...' : 'mechanic') }}
              </p>
            </div>
          </div>
          <button
            @click="handleLogout"
            class="ml-2 text-gray-400 hover:text-gray-600 transition-colors"
            title="Log out"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="flex-1 flex flex-col overflow-hidden w-full">
      <!-- Top Header with Global Search -->
      <header class="h-16 bg-white border-b border-gray-200 flex items-center px-4 sm:px-8 flex-shrink-0 gap-4">
        <!-- Hamburger Menu Button -->
        <button
          @click="isSidebarOpen = true"
          class="md:hidden text-gray-500 hover:text-gray-700"
        >
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <div ref="searchContainer" class="relative w-full max-w-xl">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <input
            v-model="searchQuery"
            @input="handleSearchInput"
            @focus="showDropdown = searchQuery.length >= 2"
            type="text"
            class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-purple-500 focus:border-purple-500 sm:text-sm"
            placeholder="Search customers, rego, VIN..."
          >

          <!-- Search Results Dropdown -->
          <div
            v-if="showDropdown && (isSearching || searchResults.customers.length > 0 || searchResults.vehicles.length > 0)"
            class="absolute mt-1 w-full bg-white rounded-md shadow-lg border border-gray-200 z-50 max-h-96 overflow-y-auto left-0"
          >
            <div v-if="isSearching" class="p-4 text-sm text-gray-500 flex items-center">
              <svg class="animate-spin h-4 w-4 mr-2 text-purple-600" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Searching...
            </div>

            <div v-else>
              <!-- Customers Section -->
              <div v-if="searchResults.customers.length > 0">
                <div class="bg-gray-50 px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                  Customers
                </div>
                <ul class="divide-y divide-gray-100">
                  <li
                    v-for="customer in searchResults.customers"
                    :key="customer.id"
                    @click="navigateToResult('customer', customer)"
                    class="px-4 py-3 hover:bg-purple-50 cursor-pointer transition-colors"
                  >
                    <div class="text-sm font-medium text-gray-900">
                      {{ customer.first_name }} {{ customer.last_name }}
                    </div>
                    <div class="text-xs text-gray-500">
                      {{ customer.phone }} • {{ customer.email }}
                    </div>
                  </li>
                </ul>
              </div>

              <!-- Vehicles Section -->
              <div v-if="searchResults.vehicles.length > 0">
                <div class="bg-gray-50 px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                  Vehicles
                </div>
                <ul class="divide-y divide-gray-100">
                  <li
                    v-for="vehicle in searchResults.vehicles"
                    :key="vehicle.id"
                    @click="navigateToResult('vehicle', vehicle)"
                    class="px-4 py-3 hover:bg-purple-50 cursor-pointer transition-colors"
                  >
                    <div class="text-sm font-medium text-gray-900">
                      {{ vehicle.make }} {{ vehicle.model }} — <span class="text-purple-600">{{ vehicle.rego }}</span>
                    </div>
                    <div class="text-xs text-gray-500">
                      VIN: {{ vehicle.vin }}
                    </div>
                  </li>
                </ul>
              </div>

              <!-- No Results -->
              <div
                v-if="!isSearching && searchResults.customers.length === 0 && searchResults.vehicles.length === 0"
                class="p-4 text-sm text-gray-500"
              >
                No matches found for "{{ searchQuery }}"
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Content Area -->
      <div class="flex-1 overflow-auto">
        <RouterView />
      </div>
    </main>
  </div>
</template>

<style scoped>
.main-layout {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}
</style>
