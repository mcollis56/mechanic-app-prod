<script setup>
import { ref, watch, computed } from 'vue';
import { supabase } from '@/supabaseClient.js';

const props = defineProps({
  modelValue: Boolean,
  vehicle: Object,
  customerId: String // Optional: pre-select customer
});

const emit = defineEmits(['update:modelValue', 'vehicleSaved']);

const formData = ref({
  customer_id: '',
  vin: '',
  registration: '',
  make: '',
  model: '',
  year: new Date().getFullYear(),
  color: '',
  engine_type: '',
  transmission: '',
  odometer: null,
  notes: ''
});

const customers = ref([]);
const loading = ref(false);
const saving = ref(false);
const errorMsg = ref('');

const isEditMode = computed(() => !!props.vehicle?.id);
const modalTitle = computed(() => isEditMode.value ? 'Edit Vehicle' : 'New Vehicle');

// Fetch customers for dropdown
const fetchCustomers = async () => {
  try {
    const { data, error } = await supabase
      .from('customers')
      .select('id, name, email')
      .order('name', { ascending: true });

    if (error) throw error;
    customers.value = data || [];
  } catch (err) {
    console.error('Error fetching customers:', err);
  }
};

// Watch for vehicle prop changes
watch(() => props.vehicle, (newVehicle) => {
  if (newVehicle && newVehicle.id) {
    formData.value = { ...newVehicle };
  } else {
    resetForm();
  }
}, { immediate: true });

// Watch for customerId prop
watch(() => props.customerId, (newCustomerId) => {
  if (newCustomerId) {
    formData.value.customer_id = newCustomerId;
  }
}, { immediate: true });

// Watch for modal open
watch(() => props.modelValue, (isOpen) => {
  if (isOpen) {
    fetchCustomers();
  }
});

const resetForm = () => {
  formData.value = {
    customer_id: props.customerId || '',
    vin: '',
    registration: '',
    make: '',
    model: '',
    year: new Date().getFullYear(),
    color: '',
    engine_type: '',
    transmission: '',
    odometer: null,
    notes: ''
  };
  errorMsg.value = '';
};

const closeModal = () => {
  emit('update:modelValue', false);
  resetForm();
};

const saveVehicle = async () => {
  try {
    saving.value = true;
    errorMsg.value = '';

    // Validation
    if (!formData.value.customer_id) {
      errorMsg.value = 'Please select a customer';
      return;
    }
    if (!formData.value.make || !formData.value.model) {
      errorMsg.value = 'Make and Model are required';
      return;
    }

    const vehicleData = {
      customer_id: formData.value.customer_id,
      vin: formData.value.vin || null,
      registration: formData.value.registration || null,
      make: formData.value.make,
      model: formData.value.model,
      year: formData.value.year || null,
      color: formData.value.color || null,
      engine_type: formData.value.engine_type || null,
      transmission: formData.value.transmission || null,
      odometer: formData.value.odometer || null,
      notes: formData.value.notes || null
    };

    if (isEditMode.value) {
      // Update existing vehicle
      const { error } = await supabase
        .from('vehicles')
        .update(vehicleData)
        .eq('id', props.vehicle.id);

      if (error) throw error;
    } else {
      // Create new vehicle
      const { error } = await supabase
        .from('vehicles')
        .insert([vehicleData]);

      if (error) throw error;
    }

    emit('vehicleSaved');
    closeModal();
  } catch (err) {
    errorMsg.value = err.message;
    console.error('Error saving vehicle:', err);
  } finally {
    saving.value = false;
  }
};
</script>

<template>
  <div v-if="modelValue" class="modal-overlay" @click.self="closeModal">
    <div class="modal-content">
      <header class="modal-header">
        <h2 class="text-2xl font-bold">{{ modalTitle }}</h2>
        <button @click="closeModal" class="close-btn">&times;</button>
      </header>

      <div v-if="errorMsg" class="error-message">
        {{ errorMsg }}
      </div>

      <form @submit.prevent="saveVehicle" class="modal-body">
        <!-- Customer Selection -->
        <div class="form-group">
          <label for="customer_id" class="required">Customer</label>
          <select
            id="customer_id"
            v-model="formData.customer_id"
            required
            class="form-input"
          >
            <option value="">Select a customer</option>
            <option v-for="customer in customers" :key="customer.id" :value="customer.id">
              {{ customer.name }} {{ customer.email ? `(${customer.email})` : '' }}
            </option>
          </select>
        </div>

        <!-- Vehicle Details Row 1 -->
        <div class="form-row">
          <div class="form-group">
            <label for="make" class="required">Make</label>
            <input
              id="make"
              v-model="formData.make"
              type="text"
              required
              placeholder="e.g., Toyota"
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="model" class="required">Model</label>
            <input
              id="model"
              v-model="formData.model"
              type="text"
              required
              placeholder="e.g., Camry"
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="year">Year</label>
            <input
              id="year"
              v-model.number="formData.year"
              type="number"
              min="1900"
              :max="new Date().getFullYear() + 1"
              placeholder="2024"
              class="form-input"
            />
          </div>
        </div>

        <!-- Vehicle Details Row 2 -->
        <div class="form-row">
          <div class="form-group">
            <label for="vin">VIN</label>
            <input
              id="vin"
              v-model="formData.vin"
              type="text"
              maxlength="17"
              placeholder="17-character VIN"
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="registration">Registration</label>
            <input
              id="registration"
              v-model="formData.registration"
              type="text"
              placeholder="License plate"
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="color">Color</label>
            <input
              id="color"
              v-model="formData.color"
              type="text"
              placeholder="e.g., Black"
              class="form-input"
            />
          </div>
        </div>

        <!-- Vehicle Details Row 3 -->
        <div class="form-row">
          <div class="form-group">
            <label for="engine_type">Engine Type</label>
            <input
              id="engine_type"
              v-model="formData.engine_type"
              type="text"
              placeholder="e.g., 2.5L I4"
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="transmission">Transmission</label>
            <select id="transmission" v-model="formData.transmission" class="form-input">
              <option value="">Select transmission</option>
              <option value="Manual">Manual</option>
              <option value="Automatic">Automatic</option>
              <option value="CVT">CVT</option>
              <option value="DCT">DCT</option>
            </select>
          </div>

          <div class="form-group">
            <label for="odometer">Odometer (km)</label>
            <input
              id="odometer"
              v-model.number="formData.odometer"
              type="number"
              min="0"
              placeholder="Current mileage"
              class="form-input"
            />
          </div>
        </div>

        <!-- Notes -->
        <div class="form-group">
          <label for="notes">Notes</label>
          <textarea
            id="notes"
            v-model="formData.notes"
            rows="3"
            placeholder="Additional notes about this vehicle..."
            class="form-input"
          ></textarea>
        </div>

        <!-- Actions -->
        <div class="modal-footer">
          <button type="button" @click="closeModal" class="btn btn-secondary">
            Cancel
          </button>
          <button type="submit" :disabled="saving" class="btn btn-primary">
            {{ saving ? 'Saving...' : 'Save Vehicle' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.close-btn {
  font-size: 2rem;
  background: none;
  border: none;
  cursor: pointer;
  color: #6b7280;
  line-height: 1;
  padding: 0;
  width: 2rem;
  height: 2rem;
}

.close-btn:hover {
  color: #111827;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
  margin-top: 1rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

label {
  display: block;
  font-weight: 500;
  margin-bottom: 0.5rem;
  color: #374151;
}

label.required::after {
  content: ' *';
  color: #ef4444;
}

.form-input {
  width: 100%;
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.875rem;
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.error-message {
  background: #fee2e2;
  border: 1px solid #fecaca;
  color: #991b1b;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  margin: 0 1.5rem 1rem;
}

.btn {
  padding: 0.625rem 1.25rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.btn-primary {
  background: #7c3aed;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #6d28d9;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
}

.btn-secondary:hover {
  background: #e5e7eb;
}
</style>
