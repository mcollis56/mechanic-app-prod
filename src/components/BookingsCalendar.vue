<script setup>
import { computed } from 'vue'

const props = defineProps({
  jobs: { type: Array, default: () => [] },
  weeks: { type: Number, default: 4 },
})

// Start of this week (Monday)
const today = new Date()
const start = new Date(today)
const dow = start.getDay() === 0 ? 7 : start.getDay() // Sun->7
start.setDate(start.getDate() - (dow - 1))

const days = computed(() => {
  const out = []
  const total = props.weeks * 7
  for (let i = 0; i < total; i++) {
    const d = new Date(start)
    d.setDate(start.getDate() + i)
    out.push(d)
  }
  return out
})

const keyOf = (d) => d.toISOString().slice(0, 10)

const jobsByDay = computed(() => {
  const map = {}
  for (const job of props.jobs || []) {
    const raw =
      job.booked_date || job.booked_at || job.due_date || job.created_at
    if (!raw) continue
    const k =
      typeof raw === 'string'
        ? raw.slice(0, 10)
        : new Date(raw).toISOString().slice(0, 10)
    ;(map[k] ||= []).push(job)
  }
  return map
})

const statusClass = (s) =>
  (s || '').toLowerCase().replace(/\s+/g, '-') // "In progress" -> "in-progress"
</script>

<template>
  <div class="cal-wrap">
    <div class="cal-grid">
      <div v-for="d in days" :key="keyOf(d)" class="cell">
        <div class="date">
          {{ d.toLocaleDateString(undefined, { weekday: 'short', day: 'numeric', month: 'short' }) }}
        </div>

        <div class="items">
          <template v-for="(job, i) in (jobsByDay[keyOf(d)] || [])" :key="job.id">
            <div v-if="i < 3" class="item" :title="job.problem_description || job.description || ''">
              <span class="dot" :class="statusClass(job.status)"></span>
              <span class="txt">
                {{ job.problem_description || job.description || 'Job' }}
                <span v-if="job.vehicle_rego || job.rego">— {{ job.vehicle_rego || job.rego }}</span>
              </span>
            </div>
          </template>

          <div
            v-if="(jobsByDay[keyOf(d)] || []).length > 3"
            class="more"
          >
            +{{ (jobsByDay[keyOf(d)] || []).length - 3 }} more…
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.cal-wrap { padding: 12px; background: #f8fafc; border-radius: 12px; }
.cal-grid { display: grid; grid-template-columns: repeat(7, minmax(0,1fr)); gap: 10px; }
.cell { background: #fff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 8px; min-height: 110px; }
.date { font-weight: 600; font-size: 13px; margin-bottom: 6px; color: #111827; }
.item { display: flex; align-items: center; gap: 6px; font-size: 12px; margin-bottom: 3px;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.dot { width: 8px; height: 8px; border-radius: 50%; background: #9ca3af; flex: 0 0 auto; }
.dot.complete { background: #10b981; }      /* green */
.dot.booking { background: #3b82f6; }       /* blue  */
.dot.in-progress { background: #f59e0b; }   /* amber */
.dot.awaiting-parts { background: #ef4444; }/* red   */
.more { font-size: 12px; color: #6b7280; }
</style>
