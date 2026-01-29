<script setup>
import { ref, watch, computed } from 'vue';
import { supabase } from '@/supabaseClient.js';

const props = defineProps({
  jobId: {
    type: String,
    required: true
  }
});

const emit = defineEmits(['partsUpdated']);

const parts = ref([]);
const suppliers = ref([]);
const loading = ref(false);
const saving = ref(false);
const showAddForm = ref(false);

const newPart = ref({
  part_name: '',
  part_number: '',
  quantity: 1,
  unit_cost: 0,
  supplier_id: null,
  notes: ''
});

const totalPartsCost = computed(() => {
  return parts.value.reduce((sum, part) => {
    return sum + (part.quantity * part.unit_cost);
  }, 0);
});

// Fetch parts for this job
const fetchParts = async () => {
  try {
    loading.value = true;
    const { data, error } = await supabase
      .from('parts_usage')
      .select(`
        *,
        suppliers (
          id,
          name
        )
      `)
      .eq('job_id', props.jobId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    parts.value = data || [];
  } catch (err) {
    console.error('Error fetching parts:', err);
  } finally {
    loading.value = false;
  }
};

// Fetch suppliers for dropdown
const fetchSuppliers = async () => {
  try {
    const { data, error } = await supabase
      .from('suppliers')
      .select('id, name')
      .order('name', { ascending: true });

    if (error) throw error;
    suppliers.value = data || [];
  } catch (err) {
    console.error('Error fetching suppliers:', err);
  }
};

// Add a new part
const addPart = async () => {
  try {
    saving.value = true;

    if (!newPart.value.part_name || newPart.value.quantity <= 0 || newPart.value.unit_cost < 0) {
      alert('Please fill in all required fields');
      return;
    }

    const { error } = await supabase
      .from('parts_usage')
      .insert([{
        job_id: props.jobId,
        part_name: newPart.value.part_name,
        part_number: newPart.value.part_number || null,
        quantity: newPart.value.quantity,
        unit_cost: newPart.value.unit_cost,
        supplier_id: newPart.value.supplier_id || null,
        notes: newPart.value.notes || null
      }]);

    if (error) throw error;

    // Reset form
    newPart.value = {
      part_name: '',
      part_number: '',
      quantity: 1,
      unit_cost: 0,
      supplier_id: null,
      notes: ''
    };

    showAddForm.value = false;
    await fetchParts();
    emit('partsUpdated', totalPartsCost.value);
  } catch (err) {
    alert(`Error adding part: ${err.message}`);
    console.error('Error adding part:', err);
  } finally {
    saving.value = false;
  }
};

// Delete a part
const deletePart = async (partId) => {
  if (!confirm('Are you sure you want to remove this part?')) {
    return;
  }

  try {
    const { error } = await supabase
      .from('parts_usage')
      .delete()
      .eq('id', partId);

    if (error) throw error;

    await fetchParts();
    emit('partsUpdated', totalPartsCost.value);
  } catch (err) {
    alert(`Error deleting part: ${err.message}`);
    console.error('Error deleting part:', err);
  }
};

// Watch for jobId changes
watch(() => props.jobId, (newJobId) => {
  if (newJobId) {
    fetchParts();
    fetchSuppliers();
  }
}, { immediate: true });
</script>

<template>
  <div class="parts-usage-editor">
    <div class="header">
      <h3 class="title">Parts Used</h3>
      <button
        @click="showAddForm = !showAddForm"
        class="btn-add"
        type="button"
      >
        {{ showAddForm ? '− Cancel' : '+ Add Part' }}
      </button>
    </div>

    <!-- Add Part Form -->
    <div v-if="showAddForm" class="add-form">
      <div class="form-row">
        <div class="form-group">
          <label for="part_name">Part Name *</label>
          <input
            id="part_name"
            v-model="newPart.part_name"
            type="text"
            placeholder="e.g., Oil Filter"
            class="form-input"
            required
          />
        </div>

        <div class="form-group">
          <label for="part_number">Part Number</label>
          <input
            id="part_number"
            v-model="newPart.part_number"
            type="text"
            placeholder="e.g., OF-12345"
            class="form-input"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="quantity">Quantity *</label>
          <input
            id="quantity"
            v-model.number="newPart.quantity"
            type="number"
            min="1"
            class="form-input"
            required
          />
        </div>

        <div class="form-group">
          <label for="unit_cost">Unit Cost ($) *</label>
          <input
            id="unit_cost"
            v-model.number="newPart.unit_cost"
            type="number"
            min="0"
            step="0.01"
            class="form-input"
            required
          />
        </div>

        <div class="form-group">
          <label for="supplier_id">Supplier</label>
          <select
            id="supplier_id"
            v-model="newPart.supplier_id"
            class="form-input"
          >
            <option :value="null">Select supplier</option>
            <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
              {{ supplier.name }}
            </option>
          </select>
        </div>
      </div>

      <div class="form-group">
        <label for="notes">Notes</label>
        <textarea
          id="notes"
          v-model="newPart.notes"
          rows="2"
          placeholder="Additional notes about this part..."
          class="form-input"
        ></textarea>
      </div>

      <div class="form-actions">
        <button @click="showAddForm = false" class="btn-secondary" type="button">
          Cancel
        </button>
        <button @click="addPart" :disabled="saving" class="btn-primary" type="button">
          {{ saving ? 'Adding...' : 'Add Part' }}
        </button>
      </div>
    </div>

    <!-- Parts List -->
    <div v-if="loading" class="loading">Loading parts...</div>

    <div v-else-if="parts.length === 0 && !showAddForm" class="empty-state">
      <p>No parts added yet</p>
    </div>

    <div v-else class="parts-list">
      <div v-for="part in parts" :key="part.id" class="part-item">
        <div class="part-info">
          <div class="part-header">
            <strong>{{ part.part_name }}</strong>
            <span v-if="part.part_number" class="part-number">{{ part.part_number }}</span>
          </div>
          <div class="part-details">
            <span>Qty: {{ part.quantity }}</span>
            <span>@ ${{ part.unit_cost.toFixed(2) }}</span>
            <span class="part-total">= ${{ (part.quantity * part.unit_cost).toFixed(2) }}</span>
            <span v-if="part.suppliers" class="supplier">{{ part.suppliers.name }}</span>
          </div>
          <div v-if="part.notes" class="part-notes">{{ part.notes }}</div>
        </div>
        <button
          @click="deletePart(part.id)"
          class="btn-delete"
          type="button"
          title="Remove part"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
    </div>

    <!-- Total -->
    <div v-if="parts.length > 0" class="total-section">
      <span class="total-label">Total Parts Cost:</span>
      <span class="total-amount">${{ totalPartsCost.toFixed(2) }}</span>
    </div>
  </div>
</template>

<style scoped>
.parts-usage-editor {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1rem;
  background: #f9fafb;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.title {
  font-size: 1rem;
  font-weight: 600;
  color: #111827;
}

.btn-add {
  padding: 0.5rem 0.75rem;
  background: #7c3aed;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-add:hover {
  background: #6d28d9;
}

.add-form {
  background: white;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

label {
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.25rem;
}

.form-input {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 0.875rem;
}

.form-input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.form-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
  margin-top: 0.75rem;
}

.btn-primary {
  padding: 0.5rem 1rem;
  background: #7c3aed;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  font-size: 0.875rem;
}

.btn-primary:hover:not(:disabled) {
  background: #6d28d9;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  padding: 0.5rem 1rem;
  background: #f3f4f6;
  color: #374151;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  font-size: 0.875rem;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.loading {
  text-align: center;
  padding: 1rem;
  color: #6b7280;
  font-size: 0.875rem;
}

.empty-state {
  text-align: center;
  padding: 2rem 1rem;
  color: #9ca3af;
  font-size: 0.875rem;
}

.parts-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.part-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 0.75rem;
}

.part-info {
  flex: 1;
}

.part-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.25rem;
}

.part-number {
  font-size: 0.75rem;
  color: #6b7280;
  font-family: monospace;
}

.part-details {
  display: flex;
  gap: 0.75rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.part-total {
  font-weight: 600;
  color: #111827;
}

.supplier {
  color: #7c3aed;
}

.part-notes {
  margin-top: 0.5rem;
  font-size: 0.75rem;
  color: #6b7280;
  font-style: italic;
}

.btn-delete {
  padding: 0.25rem;
  background: none;
  border: none;
  color: #ef4444;
  cursor: pointer;
  transition: color 0.2s;
}

.btn-delete:hover {
  color: #dc2626;
}

.total-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 2px solid #e5e7eb;
  font-weight: 600;
}

.total-label {
  color: #374151;
}

.total-amount {
  font-size: 1.25rem;
  color: #7c3aed;
}
</style>
