<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';

const loading = ref(true);
const saving = ref(false);
const errorMsg = ref('');
const successMsg = ref('');
const settingsId = ref(null);

const formData = ref({
  business_name: '',
  address: '',
  abn: '',
  phone: '',
  email: '',
  hourly_rate: 150.00,
  tax_rate: 10.00,
  enable_messaging: false
});

const fetchSettings = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error } = await supabase
      .from('settings')
      .select('*')
      .single();

    if (error) throw error;

    if (data) {
      settingsId.value = data.id;
      formData.value = {
        business_name: data.business_name || '',
        address: data.address || '',
        abn: data.abn || '',
        phone: data.phone || '',
        email: data.email || '',
        hourly_rate: parseFloat(data.hourly_rate || 150),
        tax_rate: parseFloat(data.tax_rate || 10),
        enable_messaging: data.enable_messaging || false
      };
    }
  } catch (err) {
    errorMsg.value = `Error loading settings: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const saveSettings = async () => {
  try {
    saving.value = true;
    errorMsg.value = '';
    successMsg.value = '';

    const { error } = await supabase
      .from('settings')
      .update({
        business_name: formData.value.business_name,
        address: formData.value.address,
        abn: formData.value.abn,
        phone: formData.value.phone,
        email: formData.value.email,
        hourly_rate: parseFloat(formData.value.hourly_rate),
        tax_rate: parseFloat(formData.value.tax_rate),
        enable_messaging: formData.value.enable_messaging
      })
      .eq('id', settingsId.value);

    if (error) throw error;

    successMsg.value = 'Settings saved successfully!';

    // Clear success message after 3 seconds
    setTimeout(() => {
      successMsg.value = '';
    }, 3000);
  } catch (err) {
    errorMsg.value = `Error saving settings: ${err.message}`;
    console.error(err);
  } finally {
    saving.value = false;
  }
};

onMounted(fetchSettings);
</script>

<template>
  <div class="admin-settings p-6">
    <header class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Business Settings</h1>
      <p class="text-gray-600 mt-1">Manage your business details and default rates</p>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8 bg-white rounded-lg shadow">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading settings...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4">
      {{ errorMsg }}
    </div>

    <!-- Settings Form -->
    <div v-else class="bg-white rounded-lg shadow p-6">
      <!-- Success Message -->
      <div v-if="successMsg" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded mb-6">
        {{ successMsg }}
      </div>

      <form @submit.prevent="saveSettings" class="space-y-6">
        <!-- Business Information Section -->
        <div>
          <h2 class="text-lg font-semibold text-gray-900 mb-4 pb-2 border-b">Business Information</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Business Name -->
            <div class="md:col-span-2">
              <label for="business_name" class="block text-sm font-medium text-gray-700 mb-1">
                Business Name
              </label>
              <input
                id="business_name"
                v-model="formData.business_name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="Euro Motor Works"
              />
            </div>

            <!-- Address -->
            <div class="md:col-span-2">
              <label for="address" class="block text-sm font-medium text-gray-700 mb-1">
                Business Address
              </label>
              <textarea
                id="address"
                v-model="formData.address"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="123 Main Street, Suburb, State, Postcode"
              />
            </div>

            <!-- ABN -->
            <div>
              <label for="abn" class="block text-sm font-medium text-gray-700 mb-1">
                ABN
              </label>
              <input
                id="abn"
                v-model="formData.abn"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="12 345 678 901"
              />
            </div>

            <!-- Phone -->
            <div>
              <label for="phone" class="block text-sm font-medium text-gray-700 mb-1">
                Phone Number
              </label>
              <input
                id="phone"
                v-model="formData.phone"
                type="tel"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="(02) 1234 5678"
              />
            </div>

            <!-- Email -->
            <div class="md:col-span-2">
              <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
                Business Email
              </label>
              <input
                id="email"
                v-model="formData.email"
                type="email"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="info@euromotorworks.com.au"
              />
            </div>
          </div>
        </div>

        <!-- Pricing Section -->
        <div>
          <h2 class="text-lg font-semibold text-gray-900 mb-4 pb-2 border-b">Default Rates</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Hourly Rate -->
            <div>
              <label for="hourly_rate" class="block text-sm font-medium text-gray-700 mb-1">
                Hourly Labor Rate ($)
              </label>
              <input
                id="hourly_rate"
                v-model="formData.hourly_rate"
                type="number"
                step="0.01"
                min="0"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="150.00"
                required
              />
              <p class="text-xs text-gray-500 mt-1">Default rate used when generating invoices</p>
            </div>

            <!-- Tax Rate -->
            <div>
              <label for="tax_rate" class="block text-sm font-medium text-gray-700 mb-1">
                Tax Rate (%)
              </label>
              <input
                id="tax_rate"
                v-model="formData.tax_rate"
                type="number"
                step="0.01"
                min="0"
                max="100"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="10.00"
                required
              />
              <p class="text-xs text-gray-500 mt-1">GST or tax percentage for invoices</p>
            </div>
          </div>
        </div>

        <!-- Add-ons Section -->
        <div>
          <h2 class="text-lg font-semibold text-gray-900 mb-4 pb-2 border-b">Add-ons & Features</h2>
          
          <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200">
            <div>
              <h3 class="text-base font-medium text-gray-900">Messaging Service</h3>
              <p class="text-sm text-gray-500">Enable SMS notifications for customers when cars are ready.</p>
            </div>
            <div class="flex items-center">
              <button 
                type="button" 
                class="relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
                :class="formData.enable_messaging ? 'bg-purple-600' : 'bg-gray-200'"
                @click="formData.enable_messaging = !formData.enable_messaging"
              >
                <span class="sr-only">Use setting</span>
                <span 
                  aria-hidden="true" 
                  class="pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"
                  :class="formData.enable_messaging ? 'translate-x-5' : 'translate-x-0'"
                ></span>
              </button>
              <span class="ml-3 text-sm font-medium text-gray-900">{{ formData.enable_messaging ? 'Enabled' : 'Disabled' }}</span>
            </div>
          </div>
        </div>

        <!-- Save Button -->
        <div class="flex justify-end pt-4 border-t">
          <button
            type="submit"
            :disabled="saving"
            class="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ saving ? 'Saving...' : 'Save Settings' }}
          </button>
        </div>
      </form>
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
