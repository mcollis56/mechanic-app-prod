<template>
  <div class="job-card">
    <div class="card-header">
      <span class="job-id">#{{ job.id }}</span>
      <span class="status-badge">{{ job.status }}</span>
    </div>
    <div class="card-body">
      <p class="description">{{ job.description || job.problem_description }}</p>
      <div class="job-details">
        <p v-if="job.customers"><strong>Customer:</strong> {{ job.customers.name }}</p>
        <p v-if="job.vehicles"><strong>Vehicle:</strong> {{ job.vehicles.make }} {{ job.vehicles.model }} - {{ job.vehicles.rego }}</p>
      </div>

      <!-- Generate Invoice Button (only for Complete status) -->
      <div v-if="job.status === 'Complete'" class="card-actions">
        <button
          @click.stop="generateInvoice"
          :disabled="generating"
          class="btn-generate-invoice"
        >
          {{ generating ? 'Generating...' : '📄 Generate Invoice' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../supabaseClient.js';

const props = defineProps({
  job: {
    type: Object,
    required: true
  }
});

const router = useRouter();
const generating = ref(false);

const generateInvoice = async () => {
  try {
    generating.value = true;

    // Check if invoice already exists for this job
    const { data: existingInvoice } = await supabase
      .from('invoices')
      .select('id')
      .eq('job_id', props.job.id)
      .single();

    if (existingInvoice) {
      // Invoice already exists, navigate to it
      router.push(`/invoice/${existingInvoice.id}`);
      return;
    }

    // Calculate due date (30 days from now)
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 30);

    // Create invoice
    const { data: invoice, error: invoiceError } = await supabase
      .from('invoices')
      .insert({
        job_id: props.job.id,
        customer_id: props.job.customer_id,
        status: 'draft',
        due_date: dueDate.toISOString().split('T')[0],
        notes: `Invoice for: ${props.job.problem_description || props.job.description}`
      })
      .select()
      .single();

    if (invoiceError) throw invoiceError;

    // Create initial labor line item
    const laborRate = 150; // Hardcoded hourly rate
    const estimatedHours = 2; // Default estimate

    const { error: itemError } = await supabase
      .from('invoice_items')
      .insert({
        invoice_id: invoice.id,
        description: `Labor: ${props.job.problem_description || props.job.description}`,
        qty: estimatedHours,
        unit_price: laborRate,
        kind: 'labor'
      });

    if (itemError) throw itemError;

    // Navigate to invoice editor
    router.push(`/invoice/${invoice.id}`);
  } catch (err) {
    console.error('Error generating invoice:', err);
    alert(`Error generating invoice: ${err.message}`);
  } finally {
    generating.value = false;
  }
};
</script>

<style scoped>
.job-card {
  background-color: #ffffff;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.job-card:hover {
  box-shadow: 0 4px 6px rgba(0,0,0,0.15);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.job-id {
  font-weight: bold;
  color: #555;
  font-size: 0.85em;
}

.status-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75em;
  font-weight: 600;
  background-color: #e5e7eb;
  color: #374151;
}

.card-body .description {
  color: #333;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.job-details {
  font-size: 0.85em;
  color: #666;
}

.job-details p {
  margin: 0.25rem 0;
}

.card-actions {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #eee;
}

.btn-generate-invoice {
  width: 100%;
  padding: 0.5rem 1rem;
  background-color: #7c3aed;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-generate-invoice:hover:not(:disabled) {
  background-color: #6d28d9;
}

.btn-generate-invoice:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
