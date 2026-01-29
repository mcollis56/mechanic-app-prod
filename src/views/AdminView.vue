<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';
import { useRouter } from 'vue-router';

const router = useRouter();
const users = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const savingUserId = ref(null);
const currentUser = ref(null);

const roles = ['admin', 'mechanic'];

const fetchCurrentUser = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      router.push('/');
      return false;
    }

    const { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (error) throw error;

    currentUser.value = profile;
    return true;
  } catch (err) {
    console.error('Error fetching current user:', err);
    errorMsg.value = `Failed to load user profile: ${err.message}`;
    return false;
  }
};

const fetchUsers = async () => {
  try {
    loading.value = true;
    errorMsg.value = '';

    const { data, error} = await supabase
      .from('profiles')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    users.value = data;
  } catch (err) {
    errorMsg.value = `Error fetching users: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const updateUserRole = async (user) => {
  if (user.id === currentUser.value?.id) {
    alert('You cannot change your own role.');
    return;
  }

  try {
    savingUserId.value = user.id;

    const { error } = await supabase
      .from('profiles')
      .update({ role: user.role })
      .eq('id', user.id);

    if (error) throw error;

    alert(`Successfully updated ${user.email || 'user'}'s role to ${user.role}`);
  } catch (err) {
    alert(`Error updating role: ${err.message}`);
    console.error('Error updating role:', err);
    // Revert the change in UI
    await fetchUsers();
  } finally {
    savingUserId.value = null;
  }
};

onMounted(async () => {
  await fetchCurrentUser();
  await fetchUsers();
});
</script>

<template>
  <div class="admin-view p-6">
    <header class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
          <p class="text-gray-600 mt-1">Manage users and application settings</p>
        </div>
      </div>
    </header>

    <!-- Admin Navigation -->
    <div class="mb-6 bg-white rounded-lg shadow p-2 flex gap-2">
      <RouterLink
        to="/admin"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
        :class="$route.path === '/admin'
          ? 'bg-purple-100 text-purple-700'
          : 'text-gray-600 hover:bg-gray-100'"
      >
        User Management
      </RouterLink>
      <RouterLink
        to="/admin/settings"
        class="px-4 py-2 rounded-md text-sm font-medium transition-colors"
        :class="$route.path === '/admin/settings'
          ? 'bg-purple-100 text-purple-700'
          : 'text-gray-600 hover:bg-gray-100'"
      >
        Business Settings
      </RouterLink>
    </div>

    <!-- User Management Section Title -->
    <div class="mb-4">
      <h2 class="text-xl font-semibold text-gray-900">User Management</h2>
      <p class="text-sm text-gray-600">Manage user roles and permissions</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center p-8">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      <p class="mt-2 text-gray-600">Loading users...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
      {{ errorMsg }}
    </div>

    <!-- Users Table -->
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Email
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Current Role
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="text-sm font-medium text-gray-900">
                  {{ user.email || 'No email' }}
                </div>
                <span
                  v-if="user.id === currentUser?.id"
                  class="ml-2 px-2 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-800"
                >
                  You
                </span>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span
                class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="{
                  'bg-red-100 text-red-800': user.role === 'admin',
                  'bg-blue-100 text-blue-800': user.role === 'mechanic',
                  'bg-gray-100 text-gray-800': !user.role
                }"
              >
                {{ user.role || 'No role' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm">
              <div class="flex items-center gap-2">
                <select
                  v-model="user.role"
                  :disabled="savingUserId === user.id || user.id === currentUser?.id"
                  class="block px-3 py-1 border border-gray-300 rounded-md focus:ring-purple-500 focus:border-purple-500"
                  :class="{ 'opacity-50 cursor-not-allowed': user.id === currentUser?.id }"
                >
                  <option v-for="role in roles" :key="role" :value="role">
                    {{ role }}
                  </option>
                </select>
                <button
                  @click="updateUserRole(user)"
                  :disabled="savingUserId === user.id || user.id === currentUser?.id"
                  class="px-4 py-1 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {{ savingUserId === user.id ? 'Saving...' : 'Save' }}
                </button>
              </div>
              <p v-if="user.id === currentUser?.id" class="mt-1 text-xs text-gray-500">
                Cannot change your own role
              </p>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Table Footer -->
      <div class="bg-gray-50 px-6 py-3 border-t border-gray-200">
        <p class="text-sm text-gray-700">
          Total: <span class="font-semibold">{{ users.length }}</span> user{{ users.length !== 1 ? 's' : '' }}
        </p>
      </div>
    </div>

    <!-- Info Box -->
    <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
      <h3 class="text-sm font-semibold text-blue-900 mb-2">Role Descriptions:</h3>
      <ul class="text-sm text-blue-800 space-y-1">
        <li><strong>Admin:</strong> Full access to all features including user management</li>
        <li><strong>Mechanic:</strong> Access to jobs, calendar, and customer management</li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
@keyframes spin {
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

select:focus {
  outline: none;
}
</style>
