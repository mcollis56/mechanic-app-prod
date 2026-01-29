<script setup>
import { ref, watch, onMounted, computed } from 'vue';
import { supabase } from '../supabaseClient.js';

const props = defineProps({
  job: Object,
  modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'jobSaved']);

const localJob = ref({ status: 'Booking' });
const customers = ref([]);
const vehicles = ref([]);
const filteredVehicles = ref([]);

// New customer/vehicle forms
const showNewCustomerForm = ref(false);
const showNewVehicleForm = ref(false);
const newCustomer = ref({ name: '', email: '', phone: '' });
const newVehicle = ref({ make: '', model: '', rego: '', vin: '', engine_code: '', customer_id: null });

const fetchCustomers = async () => {
  const { data } = await supabase.from('customers').select('*');
  if (data) customers.value = data;
};

const fetchVehicles = async () => {
  const { data } = await supabase.from('vehicles').select('*');
  if (data) vehicles.value = data;
};

onMounted(async () => {
  await fetchCustomers();
  await fetchVehicles();
});

watch(() => props.job, (newJob) => {
  if (newJob && Object.keys(newJob).length > 0) {
    localJob.value = { ...newJob };
    if (localJob.value.customer_id) {
      filterVehiclesByCustomer(localJob.value.customer_id);
    }
  } else {
    localJob.value = { status: 'Booking' };
    filteredVehicles.value = [];
  }
}, { immediate: true, deep: true });

watch(() => localJob.value.customer_id, (customerId) => {
  if (customerId) {
    filterVehiclesByCustomer(customerId);
  } else {
    filteredVehicles.value = [];
  }
});

const filterVehiclesByCustomer = (customerId) => {
  filteredVehicles.value = vehicles.value.filter(v => v.customer_id === customerId);
};

const selectedVehicleDetails = computed(() => {
  if (!localJob.value.vehicle_id) return null;
  return vehicles.value.find(v => v.id === localJob.value.vehicle_id);
});

const handleCustomerChange = (event) => {
  if (event.target.value === 'new') {
    showNewCustomerForm.value = true;
    localJob.value.customer_id = null;
  }
};

const handleVehicleChange = (event) => {
  if (event.target.value === 'new') {
    showNewVehicleForm.value = true;
    localJob.value.vehicle_id = null;
  }
};

const saveNewCustomer = async () => {
  const { data, error } = await supabase
    .from('customers')
    .insert(newCustomer.value)
    .select()
    .single();

  if (!error && data) {
    await fetchCustomers();
    localJob.value.customer_id = data.id;
    showNewCustomerForm.value = false;
    newCustomer.value = { name: '', email: '', phone: '' };
  }
};

const saveNewVehicle = async () => {
  newVehicle.value.customer_id = localJob.value.customer_id;
  const { data, error } = await supabase
    .from('vehicles')
    .insert(newVehicle.value)
    .select()
    .single();

  if (!error && data) {
    await fetchVehicles();
    filterVehiclesByCustomer(localJob.value.customer_id);
    localJob.value.vehicle_id = data.id;
    showNewVehicleForm.value = false;
    newVehicle.value = { make: '', model: '', rego: '', vin: '', engine_code: '', customer_id: null };
  }
};

const saveJob = async () => {
  console.log('Saving job:', localJob.value);

  try {
    // 1. If new customer form is open, save it first
    if (showNewCustomerForm.value) {
      const { data: custData, error: custError } = await supabase
        .from('customers')
        .insert(newCustomer.value)
        .select()
        .single();

      if (custError) throw custError;
      localJob.value.customer_id = custData.id;
      showNewCustomerForm.value = false;
      await fetchCustomers();
      newCustomer.value = { name: '', email: '', phone: '' };
    }

    // 2. If new vehicle form is open, save it first
    if (showNewVehicleForm.value) {
      // Ensure we have the customer ID (might have just been created above)
      newVehicle.value.customer_id = localJob.value.customer_id;
      
      const { data: vehData, error: vehError } = await supabase
        .from('vehicles')
        .insert(newVehicle.value)
        .select()
        .single();

      if (vehError) throw vehError;
      localJob.value.vehicle_id = vehData.id;
      showNewVehicleForm.value = false;
      await fetchVehicles();
      newVehicle.value = { make: '', model: '', rego: '', vin: '', engine_code: '', customer_id: null };
    }

    // 3. Validation check (now that we've tried to create new records)
    if (!localJob.value.customer_id || !localJob.value.vehicle_id) {
      alert('Please select a customer and vehicle');
      return;
    }

    // 4. Sanitize payload to only include valid jobs table columns
    const payload = {
      customer_id: localJob.value.customer_id,
      vehicle_id: localJob.value.vehicle_id,
      problem_description: localJob.value.problem_description,
      due_date: localJob.value.due_date,
      status: localJob.value.status,
      shop_id: localJob.value.shop_id
    };

    if (localJob.value.id) {
      payload.id = localJob.value.id;
    }

    const { data, error } = await supabase
      .from('jobs')
      .upsert(payload)
      .select()
      .single();

    if (error) {
      console.error('Error saving job:', error);
      alert(`Error saving job: ${error.message || 'Unknown error'}`);
    } else {
      console.log('Job saved successfully:', data);
      emit('jobSaved', data);
      closeModal();
    }
  } catch (err) {
    console.error('Unexpected error:', err);
    alert(`Unexpected error: ${err.message}`);
  }
};

const closeModal = () => {
  localJob.value = { status: 'Booking' };
  showNewCustomerForm.value = false;
  showNewVehicleForm.value = false;
  emit('update:modelValue', false);
};
</script>

<template>
  <div v-if="modelValue" class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
    <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
      <h2 class="text-2xl font-bold mb-4">{{ localJob.id ? 'Edit Job' : 'New Job' }}</h2>

      <form @submit.prevent="saveJob">
        <!-- Customer Selection -->
        <div class="mb-4">
          <label for="customer" class="block text-sm font-medium text-gray-700 mb-1">Customer</label>
          <select
            id="customer"
            v-model="localJob.customer_id"
            @change="handleCustomerChange"
            class="mt-1 block w-full p-2 border border-gray-300 rounded-md"
          >
            <option :value="null">Select a customer...</option>
            <option v-for="customer in customers" :key="customer.id" :value="customer.id">
              {{ customer.name }}
            </option>
            <option value="new">+ Add New Customer</option>
          </select>
        </div>

        <!-- New Customer Form -->
        <div v-if="showNewCustomerForm" class="mb-4 p-4 bg-gray-50 rounded border">
          <h3 class="font-semibold mb-2">New Customer</h3>
          <input v-model="newCustomer.name" placeholder="Name" class="w-full p-2 border rounded mb-2" required />
          <input v-model="newCustomer.email" type="email" placeholder="Email" class="w-full p-2 border rounded mb-2" />
          <input v-model="newCustomer.phone" placeholder="Phone" class="w-full p-2 border rounded mb-2" />
          <div class="flex gap-2">
            <button type="button" @click="saveNewCustomer" class="px-3 py-1 bg-green-600 text-white rounded text-sm">
              Save Customer
            </button>
            <button type="button" @click="showNewCustomerForm = false" class="px-3 py-1 bg-gray-300 rounded text-sm">
              Cancel
            </button>
          </div>
        </div>

        <!-- Vehicle Selection -->
        <div class="mb-4">
          <label for="vehicle" class="block text-sm font-medium text-gray-700 mb-1">Vehicle</label>
          <select
            id="vehicle"
            v-model="localJob.vehicle_id"
            @change="handleVehicleChange"
            :disabled="!localJob.customer_id && !showNewCustomerForm"
            class="mt-1 block w-full p-2 border border-gray-300 rounded-md"
          >
            <option :value="null">Select a vehicle...</option>
            <option v-for="vehicle in filteredVehicles" :key="vehicle.id" :value="vehicle.id">
              {{ vehicle.make }} {{ vehicle.model }} - {{ vehicle.rego }}
            </option>
            <option value="new" v-if="localJob.customer_id || showNewCustomerForm">+ Add New Vehicle</option>
          </select>

          <!-- Selected Vehicle Details (VIN/Engine) -->
          <div v-if="selectedVehicleDetails" class="mt-2 p-2 bg-blue-50 rounded border border-blue-100 text-xs text-blue-800">
            <div class="flex justify-between">
              <span><strong>VIN:</strong> {{ selectedVehicleDetails.vin || 'N/A' }}</span>
              <span><strong>Engine:</strong> {{ selectedVehicleDetails.engine_code || 'N/A' }}</span>
            </div>
          </div>
        </div>

        <!-- New Vehicle Form -->
        <div v-if="showNewVehicleForm" class="mb-4 p-4 bg-gray-50 rounded border">
          <h3 class="font-semibold mb-2">New Vehicle</h3>
          <input v-model="newVehicle.make" placeholder="Make" class="w-full p-2 border rounded mb-2" required />
          <input v-model="newVehicle.model" placeholder="Model" class="w-full p-2 border rounded mb-2" required />
          <input v-model="newVehicle.rego" placeholder="Registration" class="w-full p-2 border rounded mb-2" required />
          <input v-model="newVehicle.vin" placeholder="VIN" class="w-full p-2 border rounded mb-2" />
          <input v-model="newVehicle.engine_code" placeholder="Engine Code" class="w-full p-2 border rounded mb-2" />
          <div class="flex gap-2">
            <button type="button" @click="saveNewVehicle" class="px-3 py-1 bg-green-600 text-white rounded text-sm">
              Save Vehicle
            </button>
            <button type="button" @click="showNewVehicleForm = false" class="px-3 py-1 bg-gray-300 rounded text-sm">
              Cancel
            </button>
          </div>
        </div>

        <!-- Problem Description -->
        <div class="mb-4">
          <label for="problem_description" class="block text-sm font-medium text-gray-700 mb-1">Problem Description</label>
          <textarea
            id="problem_description"
            v-model="localJob.problem_description"
            rows="3"
            class="mt-1 block w-full p-2 border border-gray-300 rounded-md"
          ></textarea>
        </div>

        <!-- Due Date -->
        <div class="mb-4">
          <label for="due_date" class="block text-sm font-medium text-gray-700 mb-1">Due Date</label>
          <input
            type="date"
            id="due_date"
            v-model="localJob.due_date"
            class="mt-1 block w-full p-2 border border-gray-300 rounded-md"
          />
        </div>

        <!-- Status -->
        <div class="mb-4">
          <label for="status" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select id="status" v-model="localJob.status" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
            <option value="Booking">Booking</option>
            <option value="In progress">In Progress</option>
            <option value="Awaiting parts">Awaiting Parts</option>
            <option value="Complete">Complete</option>
          </select>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-4 mt-6">
          <button type="button" @click="closeModal" class="px-4 py-2 bg-gray-300 rounded-md hover:bg-gray-400">
            Cancel
          </button>
          <button type="submit" class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700">
            Save Job
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
select:disabled {
  background-color: #f3f4f6;
  cursor: not-allowed;
}
</style>
