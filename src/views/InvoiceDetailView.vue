<script setup>
import { onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { supabase } from "@/supabase";

const route = useRoute();
const id = route.params.id;

const inv = ref(null);
const loading = ref(false);
const errorMsg = ref("");

async function load() {
  loading.value = true; errorMsg.value = "";
  const { data, error } = await supabase
    .from("invoices")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (error) errorMsg.value = error.message;
  inv.value = data || null;
  loading.value = false;
}

onMounted(load);
</script>

<template>
  <section class="page">
    <h2>Invoice</h2>

    <p v-if="errorMsg" class="err">{{ errorMsg }}</p>
    <div v-else-if="loading" class="loading">Loading…</div>

    <div v-else-if="inv" class="card">
      <p><strong>Invoice ID:</strong> <code>{{ inv.id }}</code></p>
      <p><strong>Job ID:</strong> <code>{{ inv.job_id }}</code></p>
      <p><strong>Status:</strong> {{ inv.status }}</p>
      <p><strong>Subtotal:</strong> {{ Number(inv.subtotal || 0).toFixed(2) }}</p>
      <p><strong>Tax:</strong> {{ Number(inv.tax || 0).toFixed(2) }}</p>
      <p><strong>Total:</strong> <strong>{{ Number(inv.total || 0).toFixed(2) }}</strong></p>
      <p><strong>Updated:</strong> {{ new Date(inv.updated_at).toLocaleString() }}</p>
    </div>

    <p v-else>No invoice found.</p>
  </section>
</template>

<style scoped>
.page { padding: 1.25rem; }
.card { border:1px solid #eee; border-radius:12px; padding:1rem; }
.err { color:#b00020; }
.loading { opacity:.7; }
</style>
