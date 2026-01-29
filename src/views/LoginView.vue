<script setup>
import { ref } from 'vue';
import { supabase } from '../supabaseClient.js';
import { useRouter } from 'vue-router';

const router = useRouter();
const email = ref('');
const password = ref('');
const loading = ref(false);
const errorMsg = ref('');
const isSignup = ref(false);

const handleAuth = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    if (isSignup.value) {
      // Sign up
      const { data, error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
      });

      if (error) throw error;

      if (data.user) {
        // Create profile for new user
        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: data.user.id,
            email: data.user.email,
            role: 'mechanic' // Default role
          });

        if (profileError) throw profileError;

        alert('Account created successfully! You can now log in.');
        isSignup.value = false;
        password.value = '';
      }
    } else {
      // Sign in
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value,
      });

      if (error) throw error;

      if (data.user) {
        // Redirect to home
        router.push('/');
      }
    }
  } catch (err) {
    errorMsg.value = err.message;
    console.error('Auth error:', err);
  } finally {
    loading.value = false;
  }
};

const toggleMode = () => {
  isSignup.value = !isSignup.value;
  errorMsg.value = '';
};

const appName = import.meta.env.VITE_APP_NAME || 'Mechanic App';
</script>

<template>
  <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <h1 class="text-center text-3xl font-bold text-gray-900">{{ appName }}</h1>
      <h2 class="mt-6 text-center text-2xl font-semibold text-gray-700">
        {{ isSignup ? 'Create your account' : 'Sign in to your account' }}
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow rounded-lg sm:px-10">
        <!-- Error Message -->
        <div v-if="errorMsg" class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {{ errorMsg }}
        </div>

        <form @submit.prevent="handleAuth" class="space-y-6">
          <!-- Email -->
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <input
              id="email"
              type="email"
              v-model="email"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500"
            />
          </div>

          <!-- Password -->
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">
              Password
            </label>
            <input
              id="password"
              type="password"
              v-model="password"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-purple-500 focus:border-purple-500"
            />
          </div>

          <!-- Submit Button -->
          <div>
            <button
              type="submit"
              :disabled="loading"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {{ loading ? 'Processing...' : (isSignup ? 'Sign up' : 'Sign in') }}
            </button>
          </div>
        </form>

        <!-- Toggle Mode -->
        <div class="mt-6 text-center">
          <button
            @click="toggleMode"
            class="text-sm text-purple-600 hover:text-purple-500 transition-colors"
          >
            {{ isSignup ? 'Already have an account? Sign in' : "Don't have an account? Sign up" }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
input:focus {
  outline: none;
}
</style>
