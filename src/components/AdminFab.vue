<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()
const go = () => router.push('/admin')
</script>

<template>
  <button class="admin-fab" title="Open Admin" @click="go">
    ⚙️
  </button>
</template>

<style scoped>
.admin-fab{
  position: fixed;
  right: 16px;
  bottom: 16px;
  width: 48px; height: 48px;
  border-radius: 999px;
  display:flex; align-items:center; justify-content:center;
  background: var(--primary, #2563eb);
  color: white;
  border: none;
  box-shadow: 0 6px 18px rgba(0,0,0,.15);
  cursor: pointer;
  font-size: 20px;
}
.admin-fab:hover{ filter: brightness(1.05); }
</style>
