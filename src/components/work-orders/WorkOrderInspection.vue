<template>
  <div class="space-y-6">
    <!-- Header / Stats -->
    <div v-if="inspection" class="bg-white rounded-lg shadow-md p-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl md:text-2xl font-bold text-gray-800">Vehicle Inspection</h2>
        <div class="flex space-x-2">
           <button
            @click="cleanSweep"
            :disabled="loading || items.length === 0"
            class="px-3 py-1 md:px-4 md:py-2 text-sm md:text-base bg-emerald-600 text-white font-semibold rounded-md hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-colors disabled:bg-gray-400"
            title="Mark all unchecked items as Green"
          >
            Clean Sweep
          </button>
        </div>
      </div>
      
      <div class="grid grid-cols-3 gap-2 md:gap-4 text-center">
        <div class="p-2 md:p-4 bg-emerald-200 rounded-lg border-2 border-emerald-300">
          <div class="text-xl md:text-3xl font-bold text-emerald-900">{{ greenCount }}</div>
          <div class="text-[10px] md:text-sm font-bold text-emerald-900 uppercase tracking-wide">Passed</div>
        </div>
        <div class="p-2 md:p-4 bg-amber-200 rounded-lg border-2 border-amber-300">
          <div class="text-xl md:text-3xl font-bold text-amber-900">{{ yellowCount }}</div>
          <div class="text-[10px] md:text-sm font-bold text-amber-900 uppercase tracking-wide">Attention</div>
        </div>
        <div class="p-2 md:p-4 bg-red-200 rounded-lg border-2 border-red-300">
          <div class="text-xl md:text-3xl font-bold text-red-900">{{ redCount }}</div>
          <div class="text-[10px] md:text-sm font-bold text-red-900 uppercase tracking-wide">Failed</div>
        </div>
      </div>
    </div>

    <!-- Start Inspection State -->
    <div v-if="!inspection && !loading" class="text-center py-12 bg-white rounded-lg shadow-md">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No Inspection Started</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by creating a new inspection checklist.</p>
      <div class="mt-6">
        <button
          @click="startInspection"
          type="button"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          Start Inspection
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>

    <!-- Inspection Items -->
    <div v-if="inspection && items.length > 0" class="bg-white rounded-lg shadow-md overflow-hidden">
      <div class="hidden md:grid p-4 bg-gray-50 border-b border-gray-200 text-sm font-medium text-gray-500 grid-cols-12 gap-4">
        <div class="col-span-6">Item</div>
        <div class="col-span-4 text-center">Status</div>
        <div class="col-span-2 text-center">Media</div>
      </div>
      
      <div class="divide-y divide-gray-200">
        <div v-for="item in items" :key="item.id" class="p-4 flex flex-col md:grid md:grid-cols-12 gap-4 items-center hover:bg-gray-50 transition-colors">
          <!-- Item Name -->
          <div class="w-full md:col-span-6 md:w-auto text-center md:text-left">
             <p class="font-medium text-gray-900 text-lg md:text-base">{{ item.inspection_template_items?.label || 'Unknown Item' }}</p>
             <p v-if="item.inspection_template_items?.category" class="text-xs text-gray-500">{{ item.inspection_template_items.category }}</p>
          </div>

          <!-- Status Toggles -->
          <div class="w-full md:col-span-4 flex justify-between md:justify-center px-4 md:px-0 gap-2 py-2 md:py-0">
            <button
              @click="updateStatus(item, 'green')"
              class="flex-1 md:flex-none h-10 md:h-9 px-3 rounded-lg md:rounded-full flex items-center justify-center transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500"
              :class="item.status === 'green' ? 'bg-emerald-600 text-white shadow-md scale-105 md:scale-110' : 'bg-gray-100 text-gray-700 hover:bg-emerald-100 hover:text-emerald-700'"
              title="Pass"
            >
              <span class="font-bold mr-2 text-xs md:text-xs uppercase">Pass</span>
              <svg class="w-5 h-5 md:w-4 md:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </button>
            <button
              @click="updateStatus(item, 'yellow')"
              class="flex-1 md:flex-none h-10 md:h-9 px-3 rounded-lg md:rounded-full flex items-center justify-center transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500"
              :class="item.status === 'yellow' ? 'bg-amber-500 text-white shadow-md scale-105 md:scale-110' : 'bg-gray-100 text-gray-700 hover:bg-amber-100 hover:text-amber-700'"
              title="Attention Needed"
            >
              <span class="font-bold mr-2 text-xs md:text-xs uppercase">Attn</span>
              <svg class="w-5 h-5 md:w-4 md:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </button>
            <button
              @click="updateStatus(item, 'red')"
              class="flex-1 md:flex-none h-10 md:h-9 px-3 rounded-lg md:rounded-full flex items-center justify-center transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-600"
              :class="item.status === 'red' ? 'bg-red-600 text-white shadow-md scale-105 md:scale-110' : 'bg-gray-100 text-gray-700 hover:bg-red-100 hover:text-red-700'"
              title="Fail"
            >
              <span class="font-bold mr-2 text-xs md:text-xs uppercase">Fail</span>
              <svg class="w-5 h-5 md:w-4 md:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Media Upload (Separated) -->
          <div class="w-full md:col-span-2 md:w-auto flex justify-center py-2 md:py-0 border-t md:border-t-0 md:border-l border-gray-100 mt-2 md:mt-0 pt-3 md:pt-0">
            <div class="relative">
              <input
                type="file"
                :id="`upload-${item.id}`"
                accept="image/*"
                class="hidden"
                @change="(e) => handlePhotoUpload(e, item)"
              />
              <label
                :for="`upload-${item.id}`"
                class="cursor-pointer inline-flex items-center justify-center w-10 h-10 rounded-full transition-colors"
                :class="item.media_url ? 'bg-blue-100 text-blue-600 hover:bg-blue-200' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'"
                title="Upload Photo"
              >
                <div v-if="uploadingId === item.id" class="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </label>
              <!-- Thumbnail preview if image exists -->
              <div v-if="item.media_url" class="absolute top-0 right-0 -mt-2 -mr-2 w-3 h-3 bg-blue-500 rounded-full border-2 border-white"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabaseClient.js'

const props = defineProps({
  workOrderId: {
    type: String,
    required: true
  }
})

const inspection = ref(null)
const items = ref([])
const loading = ref(true)
const uploadingId = ref(null)

// Computed stats
const greenCount = computed(() => items.value.filter(i => i.status === 'green').length)
const yellowCount = computed(() => items.value.filter(i => i.status === 'yellow').length)
const redCount = computed(() => items.value.filter(i => i.status === 'red').length)

onMounted(async () => {
  await fetchInspection()
})

const fetchInspection = async () => {
  loading.value = true
  try {
    // 1. Try to find existing inspection
    const { data: insp, error } = await supabase
      .from('inspections')
      .select('*')
      .eq('work_order_id', props.workOrderId)
      .single()

    if (error && error.code !== 'PGRST116') { // PGRST116 is "not found"
      console.error('Error fetching inspection:', error)
      return
    }

    if (insp) {
      inspection.value = insp
      await fetchItems(insp.id)
    }
  } catch (err) {
    console.error('Unexpected error:', err)
  } finally {
    loading.value = false
  }
}

const fetchItems = async (inspectionId) => {
  const { data, error } = await supabase
    .from('inspection_items')
    .select('*, inspection_template_items(label, category)')
    .eq('inspection_id', inspectionId)
    .order('id')

  if (error) {
    console.error('Error fetching items:', error)
  } else {
    items.value = data || []
  }
}

const startInspection = async () => {
  loading.value = true
  try {
    // 1. Create Inspection Record
    const { data: newInsp, error: inspError } = await supabase
      .from('inspections')
      .insert({
        work_order_id: props.workOrderId,
        status: 'in_progress'
      })
      .select()
      .single()

    if (inspError) throw inspError

    inspection.value = newInsp

    // 2. Fetch Template Items to Create Inspection Items
    // We get all items from the default template (or just all template items if there's only one set)
    // NOTE: This assumes we want all available template items.
    const { data: templateItems, error: tError } = await supabase
      .from('inspection_template_items')
      .select('id')
      
    if (tError) throw tError
    
    if (!templateItems || templateItems.length === 0) {
      throw new Error('No inspection template items found to initialize inspection.')
    }

    // Insert items linked to the template items
    const itemsPayload = templateItems.map(t => ({
      inspection_id: newInsp.id,
      template_item_id: t.id,
      status: 'green' 
    }))

    const { error: itemsError } = await supabase
      .from('inspection_items')
      .insert(itemsPayload)

    if (itemsError) throw itemsError

    await fetchItems(newInsp.id)

  } catch (err) {
    console.error('Error starting inspection:', err)
    window.alert(`Failed to start inspection: ${err.message}`)
  } finally {
    loading.value = false
  }
}

const updateStatus = async (item, status) => {
  // Optimistic update
  const originalStatus = item.status
  item.status = status

  try {
    const { error } = await supabase
      .from('inspection_items')
      .update({ status: status })
      .eq('id', item.id)

    if (error) throw error
  } catch (err) {
    console.error('Error updating item:', err)
    item.status = originalStatus // Revert
  }
}

const cleanSweep = async () => {
  const uncheckedItems = items.value.filter(i => !i.status)
  if (uncheckedItems.length === 0) return

  loading.value = true
  
  // Optimistic update all
  uncheckedItems.forEach(i => i.status = 'green')

  try {
    const { error } = await supabase
      .from('inspection_items')
      .update({ status: 'green' })
      .eq('inspection_id', inspection.value.id)
      .is('status', null)

    if (error) throw error
    
    await fetchItems(inspection.value.id)

  } catch (err) {
    console.error('Clean sweep error:', err)
    await fetchItems(inspection.value.id)
  } finally {
    loading.value = false
  }
}

const handlePhotoUpload = async (event, item) => {
  const file = event.target.files[0]
  if (!file) return

  uploadingId.value = item.id
  
  try {
    const fileExt = file.name.split('.').pop()
    const fileName = `${props.workOrderId}/${item.id}/${Date.now()}.${fileExt}`
    const filePath = `${fileName}`

    // Upload
    const { error: uploadError } = await supabase.storage
      .from('inspection-media')
      .upload(filePath, file)

    if (uploadError) throw uploadError

    // Get Public URL
    const { data: { publicUrl } } = supabase.storage
      .from('inspection-media')
      .getPublicUrl(filePath)

    // Update item - using media_url now
    const { error: updateError } = await supabase
      .from('inspection_items')
      .update({ media_url: publicUrl })
      .eq('id', item.id)

    if (updateError) throw updateError

    item.media_url = publicUrl

  } catch (err) {
    console.error('Upload error:', err)
    window.alert('Failed to upload photo')
  } finally {
    uploadingId.value = null
    // Reset input
    event.target.value = ''
  }
}</script>
