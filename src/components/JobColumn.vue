<script setup>
defineProps({
  title: String,
  items: Array
})

const emit = defineEmits(['send-invoice'])

function send(jobId) {
  emit('send-invoice', jobId)
}
</script>

<template>
  <div class="col">
    <div class="col-head">
      <strong>{{ title }}</strong>
      <span class="count">{{ items.length }}</span>
    </div>

    <div class="cards">
      <div v-for="j in items" :key="j.id" class="card">
        <div class="line">
          <strong>{{ j.customer_name || '—' }}</strong>
          <span> · {{ j.rego || '—' }}</span>
        </div>
        <div class="line dim">{{ j.vehicle_make_model || '' }}</div>
        <div class="line">{{ j.problem_description || '' }}</div>

        <!-- Only show in Complete -->
        <div class="actions" v-if="title === 'Complete'">
          <button class="primary" @click="send(j.id)">Send invoice</button>
        </div>
      </div>

      <div v-if="!items.length" class="empty">No jobs</div>
    </div>
  </div>
</template>

<style scoped>
.col { background:#fff; border:1px solid #eee; border-radius:12px; padding:12px; min-height:200px; }
.col-head { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;}
.count { background:#f2f3f5; border-radius:10px; padding:2px 8px; font-size:12px; }
.cards { display:flex; flex-direction:column; gap:10px; }
.card { border:1px solid #eee; border-radius:10px; padding:10px; }
.line { margin:2px 0; }
.dim { color:#666; font-size:12px; }
.actions { margin-top:8px; display:flex; gap:8px; }
.primary { background:#2d6cdf; color:#fff; border:none; padding:8px 12px; border-radius:8px; cursor:pointer; }
.empty { color:#888; font-size:12px; text-align:center; padding:8px 0; }
</style>
