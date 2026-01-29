<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../supabaseClient.js';

import JobEditor from '@/components/JobEditor.vue';
import JobCard from '@/components/JobCard.vue';

const jobs = ref([]);
const loading = ref(true);
const errorMsg = ref('');
const showJobEditor = ref(false);
const selectedJob = ref(null);

// Define the columns for the Kanban board
const columns = ref([
  { key: 'Booking', title: 'Booking' },
  { key: 'In progress', title: 'In Progress' },
  { key: 'Awaiting parts', title: 'Awaiting Parts' },
  { key: 'Complete', title: 'Complete' }
]);

// Fetch all jobs from Supabase
const fetchJobs = async () => {
  try {
    loading.value = true;
    const { data, error } = await supabase
      .from('jobs')
      .select('*, customers(*), vehicles(*)'); // Fetch related data
    if (error) throw error;
    jobs.value = data;
  } catch (err) {
    errorMsg.value = `Error fetching jobs: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

// Computed properties to filter jobs for each column
const filteredJobs = (status) => {
  return computed(() => jobs.value.filter(job => job.status === status));
};

// Handle drag-and-drop to update job status
const handleDrop = async (newStatus, event) => {
  const jobId = event.dataTransfer.getData('jobId');
  if (!jobId) return;

  const jobToUpdate = jobs.value.find(j => j.id == jobId);
  if (jobToUpdate && jobToUpdate.status !== newStatus) {
    jobToUpdate.status = newStatus; // Optimistic update
    const { error } = await supabase
      .from('jobs')
      .update({ status: newStatus })
      .eq('id', jobId);
    if (error) {
      console.error('Failed to update job status:', error);
      fetchJobs(); // Revert on error
    }
  }
};

const handleDragStart = (job, event) => {
  event.dataTransfer.setData('jobId', job.id);
  event.dataTransfer.effectAllowed = 'move';
};


// Functions to open the editor for a new or existing job
const openJobEditor = (job = null) => {
  selectedJob.value = job ? { ...job } : {}; // Create a copy to avoid direct mutation
  showJobEditor.value = true;
};

// Function to handle the event after a job is saved
const handleJobSaved = () => {
  showJobEditor.value = false;
  fetchJobs(); // Refresh the list
};

onMounted(fetchJobs);
</script>

<template>
  <div class="page p-4">
    <header class="flex justify-between items-center mb-4">
      <h1 class="text-2xl font-bold">Jobs Board</h1>
      <div>
        <button @click="openJobEditor()" class="btn bg-purple-600 hover:bg-purple-700 text-white font-bold py-2 px-4 rounded">
          + New Job
        </button>
      </div>
    </header>

    <div v-if="loading" class="text-center p-8">Loading...</div>
    <div v-else-if="errorMsg" class="text-center p-8 text-red-500">{{ errorMsg }}</div>
    
    <!-- This is the Kanban Board Layout -->
    <div v-else class="board grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <div 
        v-for="col in columns" 
        :key="col.key" 
        class="column bg-gray-100 rounded-lg p-3"
        @dragover.prevent
        @dragenter.prevent
        @drop="handleDrop(col.key, $event)"
      >
        <h2 class="font-bold mb-3 text-lg">{{ col.title }}</h2>
        <div class="cards-container space-y-3">
          <JobCard
            v-for="job in filteredJobs(col.key).value"
            :key="job.id"
            :job="job"
            draggable="true"
            @dragstart="handleDragStart(job, $event)"
            @click="openJobEditor(job)"
          />
        </div>
      </div>
    </div>

    <!-- Job Editor Modal -->
    <JobEditor 
      v-model="showJobEditor" 
      :job="selectedJob" 
      @jobSaved="handleJobSaved" 
    />
  </div>
</template>

<style scoped>
.board {
  min-height: 80vh; /* Ensure columns take up space */
}
.column {
  min-height: 200px;
}
</style>
