<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../supabaseClient.js';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';
import JobEditor from '../components/JobEditor.vue';

const loading = ref(true);
const errorMsg = ref('');
const showJobEditor = ref(false);
const selectedJob = ref(null);
const selectedDate = ref(null);

const handleEventClick = (info) => {
  const job = info.event.extendedProps.job;
  selectedJob.value = { ...job };
  selectedDate.value = null;
  showJobEditor.value = true;
};

const handleDateClick = (info) => {
  selectedDate.value = info.dateStr;
  selectedJob.value = { due_date: info.dateStr, status: 'Booking' };
  showJobEditor.value = true;
};

const calendarOptions = ref({
  plugins: [dayGridPlugin, interactionPlugin],
  initialView: 'dayGridMonth',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,dayGridWeek'
  },
  events: [],
  editable: true,
  selectable: true,
  selectMirror: true,
  dayMaxEvents: true,
  weekends: true,
  eventClick: handleEventClick,
  dateClick: handleDateClick
});

const fetchJobs = async () => {
  try {
    loading.value = true;
    const { data, error } = await supabase
      .from('jobs')
      .select('*, customers(*), vehicles(*)')
      .not('due_date', 'is', null);

    if (error) throw error;

    // Transform jobs into FullCalendar events
    calendarOptions.value.events = data.map(job => ({
      id: job.id,
      title: `${job.problem_description || 'Untitled'} - ${job.customers?.name || 'No customer'}`,
      date: job.due_date,
      backgroundColor: getStatusColor(job.status),
      borderColor: getStatusColor(job.status),
      extendedProps: {
        job: job
      }
    }));
  } catch (err) {
    errorMsg.value = `Error fetching jobs: ${err.message}`;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const getStatusColor = (status) => {
  const colors = {
    'Booking': '#9333ea',
    'In progress': '#3b82f6',
    'Awaiting parts': '#f59e0b',
    'Complete': '#10b981'
  };
  return colors[status] || '#6b7280';
};

const handleJobSaved = () => {
  showJobEditor.value = false;
  selectedJob.value = null;
  selectedDate.value = null;
  fetchJobs();
};

onMounted(fetchJobs);
</script>

<template>
  <div class="calendar-view p-4">
    <header class="mb-6">
      <h1 class="text-2xl font-bold">Jobs Calendar</h1>
    </header>

    <div v-if="loading" class="text-center p-8">Loading calendar...</div>
    <div v-else-if="errorMsg" class="text-center p-8 text-red-500">{{ errorMsg }}</div>

    <div v-else class="calendar-container bg-white p-4 rounded-lg shadow">
      <FullCalendar :options="calendarOptions" />
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
.calendar-container {
  max-width: 1200px;
  margin: 0 auto;
}

/* FullCalendar styling customization */
:deep(.fc) {
  font-family: inherit;
}

:deep(.fc-toolbar-title) {
  font-size: 1.5rem;
  font-weight: bold;
}

:deep(.fc-button) {
  background-color: #9333ea;
  border-color: #9333ea;
  text-transform: capitalize;
}

:deep(.fc-button:hover) {
  background-color: #7e22ce;
  border-color: #7e22ce;
}

:deep(.fc-button-active) {
  background-color: #6b21a8 !important;
  border-color: #6b21a8 !important;
}

:deep(.fc-event) {
  cursor: pointer;
}
</style>
