<script setup>
import { ref, watch } from 'vue';
import { supabase } from '../supabaseClient.js';

const props = defineProps({
  supplier: Object,
  modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'supplierSaved']);

const localSupplier = ref({
  name: '',
  category: '',
  phone: '',
  email: '',
  address: '',
  website: '',
  notes: ''
});

const saving = ref(false);
const errorMsg = ref('');

watch(() => props.supplier, (newSupplier) => {
  if (newSupplier && Object.keys(newSupplier).length > 0) {
    localSupplier.value = { ...newSupplier };
  } else {
    localSupplier.value = {
      name: '',
      category: '',
      phone: '',
      email: '',
      address: '',
      website: '',
      notes: ''
    };
  }
}, { immediate: true, deep: true });

const saveSupplier = async () => {
  if (!localSupplier.value.name) {
    errorMsg.value = 'Name is required';
    return;
  }

  try {
    saving.value = true;
    errorMsg.value = '';

    if (localSupplier.value.id) {
      // Update existing supplier
      const { error } = await supabase
        .from('suppliers')
        .update({
          name: localSupplier.value.name,
          category: localSupplier.value.category,
          phone: localSupplier.value.phone,
          email: localSupplier.value.email,
          address: localSupplier.value.address,
          website: localSupplier.value.website,
          notes: localSupplier.value.notes
        })
        .eq('id', localSupplier.value.id);

      if (error) throw error;
    } else {
      // Create new supplier
      const { error } = await supabase
        .from('suppliers')
        .insert({
          name: localSupplier.value.name,
          category: localSupplier.value.category,
          phone: localSupplier.value.phone,
          email: localSupplier.value.email,
          address: localSupplier.value.address,
          website: localSupplier.value.website,
          notes: localSupplier.value.notes,
          is_prefilled: false
        });

      if (error) throw error;
    }

    emit('supplierSaved');
    closeModal();
  } catch (err) {
    errorMsg.value = err.message;
    console.error('Error saving supplier:', err);
  } finally {
    saving.value = false;
  }
};

const closeModal = () => {
  emit('update:modelValue', false);
};
</script>

<template>
  <div v-if="modelValue" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="flex justify-between items-center p-6 border-b border-gray-200">
        <h2 class="text-xl font-bold text-gray-900">
          {{ localSupplier.id ? 'Edit Supplier' : 'New Supplier' }}
        </h2>
        <button @click="closeModal" class="text-gray-400 hover:text-gray-600 transition-colors">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Error Message -->
      <div v-if="errorMsg" class="mx-6 mt-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
        {{ errorMsg }}
      </div>

      <!-- Form -->
      <form @submit.prevent="saveSupplier" class="p-6 space-y-4">
        <!-- Name (Required) -->
        <div>
          <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
            Name <span class="text-red-500">*</span>
          </label>
          <input
            id="name"
            type="text"
            v-model="localSupplier.name"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., ABC Auto Parts"
          />
        </div>

        <!-- Category -->
        <div>
          <label for="category" class="block text-sm font-medium text-gray-700 mb-1">
            Category
          </label>
          <input
            id="category"
            type="text"
            v-model="localSupplier.category"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., Auto Parts, Tools, Tires"
          />
        </div>

        <!-- Phone -->
        <div>
          <label for="phone" class="block text-sm font-medium text-gray-700 mb-1">
            Phone
          </label>
          <input
            id="phone"
            type="tel"
            v-model="localSupplier.phone"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., (02) 9999 9999"
          />
        </div>

        <!-- Email -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
            Email
          </label>
          <input
            id="email"
            type="email"
            v-model="localSupplier.email"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., sales@supplier.com"
          />
        </div>

        <!-- Address -->
        <div>
          <label for="address" class="block text-sm font-medium text-gray-700 mb-1">
            Address
          </label>
          <textarea
            id="address"
            v-model="localSupplier.address"
            rows="2"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., 123 Main St, Suburb, NSW 2000"
          ></textarea>
        </div>

        <!-- Website -->
        <div>
          <label for="website" class="block text-sm font-medium text-gray-700 mb-1">
            Website
          </label>
          <input
            id="website"
            type="url"
            v-model="localSupplier.website"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., https://www.supplier.com"
          />
        </div>

        <!-- Notes -->
        <div>
          <label for="notes" class="block text-sm font-medium text-gray-700 mb-1">
            Notes
          </label>
          <textarea
            id="notes"
            v-model="localSupplier.notes"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., Account number, special terms, delivery days"
          ></textarea>
        </div>

        <!-- Actions -->
        <div class="flex gap-3 pt-4">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="saving"
            class="flex-1 px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ saving ? 'Saving...' : 'Save Supplier' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
input:focus,
textarea:focus {
  outline: none;
}
</style>
