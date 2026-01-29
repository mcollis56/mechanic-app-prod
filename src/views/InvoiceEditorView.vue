<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../supabaseClient.js';


const route = useRoute();
const router = useRouter();
const invoiceId = route.params.id;

const invoice = ref(null);
const customer = ref(null);
const items = ref([]);
const loading = ref(true);
const saving = ref(false);
const errorMsg = ref('');

// New line item form
const newItem = ref({
  description: '',
  quantity: 1,
  unit_price: 0,
  item_type: 'part'
});

// Computed totals
const subtotal = computed(() => {
  return items.value.reduce((sum, item) => {
    const qty = parseFloat(item.qty || item.quantity || 0);
    const price = parseFloat(item.unit_price || 0);
    return sum + (qty * price);
  }, 0);
});

const taxAmount = computed(() => {
  const taxRate = invoice.value?.tax_rate || 10;
  return (subtotal.value * taxRate) / 100;
});

const totalAmount = computed(() => {
  return subtotal.value + taxAmount.value;
});

// Fetch invoice data
const fetchInvoice = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    // Fetch invoice with customer details
    const { data: invoiceData, error: invoiceError } = await supabase
      .from('invoices')
      .select(`
        *,
        customers (
          id,
          name,
          email,
          phone
        )
      `)
      .eq('id', invoiceId)
      .single();

    if (invoiceError) throw invoiceError;

    invoice.value = invoiceData;
    customer.value = invoiceData.customers;

    // Fetch invoice items
    const { data: itemsData, error: itemsError } = await supabase
      .from('invoice_items')
      .select('*')
      .eq('invoice_id', invoiceId)
      .order('created_at', { ascending: true });

    if (itemsError) throw itemsError;

    items.value = itemsData || [];
  } catch (err) {
    errorMsg.value = `Error loading invoice: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

// Add new line item
const addLineItem = async () => {
  if (!newItem.value.description) {
    alert('Description is required');
    return;
  }

  try {
    saving.value = true;

    const { data, error } = await supabase
      .from('invoice_items')
      .insert({
        invoice_id: invoiceId,
        description: newItem.value.description,
        qty: parseFloat(newItem.value.quantity),
        unit_price: parseFloat(newItem.value.unit_price),
        kind: newItem.value.item_type || 'part'
      })
      .select()
      .single();

    if (error) throw error;

    items.value.push(data);

    // Reset form
    newItem.value = {
      description: '',
      quantity: 1,
      unit_price: 0,
      item_type: 'part'
    };

    await updateInvoiceTotals();
  } catch (err) {
    alert(`Error adding line item: ${err.message}`);
    console.error(err);
  } finally {
    saving.value = false;
  }
};

// Update existing line item
const updateLineItem = async (item) => {
  try {
    const { error } = await supabase
      .from('invoice_items')
      .update({
        description: item.description,
        qty: parseFloat(item.qty || item.quantity),
        unit_price: parseFloat(item.unit_price)
      })
      .eq('id', item.id);

    if (error) throw error;

    await updateInvoiceTotals();
  } catch (err) {
    alert(`Error updating line item: ${err.message}`);
    console.error(err);
  }
};

// Delete line item
const deleteLineItem = async (itemId) => {
  if (!confirm('Are you sure you want to delete this item?')) {
    return;
  }

  try {
    const { error } = await supabase
      .from('invoice_items')
      .delete()
      .eq('id', itemId);

    if (error) throw error;

    items.value = items.value.filter(item => item.id !== itemId);
    await updateInvoiceTotals();
  } catch (err) {
    alert(`Error deleting line item: ${err.message}`);
    console.error(err);
  }
};

// Update invoice totals
const updateInvoiceTotals = async () => {
  try {
    const { error } = await supabase
      .from('invoices')
      .update({
        subtotal: subtotal.value,
        tax_amount: taxAmount.value,
        total_amount: totalAmount.value
      })
      .eq('id', invoiceId);

    if (error) throw error;
  } catch (err) {
    console.error('Error updating totals:', err);
  }
};

// Update invoice status
const updateStatus = async (newStatus) => {
  try {
    const { error } = await supabase
      .from('invoices')
      .update({ status: newStatus })
      .eq('id', invoiceId);

    if (error) throw error;

    invoice.value.status = newStatus;
  } catch (err) {
    alert(`Error updating status: ${err.message}`);
    console.error(err);
  }
};

// Export to PDF
const exportToPDF = () => {
  const doc = new window.jspdf.jsPDF();

  // Set up colors
  const primaryColor = [124, 58, 237]; // Purple
  const textColor = [55, 65, 81]; // Gray-700

  // Header - Business Info
  doc.setFontSize(24);
  doc.setTextColor(...primaryColor);
  doc.text('Euro Motor Works', 20, 25);

  doc.setFontSize(10);
  doc.setTextColor(...textColor);
  doc.text('3/3 Taronga Pl,', 20, 32);
  doc.text('Mona Vale NSW 2103', 20, 37);
  doc.text('Phone: (02) 9999 2771', 20, 42);

  // Invoice Number and Date
  doc.setFontSize(16);
  doc.setTextColor(...primaryColor);
  doc.text(invoice.value.invoice_number, 140, 25);

  doc.setFontSize(10);
  doc.setTextColor(...textColor);
  doc.text(`Date: ${new Date(invoice.value.created_at).toLocaleDateString()}`, 140, 32);
  doc.text(`Due: ${invoice.value.due_date ? new Date(invoice.value.due_date).toLocaleDateString() : 'N/A'}`, 140, 37);
  doc.text(`Status: ${invoice.value.status.toUpperCase()}`, 140, 42);

  // Customer Info
  doc.setFontSize(12);
  doc.setTextColor(...primaryColor);
  doc.text('Bill To:', 20, 55);

  doc.setFontSize(10);
  doc.setTextColor(...textColor);
  doc.text(customer.value?.name || 'N/A', 20, 62);
  if (customer.value?.email) doc.text(customer.value.email, 20, 67);
  if (customer.value?.phone) doc.text(customer.value.phone, 20, 72);

  // Line Items Table
  const tableData = items.value.map(item => [
    item.description,
    (item.kind || 'part').charAt(0).toUpperCase() + (item.kind || 'part').slice(1),
    parseFloat(item.qty || 0).toFixed(2),
    `$${parseFloat(item.unit_price || 0).toFixed(2)}`,
    `$${(parseFloat(item.qty || 0) * parseFloat(item.unit_price || 0)).toFixed(2)}`
  ]);

  doc.autoTable({
    startY: 90,
    head: [['Description', 'Type', 'Quantity', 'Unit Price', 'Total']],
    body: tableData,
    theme: 'grid',
    headStyles: {
      fillColor: primaryColor,
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      fontSize: 10
    },
    styles: {
      fontSize: 9,
      cellPadding: 5
    },
    columnStyles: {
      2: { halign: 'right' },
      3: { halign: 'right' },
      4: { halign: 'right', fontStyle: 'bold' }
    }
  });

  // Totals
  const finalY = doc.lastAutoTable.finalY + 10;
  const totalsX = 130;

  doc.setFontSize(10);
  doc.text('Subtotal:', totalsX, finalY);
  doc.text(`$${subtotal.value.toFixed(2)}`, 190, finalY, { align: 'right' });

  doc.text(`Tax (${invoice.value.tax_rate || 10}%):`, totalsX, finalY + 7);
  doc.text(`$${taxAmount.value.toFixed(2)}`, 190, finalY + 7, { align: 'right' });

  doc.setFontSize(12);
  doc.setFont(undefined, 'bold');
  doc.text('Total:', totalsX, finalY + 17);
  doc.text(`$${totalAmount.value.toFixed(2)}`, 190, finalY + 17, { align: 'right' });

  // Notes (if any)
  if (invoice.value.notes) {
    doc.setFontSize(10);
    doc.setFont(undefined, 'normal');
    doc.text('Notes:', 20, finalY + 30);
    doc.setFontSize(9);
    const splitNotes = doc.splitTextToSize(invoice.value.notes, 170);
    doc.text(splitNotes, 20, finalY + 37);
  }

  // Footer
  doc.setFontSize(8);
  doc.setTextColor(150, 150, 150);
  doc.text('Thank you for your business!', 105, 280, { align: 'center' });

  // Save the PDF
  doc.save(`${invoice.value.invoice_number}.pdf`);
};

onMounted(fetchInvoice);
</script>

<template>
  <div class="invoice-editor p-6">
    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading invoice...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Invoice Content -->
    <div v-else-if="invoice" class="max-w-5xl mx-auto">
      <!-- Header -->
      <div class="flex justify-between items-start mb-6">
        <div>
          <button @click="router.push('/invoices')" class="text-purple-600 hover:text-purple-700 mb-4">
            ← Back to Invoices
          </button>
          <h1 class="text-3xl font-bold text-gray-900">{{ invoice.invoice_number }}</h1>
          <p class="text-gray-600 mt-1">Created: {{ new Date(invoice.created_at).toLocaleDateString() }}</p>
        </div>

        <div class="text-right">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              :value="invoice.status"
              @change="updateStatus($event.target.value)"
              class="px-4 py-2 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
            >
              <option value="draft">Draft</option>
              <option value="sent">Sent</option>
              <option value="paid">Paid</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Business & Customer Info -->
      <div class="grid grid-cols-2 gap-6 mb-8 bg-white p-6 rounded-lg shadow">
        <div>
          <h3 class="font-semibold text-gray-900 mb-2">From:</h3>
          <p class="text-gray-700 font-medium">Euro Motor Works</p>
          <p class="text-gray-600 text-sm">3/3 Taronga Pl</p>
          <p class="text-gray-600 text-sm">Mona Vale, NSW 2103</p>
          <p class="text-gray-600 text-sm">Phone: (02) 9999 2771</p>
        </div>

        <div>
          <h3 class="font-semibold text-gray-900 mb-2">Bill To:</h3>
          <p class="text-gray-700 font-medium">{{ customer?.name || 'N/A' }}</p>
          <p class="text-gray-600 text-sm">{{ customer?.email || '' }}</p>
          <p class="text-gray-600 text-sm">{{ customer?.phone || '' }}</p>
        </div>
      </div>

      <!-- Invoice Details -->
      <div class="bg-white p-6 rounded-lg shadow mb-6">
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div>
            <span class="font-medium text-gray-700">Invoice Date:</span>
            <span class="text-gray-600 ml-2">{{ new Date(invoice.created_at).toLocaleDateString() }}</span>
          </div>
          <div>
            <span class="font-medium text-gray-700">Due Date:</span>
            <span class="text-gray-600 ml-2">{{ invoice.due_date ? new Date(invoice.due_date).toLocaleDateString() : 'N/A' }}</span>
          </div>
        </div>
        <div v-if="invoice.notes" class="mt-4">
          <span class="font-medium text-gray-700">Notes:</span>
          <p class="text-gray-600 text-sm mt-1">{{ invoice.notes }}</p>
        </div>
      </div>

      <!-- Line Items Table -->
      <div class="bg-white rounded-lg shadow overflow-hidden mb-6">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Qty</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Unit Price</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="item in items" :key="item.id">
              <td class="px-6 py-4">
                <input
                  type="text"
                  v-model="item.description"
                  @blur="updateLineItem(item)"
                  class="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:ring-purple-500 focus:border-purple-500"
                />
              </td>
              <td class="px-6 py-4">
                <span class="px-2 py-1 text-xs font-medium rounded"
                  :class="item.kind === 'labor' ? 'bg-blue-100 text-blue-700' : 'bg-green-100 text-green-700'">
                  {{ item.kind || 'part' }}
                </span>
              </td>
              <td class="px-6 py-4 text-right">
                <input
                  type="number"
                  v-model="item.qty"
                  @blur="updateLineItem(item)"
                  step="0.01"
                  min="0"
                  class="w-20 px-2 py-1 text-sm text-right border border-gray-300 rounded focus:ring-purple-500 focus:border-purple-500"
                />
              </td>
              <td class="px-6 py-4 text-right">
                <input
                  type="number"
                  v-model="item.unit_price"
                  @blur="updateLineItem(item)"
                  step="0.01"
                  min="0"
                  class="w-24 px-2 py-1 text-sm text-right border border-gray-300 rounded focus:ring-purple-500 focus:border-purple-500"
                />
              </td>
              <td class="px-6 py-4 text-right font-medium">
                ${{ (parseFloat(item.qty || 0) * parseFloat(item.unit_price || 0)).toFixed(2) }}
              </td>
              <td class="px-6 py-4 text-right">
                <button
                  @click="deleteLineItem(item.id)"
                  class="text-red-600 hover:text-red-800 text-sm"
                >
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Add New Item Form -->
        <div class="border-t border-gray-200 bg-gray-50 px-6 py-4">
          <h4 class="text-sm font-medium text-gray-700 mb-3">Add Line Item</h4>
          <div class="grid grid-cols-6 gap-3">
            <div class="col-span-2">
              <input
                type="text"
                v-model="newItem.description"
                placeholder="Description"
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              />
            </div>
            <div>
              <select
                v-model="newItem.item_type"
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="labor">Labor</option>
                <option value="part">Part</option>
              </select>
            </div>
            <div>
              <input
                type="number"
                v-model="newItem.quantity"
                placeholder="Qty"
                step="0.01"
                min="0"
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              />
            </div>
            <div>
              <input
                type="number"
                v-model="newItem.unit_price"
                placeholder="Unit Price"
                step="0.01"
                min="0"
                class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
              />
            </div>
            <div>
              <button
                @click="addLineItem"
                :disabled="saving"
                class="w-full px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 disabled:opacity-50"
              >
                {{ saving ? 'Adding...' : 'Add Item' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Totals -->
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex justify-end">
          <div class="w-64 space-y-2">
            <div class="flex justify-between text-sm">
              <span class="text-gray-600">Subtotal:</span>
              <span class="font-medium">${{ subtotal.toFixed(2) }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-gray-600">Tax ({{ invoice.tax_rate || 10 }}%):</span>
              <span class="font-medium">${{ taxAmount.toFixed(2) }}</span>
            </div>
            <div class="flex justify-between text-lg font-bold border-t pt-2">
              <span>Total:</span>
              <span>${{ totalAmount.toFixed(2) }}</span>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end gap-3 mt-6 pt-6 border-t">
          <button
            @click="router.push('/invoices')"
            class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
          >
            Close
          </button>
          <button
            @click="exportToPDF"
            class="px-6 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700"
          >
            📄 Export to PDF
          </button>
        </div>
      </div>
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

input:focus,
select:focus {
  outline: none;
}
</style>
