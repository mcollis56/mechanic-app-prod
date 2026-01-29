<template>
  <div class="min-h-screen bg-gray-50 p-6" v-if="workOrder">
    <div class="max-w-4xl mx-auto">
      <!-- Work Order Header -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-4">Work Order Detail</h1>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <p class="text-sm text-gray-600">ID</p>
            <p class="text-lg font-semibold text-gray-800">{{ workOrder.id }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-600">Status</p>
            <p class="text-lg font-semibold" :class="statusClass">{{ formatStatus(workOrder.status) }}</p>
          </div>
          <div v-if="workOrder.job_type">
            <p class="text-sm text-gray-600">Job Type</p>
            <p class="text-lg font-semibold text-purple-600">
              <span v-if="workOrder.job_type === 'rego_renewal'">Rego Renewal / Pink Slip</span>
              <span v-else>{{ workOrder.job_type }}</span>
            </p>
          </div>
          <div class="md:col-span-2">
            <p class="text-sm text-gray-600">Summary</p>
            <p class="text-lg text-gray-800">{{ workOrder.summary }}</p>
          </div>
          <div class="md:col-span-2">
            <p class="text-sm text-gray-600">Labour Notes</p>
            <p class="text-lg text-gray-800">{{ workOrder.labour_notes }}</p>
          </div>
        </div>
      </div>

      <!-- Tab Navigation -->
      <div class="mb-6 border-b border-gray-200">
        <nav class="-mb-px flex space-x-8">
          <button
            @click="activeTab = 'details'"
            :class="[
              activeTab === 'details'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
              'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
            ]"
          >
            Details
          </button>
          <button
            @click="activeTab = 'inspection'"
            :class="[
              activeTab === 'inspection'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
              'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
            ]"
          >
            Inspection
          </button>
        </nav>
      </div>

      <!-- Details Tab Content -->
      <div v-show="activeTab === 'details'">

      <!-- Rego Renewal Inspection Section - Only shows for rego_renewal job types -->
      <div v-if="isRegoRenewal" class="bg-white rounded-lg shadow-md p-6 mb-6 border-2 border-purple-200">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center">
            <svg class="w-8 h-8 text-purple-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <h2 class="text-2xl font-bold text-gray-800">eSafety Inspection</h2>
          </div>
          <span class="px-3 py-1 text-sm font-semibold rounded-full" :class="inspectionStatusBadgeClass">
            {{ inspectionStatusLabel }}
          </span>
        </div>

        <!-- Awaiting Inspection State -->
        <div v-if="workOrder.status === 'awaiting_inspection'" class="space-y-4">
          <p class="text-gray-600">
            Complete the vehicle inspection and record the result below.
          </p>
          <div class="flex gap-4">
            <button
              @click="handleInspectionPass"
              :disabled="isUpdatingStatus"
              class="flex-1 px-6 py-4 bg-green-600 hover:bg-green-700 disabled:bg-green-400 text-white font-bold rounded-lg transition-colors flex items-center justify-center gap-2"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              {{ isUpdatingStatus ? 'Processing...' : 'PASS - Issue Pink Slip' }}
            </button>
            <button
              @click="handleInspectionFail"
              :disabled="isUpdatingStatus"
              class="flex-1 px-6 py-4 bg-red-600 hover:bg-red-700 disabled:bg-red-400 text-white font-bold rounded-lg transition-colors flex items-center justify-center gap-2"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
              {{ isUpdatingStatus ? 'Processing...' : 'FAIL - Requires Repairs' }}
            </button>
          </div>
        </div>

        <!-- Inspection Failed State -->
        <div v-else-if="workOrder.status === 'inspection_failed'" class="space-y-4">
          <div class="bg-red-50 border border-red-200 rounded-lg p-4">
            <div class="flex items-start">
              <svg class="w-6 h-6 text-red-600 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              <div>
                <h3 class="font-semibold text-red-800">Inspection Failed</h3>
                <p class="text-red-700 text-sm mt-1">
                  The vehicle did not pass the eSafety inspection. Add repair items below and complete the repairs before re-inspecting.
                </p>
              </div>
            </div>
          </div>
          <button
            @click="handleReInspect"
            :disabled="isUpdatingStatus"
            class="w-full px-6 py-3 bg-purple-600 hover:bg-purple-700 disabled:bg-purple-400 text-white font-semibold rounded-lg transition-colors"
          >
            {{ isUpdatingStatus ? 'Processing...' : 'Re-inspect Vehicle' }}
          </button>
        </div>

        <!-- Pink Slip Lodged State -->
        <div v-else-if="workOrder.status === 'pink_slip_lodged'" class="space-y-4">
          <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <div class="flex items-start">
              <svg class="w-6 h-6 text-green-600 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <div>
                <h3 class="font-semibold text-green-800">Pink Slip Issued</h3>
                <p class="text-green-700 text-sm mt-1">
                  The vehicle has passed the eSafety inspection and the Pink Slip has been lodged. The eSafety Check fee has been automatically added to the work order.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Line Items Section (Parts + Services combined) -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Line Items</h2>

        <!-- Combined Line Items List -->
        <div v-if="allLineItems.length > 0" class="mb-6">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Qty</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Unit Price</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="item in allLineItems" :key="item.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ item.description }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span
                      class="px-2 py-1 text-xs font-medium rounded-full"
                      :class="item.type === 'Part' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'"
                    >
                      {{ item.type }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ item.quantity || '-' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ item.unitPrice ? `$${item.unitPrice}` : '-' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">${{ item.total }}</td>
                </tr>
              </tbody>
              <tfoot class="bg-gray-50">
                <tr>
                  <td colspan="4" class="px-6 py-4 text-right text-sm font-bold text-gray-700">Grand Total:</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-green-700">${{ grandTotal.toFixed(2) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
        <div v-else class="mb-6 p-4 bg-gray-50 rounded-md">
          <p class="text-gray-600 text-center">No items added yet</p>
        </div>

        <!-- Add Items Section (Collapsible) -->
        <div class="border-t border-gray-200 pt-4">
          <button
            @click="showAddForms = !showAddForms"
            class="flex items-center justify-between w-full text-left text-gray-700 hover:text-gray-900"
          >
            <span class="text-lg font-semibold">Add Items</span>
            <svg
              class="w-5 h-5 transform transition-transform"
              :class="{ 'rotate-180': showAddForms }"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          <div v-show="showAddForms" class="mt-4 space-y-6">
            <!-- Add Part Form -->
            <div class="bg-blue-50 rounded-lg p-6">
              <h3 class="text-lg font-semibold text-gray-800 mb-4">Add Part</h3>
              <form @submit.prevent="addPart" class="space-y-4">
                <!-- Searchable Part Dropdown -->
                <div class="relative">
                  <label for="partSearch" class="block text-sm font-medium text-gray-700 mb-1">
                    Part Name <span class="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    id="partSearch"
                    v-model="partSearchQuery"
                    @input="searchInventory"
                    @focus="showDropdown = true"
                    @blur="handleBlur"
                    autocomplete="off"
                    class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="Search for a part..."
                  />

                  <!-- Loading indicator -->
                  <div v-if="isSearching" class="absolute right-3 top-9">
                    <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                  </div>

                  <!-- Dropdown Results -->
                  <div
                    v-if="showDropdown && (inventoryResults.length > 0 || partSearchQuery.length >= 2)"
                    class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-y-auto"
                  >
                    <div v-if="inventoryResults.length === 0 && partSearchQuery.length >= 2 && !isSearching" class="px-4 py-3 text-sm text-gray-500">
                      No parts found matching "{{ partSearchQuery }}"
                    </div>
                    <div
                      v-for="invItem in inventoryResults"
                      :key="invItem.id"
                      @mousedown.prevent="selectPart(invItem)"
                      class="px-4 py-3 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                    >
                      <div class="flex justify-between items-start">
                        <div>
                          <p class="text-sm font-medium text-gray-900">{{ invItem.description }}</p>
                          <p v-if="invItem.part_number" class="text-xs text-gray-500">Part #: {{ invItem.part_number }}</p>
                        </div>
                        <div class="text-right">
                          <p class="text-sm font-semibold text-green-600">${{ formatPrice(invItem.unit_price) }}</p>
                          <p class="text-xs text-gray-500">Qty: {{ invItem.quantity ?? 0 }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Selected Part Info -->
                <div v-if="selectedInventoryItem" class="bg-green-50 border border-green-200 rounded-md p-3">
                  <div class="flex justify-between items-center">
                    <div>
                      <p class="text-sm font-medium text-green-800">Selected: {{ selectedInventoryItem.description }}</p>
                      <p v-if="selectedInventoryItem.part_number" class="text-xs text-green-600">Part #: {{ selectedInventoryItem.part_number }}</p>
                    </div>
                    <button
                      type="button"
                      @click="clearSelectedPart"
                      class="text-green-600 hover:text-green-800"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label for="unitCost" class="block text-sm font-medium text-gray-700 mb-1">
                      Unit Cost <span class="text-red-500">*</span>
                    </label>
                    <input
                      type="number"
                      id="unitCost"
                      v-model.number="newPart.unit_cost"
                      step="0.01"
                      min="0"
                      class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="0.00"
                    />
                  </div>

                  <div>
                    <label for="quantity" class="block text-sm font-medium text-gray-700 mb-1">
                      Quantity <span class="text-red-500">*</span>
                    </label>
                    <input
                      type="number"
                      id="quantity"
                      v-model.number="newPart.quantity"
                      min="1"
                      class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="1"
                    />
                  </div>
                </div>

                <div class="flex justify-end">
                  <button
                    type="submit"
                    :disabled="isSubmitting"
                    class="px-6 py-2 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                  >
                    <span v-if="!isSubmitting">Add Part</span>
                    <span v-else>Adding...</span>
                  </button>
                </div>
              </form>
            </div>

            <!-- Add Service/Labour Form -->
            <div class="bg-purple-50 rounded-lg p-6">
              <h3 class="text-lg font-semibold text-gray-800 mb-4">Add Service / Labour</h3>
              <form @submit.prevent="addLabour" class="space-y-4">
                <div>
                  <label for="labourDescription" class="block text-sm font-medium text-gray-700 mb-1">
                    Description <span class="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    id="labourDescription"
                    v-model="newLabour.description"
                    class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="e.g., Brake pad replacement labour"
                  />
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label for="labourHours" class="block text-sm font-medium text-gray-700 mb-1">
                      Hours <span class="text-red-500">*</span>
                    </label>
                    <input
                      type="number"
                      id="labourHours"
                      v-model.number="newLabour.hours"
                      step="0.5"
                      min="0.5"
                      class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      placeholder="1"
                    />
                  </div>

                  <div>
                    <label for="labourRate" class="block text-sm font-medium text-gray-700 mb-1">
                      Rate ($/hr) <span class="text-red-500">*</span>
                    </label>
                    <input
                      type="number"
                      id="labourRate"
                      v-model.number="newLabour.rate"
                      step="0.01"
                      min="0"
                      class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      placeholder="0.00"
                    />
                  </div>
                </div>

                <!-- Calculated total preview -->
                <div v-if="newLabour.hours && newLabour.rate" class="text-sm text-gray-600">
                  Total: <span class="font-semibold text-gray-900">${{ (newLabour.hours * newLabour.rate).toFixed(2) }}</span>
                </div>

                <div class="flex justify-end">
                  <button
                    type="submit"
                    :disabled="isAddingLabour"
                    class="px-6 py-2 bg-purple-600 text-white font-semibold rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
                  >
                    <span v-if="!isAddingLabour">Add Service</span>
                    <span v-else>Adding...</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>

      <!-- Notes Section -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-4">Notes</h2>
        <ul v-if="notes.length > 0" class="space-y-2">
          <li v-for="note in notes" :key="note.id" class="p-3 bg-gray-50 rounded-md">
            <span class="inline-block px-2 py-1 text-xs font-semibold rounded-full mr-2"
                  :class="note.source === 'ai' ? 'bg-purple-200 text-purple-800' : 'bg-green-200 text-green-800'">
              {{ note.source }}
            </span>
            <span class="text-gray-700">{{ note.content }}</span>
          </li>
        </ul>
        <p v-else class="text-gray-600 text-center p-4 bg-gray-50 rounded-md">No notes available</p>
      </div>
      </div> <!-- End Details Tab Content -->

      <!-- Inspection Tab Content -->
      <div v-show="activeTab === 'inspection'">
        <WorkOrderInspection :work-order-id="route.params.id" />
      </div>

      <!-- Action Buttons -->
      <div class="flex justify-end space-x-4">
        <button
          v-if="workOrder.status === 'draft'"
          @click="startJob"
          class="px-6 py-3 bg-green-600 text-white font-semibold rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors"
        >
          Start Job
        </button>
        <button
          v-else-if="workOrder.status === 'in_progress'"
          @click="completeJob"
          class="px-6 py-3 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
        >
          Complete Job
        </button>
        <button
          @click="showNotifyModal = true"
          class="px-6 py-3 bg-purple-600 text-white font-semibold rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 transition-colors disabled:bg-purple-400"
        >
          Notify Customer
        </button>
        <!-- Print Invoice Button - always visible when there are line items -->
        <button
          v-if="allLineItems.length > 0"
          @click="printInvoice"
          :disabled="isPrinting"
          class="px-6 py-3 bg-gray-600 text-white font-semibold rounded-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-colors disabled:bg-gray-400"
        >
          {{ isPrinting ? 'Generating...' : 'Print Invoice' }}
        </button>
      </div>
    </div>

    <!-- Notification Modal -->
    <div v-if="showNotifyModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true" @click="showNotifyModal = false"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-purple-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">Confirm SMS Notification</h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500 mb-4">
                    Send the following customized message to the customer?
                  </p>
                  <div class="bg-gray-50 p-4 rounded-md border border-gray-200 text-sm text-gray-800 italic">
                    "Hi {{ customer?.name || 'Customer' }}, your {{ vehicle?.make }} {{ vehicle?.model }} is ready at Euro Motor Works! Total: ${{ grandTotal.toFixed(2) }}. See you soon."
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button 
              type="button" 
              class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-purple-600 text-base font-medium text-white hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 sm:ml-3 sm:w-auto sm:text-sm"
              @click="sendNotification"
              :disabled="isSending"
            >
              {{ isSending ? 'Sending...' : 'Send SMS ($0.10)' }}
            </button>
            <button 
              type="button" 
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
              @click="showNotifyModal = false"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div v-else class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="text-center">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      <p class="mt-4 text-lg text-gray-600">Loading...</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabaseClient.js'
import WorkOrderInspection from '@/components/work-orders/WorkOrderInspection.vue'

const route = useRoute()
const router = useRouter()
const activeTab = ref('details')
const workOrder = ref(null)
const items = ref([])
const labourItems = ref([])
const notes = ref([])
const isSubmitting = ref(false)
const isUpdatingStatus = ref(false)
const isAddingLabour = ref(false)
const showAddForms = ref(false)
const isPrinting = ref(false)
const isSending = ref(false)
const showNotifyModal = ref(false)
const businessSettings = ref(null)
const customer = ref(null)
const vehicle = ref(null)

// Rego Renewal / Pink Slip constants
const PINK_SLIP_FEE = 45.00
const PINK_SLIP_ITEM_NAME = 'eSafety Check (Pink Slip)'

// Inventory search state
const partSearchQuery = ref('')
const inventoryResults = ref([])
const isSearching = ref(false)
const showDropdown = ref(false)
const selectedInventoryItem = ref(null)
let searchTimeout = null

// Form data for new part
const newPart = ref({
  name: '',
  unit_cost: null,
  quantity: null
})

// Computed property for total parts cost
const totalPartsCost = computed(() => {
  return items.value.reduce((total, item) => {
    return total + (parseFloat(item.unit_cost) * item.quantity)
  }, 0)
})

// Computed property for total labour cost
const totalLabourCost = computed(() => {
  return labourItems.value.reduce((total, item) => {
    return total + parseFloat(item.total || 0)
  }, 0)
})

// Computed property combining parts and labour into unified line items
const allLineItems = computed(() => {
  const partItems = items.value.map(item => ({
    id: `part-${item.id}`,
    description: item.name,
    type: 'Part',
    quantity: item.quantity,
    unitPrice: parseFloat(item.unit_cost).toFixed(2),
    total: (parseFloat(item.unit_cost) * item.quantity).toFixed(2)
  }))

  const serviceItems = labourItems.value.map(item => ({
    id: `service-${item.id}`,
    description: item.description,
    type: 'Service',
    quantity: item.hours || null,
    unitPrice: item.rate ? parseFloat(item.rate).toFixed(2) : null,
    total: parseFloat(item.total).toFixed(2)
  }))

  return [...partItems, ...serviceItems]
})

// Grand total combining parts and labour
const grandTotal = computed(() => {
  return totalPartsCost.value + totalLabourCost.value
})

// Form data for new labour item (total is a generated column in DB)
const newLabour = ref({
  description: '',
  hours: null,
  rate: null
})

// Rego Renewal computed properties
const isRegoRenewal = computed(() => {
  return workOrder.value?.job_type === 'rego_renewal'
})

const statusClass = computed(() => {
  const status = workOrder.value?.status
  return {
    'text-yellow-600': status === 'draft',
    'text-blue-600': status === 'in_progress',
    'text-green-600': status === 'completed' || status === 'pink_slip_lodged',
    'text-orange-600': status === 'awaiting_inspection',
    'text-red-600': status === 'inspection_failed'
  }
})

const inspectionStatusBadgeClass = computed(() => {
  const status = workOrder.value?.status
  return {
    'bg-orange-100 text-orange-800': status === 'awaiting_inspection',
    'bg-red-100 text-red-800': status === 'inspection_failed',
    'bg-green-100 text-green-800': status === 'pink_slip_lodged'
  }
})

const inspectionStatusLabel = computed(() => {
  const status = workOrder.value?.status
  switch (status) {
    case 'awaiting_inspection': return 'Awaiting Inspection'
    case 'inspection_failed': return 'Failed'
    case 'pink_slip_lodged': return 'Passed'
    default: return status
  }
})

const formatStatus = (status) => {
  if (!status) return 'unknown'
  return status.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
}

const formatPrice = (price) => {
  if (price == null) return '0.00'
  return parseFloat(price).toFixed(2)
}

const searchInventory = () => {
  // Clear previous timeout
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }

  // Don't search if query is too short
  if (partSearchQuery.value.length < 2) {
    inventoryResults.value = []
    return
  }

  // Debounce the search
  searchTimeout = setTimeout(async () => {
    isSearching.value = true
    try {
      const query = partSearchQuery.value.toLowerCase()

      const { data, error } = await supabase
        .from('inventory')
        .select('*')
        .or(`description.ilike.%${query}%,part_number.ilike.%${query}%`)
        .order('description', { ascending: true })
        .limit(10)

      if (error) {
        console.error('Error searching inventory:', error)
        inventoryResults.value = []
      } else {
        inventoryResults.value = data || []
      }
    } catch (err) {
      console.error('Search error:', err)
      inventoryResults.value = []
    } finally {
      isSearching.value = false
    }
  }, 300)
}

const selectPart = (invItem) => {
  selectedInventoryItem.value = invItem
  partSearchQuery.value = invItem.description
  newPart.value.name = invItem.description
  newPart.value.unit_cost = invItem.unit_price || 0
  showDropdown.value = false
  inventoryResults.value = []
}

const clearSelectedPart = () => {
  selectedInventoryItem.value = null
  partSearchQuery.value = ''
  newPart.value.name = ''
  newPart.value.unit_cost = null
}

const handleBlur = () => {
  // Delay hiding dropdown to allow click events on dropdown items
  setTimeout(() => {
    showDropdown.value = false
  }, 200)
}

const fetchData = async () => {
  const id = route.params.id

  // Fetch work order with customer and vehicle details
  const { data: orderData, error: orderError } = await supabase
    .from('work_orders')
    .select(`
      *,
      customers (id, name, email, phone),
      vehicles (id, make, model, rego)
    `)
    .eq('id', id)
    .single()

  if (!orderError && orderData) {
    workOrder.value = orderData
    customer.value = orderData.customers
    vehicle.value = orderData.vehicles
  }

  // Fetch business settings
  const { data: settingsData } = await supabase
    .from('settings')
    .select('*')
    .limit(1)
    .single()
  businessSettings.value = settingsData

  // Fetch parts
  const { data: itemsData } = await supabase
    .from('work_order_items')
    .select('*')
    .eq('work_order_id', id)
  items.value = itemsData || []

  // Fetch labour items
  const { data: labourData } = await supabase
    .from('work_order_labour')
    .select('*')
    .eq('work_order_id', id)
  labourItems.value = labourData || []

  const { data: notesData } = await supabase
    .from('job_notes')
    .select('*')
    .eq('work_order_id', id)
  notes.value = notesData || []
}

const addPart = async () => {
  // Validation
  if (!newPart.value.name || newPart.value.name.trim() === '') {
    window.alert('Part name is required and cannot be empty')
    return
  }

  if (!newPart.value.quantity || newPart.value.quantity <= 0) {
    window.alert('Quantity must be a positive number')
    return
  }

  if (newPart.value.unit_cost === null || newPart.value.unit_cost === undefined || newPart.value.unit_cost < 0) {
    window.alert('Unit cost must be a valid number')
    return
  }

  isSubmitting.value = true

  try {
    // Insert new part into work_order_items table
    const { data, error } = await supabase
      .from('work_order_items')
      .insert({
        work_order_id: route.params.id,
        name: newPart.value.name.trim(),
        unit_cost: newPart.value.unit_cost,
        quantity: newPart.value.quantity
      })
      .select()

    if (error) {
      window.alert(`Error adding part: ${error.message}`)
      return
    }

    // Reset form
    newPart.value = {
      name: '',
      unit_cost: null,
      quantity: null
    }
    partSearchQuery.value = ''
    selectedInventoryItem.value = null
    inventoryResults.value = []

    // Refresh the parts list
    await fetchData()

  } catch (error) {
    window.alert(`Unexpected error: ${error.message}`)
  } finally {
    isSubmitting.value = false
  }
}

const addLabour = async () => {
  // Validation
  if (!newLabour.value.description || newLabour.value.description.trim() === '') {
    window.alert('Description is required')
    return
  }

  // Hours and rate are required since total is a generated column
  if (!newLabour.value.hours || newLabour.value.hours <= 0) {
    window.alert('Hours is required')
    return
  }

  if (!newLabour.value.rate || newLabour.value.rate <= 0) {
    window.alert('Rate is required')
    return
  }

  isAddingLabour.value = true

  try {
    // Note: total is a generated column (hours * rate), so we don't include it
    const { error } = await supabase
      .from('work_order_labour')
      .insert({
        work_order_id: route.params.id,
        description: newLabour.value.description.trim(),
        hours: newLabour.value.hours,
        rate: newLabour.value.rate
      })

    if (error) {
      window.alert(`Error adding labour: ${error.message}`)
      return
    }

    // Reset form
    newLabour.value = {
      description: '',
      hours: null,
      rate: null
    }

    // Refresh the labour list
    await fetchData()

  } catch (error) {
    window.alert(`Unexpected error: ${error.message}`)
  } finally {
    isAddingLabour.value = false
  }
}

const startJob = async () => {
  const id = workOrder.value.id
  const { error } = await supabase
    .from('work_orders')
    .update({ status: 'in_progress' })
    .eq('id', id)
  if (!error) {
    workOrder.value.status = 'in_progress'
  } else {
    window.alert(`Error starting job: ${error.message}`)
  }
}

const completeJob = async () => {
  const id = workOrder.value.id
  const { error } = await supabase
    .from('work_orders')
    .update({ status: 'completed', completed_at: new Date().toISOString() })
    .eq('id', id)
  if (!error) {
    workOrder.value.status = 'completed'
  } else {
    window.alert(`Error completing job: ${error.message}`)
  }
}

// Rego Renewal inspection handlers
const handleInspectionPass = async () => {
  if (!confirm('Confirm that the vehicle has PASSED the eSafety inspection?\n\nThis will issue the Pink Slip and add the inspection fee to the work order.')) {
    return
  }

  isUpdatingStatus.value = true
  try {
    // 1. Update status to pink_slip_lodged
    const { error: statusError } = await supabase
      .from('work_orders')
      .update({ status: 'pink_slip_lodged' })
      .eq('id', workOrder.value.id)

    if (statusError) throw statusError

    // 2. Add the Pink Slip fee as a LABOUR/SERVICE item (not a part)
    // Using hours=1 and rate=fee because total is a generated column
    const { error: labourError } = await supabase
      .from('work_order_labour')
      .insert({
        work_order_id: workOrder.value.id,
        description: PINK_SLIP_ITEM_NAME,
        hours: 1,
        rate: PINK_SLIP_FEE
      })

    if (labourError) throw labourError

    // 3. Refresh data to show updated status and labour items
    await fetchData()

  } catch (err) {
    window.alert(`Error processing inspection pass: ${err.message}`)
    console.error('Inspection pass error:', err)
  } finally {
    isUpdatingStatus.value = false
  }
}

const handleInspectionFail = async () => {
  if (!confirm('Confirm that the vehicle has FAILED the eSafety inspection?\n\nYou will need to add repair items and fix the issues before re-inspecting.')) {
    return
  }

  isUpdatingStatus.value = true
  try {
    const { error } = await supabase
      .from('work_orders')
      .update({ status: 'inspection_failed' })
      .eq('id', workOrder.value.id)

    if (error) throw error

    workOrder.value.status = 'inspection_failed'

  } catch (err) {
    window.alert(`Error processing inspection fail: ${err.message}`)
    console.error('Inspection fail error:', err)
  } finally {
    isUpdatingStatus.value = false
  }
}

const handleReInspect = async () => {
  if (!confirm('Ready to re-inspect the vehicle?\n\nThis will set the status back to "Awaiting Inspection".')) {
    return
  }

  isUpdatingStatus.value = true
  try {
    const { error } = await supabase
      .from('work_orders')
      .update({ status: 'awaiting_inspection' })
      .eq('id', workOrder.value.id)

    if (error) throw error

    workOrder.value.status = 'awaiting_inspection'

  } catch (err) {
    window.alert(`Error setting re-inspection: ${err.message}`)
    console.error('Re-inspect error:', err)
  } finally {
    isUpdatingStatus.value = false
  }
}

// Print Invoice function using jsPDF
const printInvoice = async () => {
  isPrinting.value = true

  try {
    // Dynamically import jsPDF and autoTable
    const jsPDFModule = await import('jspdf')
    const autoTableModule = await import('jspdf-autotable')

    const jsPDF = jsPDFModule.jsPDF
    const autoTable = autoTableModule.default

    const doc = new jsPDF()

    // Colors
    const primaryColor = [124, 58, 237] // Purple
    const textColor = [55, 65, 81] // Gray-700
    const lightGray = [107, 114, 128] // Gray-500

    // Get business info (fallback to defaults)
    const business = businessSettings.value || {}
    const businessName = business.business_name || 'Euro Motor Works'
    const businessAddress = business.address || ''
    const businessPhone = business.phone || ''
    const businessEmail = business.email || ''
    const businessABN = business.abn || ''
    const taxRate = business.tax_rate || 10

    // Invoice number based on work order ID
    const invoiceNumber = `INV-${workOrder.value.id.slice(0, 8).toUpperCase()}`
    const invoiceDate = new Date().toLocaleDateString('en-AU')

    // === HEADER - Business Info ===
    doc.setFontSize(24)
    doc.setTextColor(...primaryColor)
    doc.text(businessName, 20, 25)

    doc.setFontSize(10)
    doc.setTextColor(...textColor)
    let yPos = 32
    if (businessAddress) {
      doc.text(businessAddress, 20, yPos)
      yPos += 5
    }
    if (businessPhone) {
      doc.text(`Phone: ${businessPhone}`, 20, yPos)
      yPos += 5
    }
    if (businessEmail) {
      doc.text(`Email: ${businessEmail}`, 20, yPos)
      yPos += 5
    }
    if (businessABN) {
      doc.text(`ABN: ${businessABN}`, 20, yPos)
    }

    // === INVOICE NUMBER (Right side) ===
    doc.setFontSize(18)
    doc.setTextColor(...primaryColor)
    doc.text('TAX INVOICE', 140, 20)

    doc.setFontSize(12)
    doc.text(invoiceNumber, 140, 28)

    doc.setFontSize(10)
    doc.setTextColor(...textColor)
    doc.text(`Date: ${invoiceDate}`, 140, 36)
    doc.text(`Status: ${formatStatus(workOrder.value.status)}`, 140, 42)

    // === CUSTOMER INFO ===
    doc.setFontSize(12)
    doc.setTextColor(...primaryColor)
    doc.text('Bill To:', 20, 60)

    doc.setFontSize(10)
    doc.setTextColor(...textColor)
    yPos = 67
    if (customer.value?.name) {
      doc.setFont(undefined, 'bold')
      doc.text(customer.value.name, 20, yPos)
      doc.setFont(undefined, 'normal')
      yPos += 5
    }
    if (customer.value?.phone) {
      doc.text(`Phone: ${customer.value.phone}`, 20, yPos)
      yPos += 5
    }
    if (customer.value?.email) {
      doc.text(`Email: ${customer.value.email}`, 20, yPos)
    }

    // === VEHICLE INFO ===
    doc.setFontSize(12)
    doc.setTextColor(...primaryColor)
    doc.text('Vehicle:', 120, 60)

    doc.setFontSize(10)
    doc.setTextColor(...textColor)
    yPos = 67
    if (vehicle.value) {
      doc.text(`${vehicle.value.make || ''} ${vehicle.value.model || ''}`, 120, yPos)
      yPos += 5
      if (vehicle.value.rego) {
        doc.text(`Rego: ${vehicle.value.rego}`, 120, yPos)
      }
    }

    // === WORK ORDER SUMMARY ===
    if (workOrder.value.summary) {
      doc.setFontSize(10)
      doc.setTextColor(...lightGray)
      doc.text('Job Description:', 20, 95)
      doc.setTextColor(...textColor)
      const summaryLines = doc.splitTextToSize(workOrder.value.summary, 170)
      doc.text(summaryLines, 20, 101)
    }

    // === LINE ITEMS TABLE ===
    const tableData = allLineItems.value.map(item => [
      item.description,
      item.type,
      item.quantity || '-',
      item.unitPrice ? `$${item.unitPrice}` : '-',
      `$${item.total}`
    ])

    const tableResult = autoTable(doc, {
      startY: workOrder.value.summary ? 115 : 100,
      head: [['Description', 'Type', 'Qty', 'Unit Price', 'Total']],
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
        0: { cellWidth: 70 },
        1: { cellWidth: 25, halign: 'center' },
        2: { cellWidth: 20, halign: 'right' },
        3: { cellWidth: 30, halign: 'right' },
        4: { cellWidth: 30, halign: 'right', fontStyle: 'bold' }
      }
    })

    // === TOTALS ===
    const finalY = (tableResult?.finalY || doc.lastAutoTable?.finalY || 150) + 10
    const totalsX = 130

    // Subtotal
    const subtotal = grandTotal.value / (1 + taxRate / 100)
    const taxAmount = grandTotal.value - subtotal

    doc.setFontSize(10)
    doc.setTextColor(...textColor)
    doc.text('Subtotal:', totalsX, finalY)
    doc.text(`$${subtotal.toFixed(2)}`, 190, finalY, { align: 'right' })

    doc.text(`GST (${taxRate}%):`, totalsX, finalY + 7)
    doc.text(`$${taxAmount.toFixed(2)}`, 190, finalY + 7, { align: 'right' })

    doc.setFontSize(14)
    doc.setFont(undefined, 'bold')
    doc.setTextColor(...primaryColor)
    doc.text('Total:', totalsX, finalY + 18)
    doc.text(`$${grandTotal.value.toFixed(2)}`, 190, finalY + 18, { align: 'right' })

    // === FOOTER ===
    doc.setFontSize(9)
    doc.setFont(undefined, 'normal')
    doc.setTextColor(...lightGray)
    doc.text('Thank you for your business!', 105, 280, { align: 'center' })

    // Save the PDF
    doc.save(`${invoiceNumber}.pdf`)

  } catch (err) {
    console.error('Error generating invoice:', err)
    window.alert(`Error generating invoice: ${err.message}`)
  } finally {
    isPrinting.value = false
  }
}

onMounted(() => {
  fetchData()
})

const canNotify = computed(() => {
  if (!businessSettings.value?.enable_messaging) return false
  // Can notify if work order is 'completed' or maybe 'pink_slip_lodged' or just generally ready
  // User prompt said "Car Ready", usually implies status is done or at least in progress and completeable.
  // Let's allow it for In Progress, Completed, Pink Slip Lodged. Not Draft.
  const status = workOrder.value?.status
  return ['in_progress', 'completed', 'pink_slip_lodged', 'awaiting_inspection', 'inspection_failed'].includes(status)
})

const sendNotification = async () => {
  isSending.value = true
  try {
    // 1. Log simulation
    console.log('Sending SMS to', customer.value?.phone)
    console.log('Message:', `Hi ${customer.value?.name}, your ${vehicle.value?.make} ${vehicle.value?.model} is ready! Total: $${grandTotal.value.toFixed(2)}`)

    // 2. Add Job Note
    const { error } = await supabase
      .from('job_notes')
      .insert({
        work_order_id: workOrder.value.id,
        content: `SMS Sent: "Car Ready" notification sent to customer.`,
        source: 'manual' 
      })

    if (error) throw error

    // 3. UI Feedback
    showNotifyModal.value = false
    window.alert('SMS Notification simulated successfully!')
    
    // Refresh notes
    const { data: notesData } = await supabase
      .from('job_notes')
      .select('*')
      .eq('work_order_id', workOrder.value.id)
    notes.value = notesData || []

  } catch (err) {
    console.error('Error sending notification:', err)
    window.alert('Failed to simulate SMS.')
  } finally {
    isSending.value = false
  }
}
</script>
