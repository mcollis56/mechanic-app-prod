<script setup lang="ts">
import { ref } from 'vue'

const URL = import.meta.env.VITE_SUPABASE_URL
const KEY = import.meta.env.VITE_SUPABASE_ANON_KEY

const agentQ = ref('')
const asking = ref(false)
const agentOut = ref<{ summary?: string; steps?: string[]; mode?: string; raw?: any } | null>(null)
const agentErr = ref<string | null>(null)

async function onAsk() {
  agentErr.value = null
  agentOut.value = null
  const q = agentQ.value.trim()
  if (!q) return

  asking.value = true
  try {
    const res = await fetch(`${URL}/functions/v1/agent`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': KEY,
        'Authorization': `Bearer ${KEY}`,
      },
      body: JSON.stringify({ question: q, limit: 15 }),
    })
    const text = await res.text()
    let json: any
    try { json = JSON.parse(text) } catch { json = { raw: text } }

    if (!res.ok) throw new Error(`${res.status} ${text}`)
    // expect either {mode:"ai", result:{summary,steps}} or {mode:"safe",reason:...}
    const mode = json.mode || (json.result ? 'ai' : 'unknown')
    const result = json.result || {}
    agentOut.value = { mode, summary: result.summary, steps: result.steps, raw: json }
    console.log('agent result:', json)
  } catch (e: any) {
    agentErr.value = e?.message || String(e)
    console.error('agent error:', e)
  } finally {
    asking.value = false
  }
}
</script>

<template>
  <div class="flex gap-2">
    <input v-model="agentQ" placeholder="Ask the shop assistant..." class="flex-1">
    <button :disabled="asking" @click="onAsk">{{ asking ? 'Thinking...' : 'Ask' }}</button>
  </div>

  <div v-if="agentErr" style="margin-top:8px;color:#b91c1c">Agent error: {{ agentErr }}</div>

  <div v-if="agentOut" style="margin-top:12px;border:1px solid #e5e7eb;border-radius:8px;padding:12px">
    <div style="font-weight:600;margin-bottom:6px">
      Agent • {{ agentOut.mode }}
    </div>
    <div v-if="agentOut.summary" style="margin-bottom:8px">{{ agentOut.summary }}</div>
    <ol v-if="agentOut.steps?.length" style="padding-left:18px">
      <li v-for="(s,i) in agentOut.steps" :key="i" style="margin:4px 0">{{ s }}</li>
    </ol>
  </div>
</template>
