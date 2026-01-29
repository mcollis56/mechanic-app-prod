<template>
  <teleport to="body">
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40" @click.self="$emit('close')">
      <div class="bg-white rounded-xl shadow-xl w-[680px] max-w-[92vw]">
        <div class="p-4 border-b flex items-center justify-between">
          <h3 class="m-0 text-lg">Job #{{ job?.id?.slice(0,8) }}</h3>
          <button class="button" @click="$emit('close')">Close</button>
        </div>

        <div class="p-4 space-y-10">
          <section>
            <div class="muted text-sm">Customer</div>
            <div class="text-base">{{ job?.customer_name || '—' }}</div>
          </section>

          <section>
            <div class="muted text-sm">Vehicle</div>
            <div class="text-base">{{ job?.vehicle_rego }} <span class="muted">•</span> {{ job?.vehicle_make_model }}</div>
          </section>

          <section>
            <div class="muted text-sm">Problem</div>
            <div class="text-base">{{ job?.problem_description || '—' }}</div>
          </section>

          <section>
            <div class="muted text-sm">Status</div>
            <select class="input" v-model="localStatus" @change="$emit('update-status', localStatus)">
              <option>Booking</option>
              <option>In progress</option>
              <option>Awaiting parts</option>
              <option>Complete</option>
            </select>
          </section>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import { watch, ref } from 'vue'

const props = defineProps({
  open: Boolean,
  job:  Object,
  status: String
})
defineEmits(['close', 'update-status'])

const localStatus = ref(props.status || 'Booking')
watch(() => props.status, s => { if (s) localStatus.value = s })
</script>

<style scoped>
.button{border:1px solid #d1d5db;background:#f9fafb;border-radius:10px;padding:6px 10px;cursor:pointer}
.muted{color:#6b7280}
.input{border:1px solid #e5e7eb;border-radius:10px;padding:8px 10px;background:#fff}
</style>
