<script setup>
import { ref, watch } from 'vue';
import { supabase } from '../supabaseClient.js';

const props = defineProps({
  item: Object,
  modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'itemSaved']);

const localItem = ref({
  description: '',
  part_number: '',
  category: '',
  quantity: 0,
  min_stock: 5,
  unit_price: null,
  cost_price: null,
  supplier: '',
  location: '',
  notes: ''
});

const saving = ref(false);
const errorMsg = ref('');

watch(() => props.item, (newItem) => {
  if (newItem && Object.keys(newItem).length > 0) {
    localItem.value = { ...newItem };
  } else {
    localItem.value = {
      description: '',
      part_number: '',
      category: '',
      quantity: 0,
      min_stock: 5,
      unit_price: null,
      cost_price: null,
      supplier: '',
      location: '',
      notes: ''
    };
  }
}, { immediate: true, deep: true });

const saveItem = async () => {
  if (!localItem.value.description) {
    errorMsg.value = 'Description is required';
    return;
  }

  try {
    saving.value = true;
    errorMsg.value = '';

    const itemData = {
      description: localItem.value.description,
      part_number: localItem.value.part_number || null,
      category: localItem.value.category || null,
      quantity: localItem.value.quantity || 0,
      min_stock: localItem.value.min_stock || 5,
      unit_price: localItem.value.unit_price || null,
      cost_price: localItem.value.cost_price || null,
      supplier: localItem.value.supplier || null,
      location: localItem.value.location || null,
      notes: localItem.value.notes || null
    };

    if (localItem.value.id) {
      // Update existing item
      const { error } = await supabase
        .from('inventory')
        .update(itemData)
        .eq('id', localItem.value.id);

      if (error) throw error;
    } else {
      // Create new item
      const { error } = await supabase
        .from('inventory')
        .insert(itemData);

      if (error) throw error;
    }

    emit('itemSaved');
    closeModal();
  } catch (err) {
    errorMsg.value = err.message;
    console.error('Error saving item:', err);
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
          {{ localItem.id ? 'Edit Part' : 'New Part' }}
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
      <form @submit.prevent="saveItem" class="p-6 space-y-4">
        <!-- Description (Required) -->
        <div>
          <label for="description" class="block text-sm font-medium text-gray-700 mb-1">
            Description <span class="text-red-500">*</span>
          </label>
          <input
            id="description"
            type="text"
            v-model="localItem.description"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="e.g., Oil Filter"
          />
        </div>

        <!-- Part Number & Category Row -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="part_number" class="block text-sm font-medium text-gray-700 mb-1">
              Part Number
            </label>
            <input
              id="part_number"
              type="text"
              v-model="localItem.part_number"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="e.g., OIL-1234"
            />
          </div>
          <div>
            <label for="category" class="block text-sm font-medium text-gray-700 mb-1">
              Category
            </label>
            <input
              id="category"
              type="text"
              v-model="localItem.category"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="e.g., Filters, Brakes"
            />
          </div>
        </div>

        <!-- Quantity & Min Stock Row -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="quantity" class="block text-sm font-medium text-gray-700 mb-1">
              Quantity in Stock
            </label>
            <input
              id="quantity"
              type="number"
              min="0"
              v-model.number="localItem.quantity"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            />
          </div>
          <div>
            <label for="min_stock" class="block text-sm font-medium text-gray-700 mb-1">
              Minimum Stock Level
            </label>
            <input
              id="min_stock"
              type="number"
              min="0"
              v-model.number="localItem.min_stock"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            />
          </div>
        </div>

        <!-- Unit Price & Cost Price Row -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="unit_price" class="block text-sm font-medium text-gray-700 mb-1">
              Sell Price ($)
            </label>
            <input
              id="unit_price"
              type="number"
              min="0"
              step="0.01"
              v-model.number="localItem.unit_price"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="0.00"
            />
          </div>
          <div>
            <label for="cost_price" class="block text-sm font-medium text-gray-700 mb-1">
              Cost Price ($)
            </label>
            <input
              id="cost_price"
              type="number"
              min="0"
              step="0.01"
              v-model.number="localItem.cost_price"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="0.00"
            />
          </div>
        </div>

        <!-- Supplier & Location Row -->
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label for="supplier" class="block text-sm font-medium text-gray-700 mb-1">
              Supplier
            </label>
            <input
              id="supplier"
              type="text"
              v-model="localItem.supplier"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="e.g., ABC Auto Parts"
            />
          </div>
          <div>
            <label for="location" class="block text-sm font-medium text-gray-700 mb-1">
              Storage Location
            </label>
            <input
              id="location"
              type="text"
              v-model="localItem.location"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              placeholder="e.g., Shelf A-3"
            />
          </div>
        </div>

        <!-- Notes -->
        <div>
          <label for="notes" class="block text-sm font-medium text-gray-700 mb-1">
            Notes
          </label>
          <textarea
            id="notes"
            v-model="localItem.notes"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            placeholder="Any additional notes about this part"
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
            {{ saving ? 'Saving...' : 'Save Part' }}
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
