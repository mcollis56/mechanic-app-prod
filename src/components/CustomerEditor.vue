<script setup>
import { ref, watch } from 'vue';
import { supabase } from '../supabaseClient.js';

const props = defineProps({
  customer: Object,
  modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'customerSaved']);

const localCustomer = ref({
  name: '',
  email: '',
  phone: ''
});

const localVehicle = ref({
  make: '',
  model: '',
  rego: '',
  vin: '',
  engine_code: ''
});

const saving = ref(false);
const errorMsg = ref('');

watch(() => props.customer, (newCustomer) => {
  if (newCustomer && Object.keys(newCustomer).length > 0) {
    localCustomer.value = { ...newCustomer };
  } else {
    localCustomer.value = { name: '', email: '', phone: '' };
  }
  // Reset vehicle form when modal opens/customer changes
  localVehicle.value = { make: '', model: '', rego: '', vin: '', engine_code: '' };
}, { immediate: true, deep: true });

const saveCustomer = async () => {
  if (!localCustomer.value.name || !localCustomer.value.email) {
    errorMsg.value = 'Name and Email are required';
    return;
  }

  try {
    saving.value = true;
    errorMsg.value = '';
    let customerId = localCustomer.value.id;

    if (customerId) {
      // Update existing customer
      const { error } = await supabase
        .from('customers')
        .update({
          name: localCustomer.value.name,
          email: localCustomer.value.email,
          phone: localCustomer.value.phone
        })
        .eq('id', customerId);

      if (error) throw error;
    } else {
      // Create new customer
      const { data, error } = await supabase
        .from('customers')
        .insert({
          name: localCustomer.value.name,
          email: localCustomer.value.email,
          phone: localCustomer.value.phone
        })
        .select()
        .single();

      if (error) throw error;
      customerId = data.id;
    }

    // Save vehicle if at least make and model are provided
    if (localVehicle.value.make && localVehicle.value.model) {
      const { error: vError } = await supabase
        .from('vehicles')
        .insert({
          customer_id: customerId,
          make: localVehicle.value.make,
          model: localVehicle.value.model,
          rego: localVehicle.value.rego,
          vin: localVehicle.value.vin,
          engine_code: localVehicle.value.engine_code
        });
      
      if (vError) throw vError;
    }

    emit('customerSaved');
    closeModal();
  } catch (err) {
    errorMsg.value = err.message;
    console.error('Error saving customer/vehicle:', err);
  } finally {
    saving.value = false;
  }
};

const closeModal = () => {
  localCustomer.value = { name: '', email: '', phone: '' };
  localVehicle.value = { make: '', model: '', rego: '', vin: '', engine_code: '' };
  errorMsg.value = '';
  emit('update:modelValue', false);
};
</script>

<template>
  <div v-if="modelValue" class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
    <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
      <h2 class="text-2xl font-bold mb-4">{{ localCustomer.id ? 'Edit Customer' : 'New Customer' }}</h2>

      <div v-if="errorMsg" class="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded">
        {{ errorMsg }}
      </div>

      <form @submit.prevent="saveCustomer">
        <!-- Customer Details Section -->
        <div class="mb-6">
          <h3 class="text-lg font-semibold mb-3 border-b pb-1">Customer Details</h3>
          <!-- Name -->
          <div class="mb-4">
            <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
              Name <span class="text-red-500">*</span>
            </label>
            <input
              type="text"
              id="name"
              v-model="localCustomer.name"
              class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              required
            />
          </div>

          <!-- Email -->
          <div class="mb-4">
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
              Email <span class="text-red-500">*</span>
            </label>
            <input
              type="email"
              id="email"
              v-model="localCustomer.email"
              class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              required
            />
          </div>

          <!-- Phone -->
          <div class="mb-4">
            <label for="phone" class="block text-sm font-medium text-gray-700 mb-1">Phone</label>
            <input
              type="tel"
              id="phone"
              v-model="localCustomer.phone"
              class="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            />
          </div>
        </div>

        <!-- Vehicle Details Section -->
        <div class="mb-6">
          <h3 class="text-lg font-semibold mb-3 border-b pb-1">Initial Vehicle (Optional)</h3>
          <div class="grid grid-cols-2 gap-4">
            <div class="mb-2">
              <label class="block text-xs font-medium text-gray-500">Make</label>
              <input v-model="localVehicle.make" placeholder="e.g. Toyota" class="w-full p-2 border border-gray-300 rounded-md text-sm" />
            </div>
            <div class="mb-2">
              <label class="block text-xs font-medium text-gray-500">Model</label>
              <input v-model="localVehicle.model" placeholder="e.g. Corolla" class="w-full p-2 border border-gray-300 rounded-md text-sm" />
            </div>
          </div>
          <div class="mb-2">
            <label class="block text-xs font-medium text-gray-500">Registration</label>
            <input v-model="localVehicle.rego" placeholder="ABC-123" class="w-full p-2 border border-gray-300 rounded-md text-sm" />
          </div>
          <div class="mb-2">
            <label class="block text-xs font-medium text-gray-500">VIN</label>
            <input v-model="localVehicle.vin" placeholder="17-digit VIN" class="w-full p-2 border border-gray-300 rounded-md text-sm" />
          </div>
          <div class="mb-2">
            <label class="block text-xs font-medium text-gray-500">Engine Code</label>
            <input v-model="localVehicle.engine_code" placeholder="e.g. 2JZ-GTE" class="w-full p-2 border border-gray-300 rounded-md text-sm" />
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-4 mt-6">
          <button
            type="button"
            @click="closeModal"
            class="px-4 py-2 bg-gray-300 rounded-md hover:bg-gray-400 transition-colors"
            :disabled="saving"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors disabled:opacity-50"
            :disabled="saving"
          >
            {{ saving ? 'Saving...' : 'Save Customer' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
input:focus {
  outline: none;
}
</style>
