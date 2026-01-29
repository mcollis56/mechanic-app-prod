// main.js - FINAL VERSION (21-Oct)
// This file is the entry point for the entire application.

import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import { supabase } from './supabaseClient.js'; // Using our clean client

// Import Tailwind CSS - This is critical for styling
import './assets/main.css'; 

const app = createApp(App);

app.use(router);

// Make supabase available globally if needed, though direct import is better
app.config.globalProperties.$supabase = supabase;

app.mount('#app');
