<script setup>
import { ref, computed } from 'vue';
import { useAI } from '@/services/aiService.js';

const props = defineProps({
  technicianNotes: {
    type: String,
    required: true
  },
  context: {
    type: Object,
    default: () => ({})
  }
});

const emit = defineEmits(['notesEnhanced']);

const { aiService, isAIAvailable } = useAI();

const enhancedNotes = ref('');
const isEnhancing = ref(false);
const error = ref('');
const showEnhanced = ref(false);

const canEnhance = computed(() => {
  return isAIAvailable && props.technicianNotes && props.technicianNotes.trim().length > 0;
});

const enhanceNotes = async () => {
  if (!canEnhance.value) return;

  try {
    isEnhancing.value = true;
    error.value = '';
    
    enhancedNotes.value = await aiService.enhanceNotes(
      props.technicianNotes,
      props.context
    );
    
    showEnhanced.value = true;
  } catch (err) {
    error.value = err.message;
    console.error('Note enhancement error:', err);
  } finally {
    isEnhancing.value = false;
  }
};

const useEnhancedNotes = () => {
  emit('notesEnhanced', enhancedNotes.value);
  showEnhanced.value = false;
};

const editEnhancedNotes = () => {
  // Allow editing of enhanced notes
  const textarea = document.getElementById('enhanced-notes-textarea');
  if (textarea) {
    textarea.focus();
  }
};

const cancelEnhancement = () => {
  showEnhanced.value = false;
  enhancedNotes.value = '';
  error.value = '';
};
</script>

<template>
  <div class="ai-notes-enhancer">
    <!-- AI Not Available Warning -->
    <div v-if="!isAIAvailable" class="warning-box">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
      <span>AI enhancement is not configured. Please add API keys to your .env file.</span>
    </div>

    <!-- Enhance Button -->
    <div v-else-if="!showEnhanced" class="enhance-section">
      <button
        @click="enhanceNotes"
        :disabled="!canEnhance || isEnhancing"
        class="enhance-btn"
        type="button"
      >
        <svg v-if="!isEnhancing" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        <svg v-else class="w-5 h-5 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        <span>{{ isEnhancing ? 'Enhancing with AI...' : 'Enhance with AI' }}</span>
      </button>
      <p class="hint-text">Convert technician notes to customer-friendly language</p>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-box">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>{{ error }}</span>
    </div>

    <!-- Enhanced Notes Display -->
    <div v-if="showEnhanced && enhancedNotes" class="enhanced-display">
      <div class="enhanced-header">
        <h4 class="enhanced-title">AI-Enhanced Customer Notes</h4>
        <span class="ai-badge">✨ AI Generated</span>
      </div>

      <div class="enhanced-content">
        <textarea
          id="enhanced-notes-textarea"
          v-model="enhancedNotes"
          rows="6"
          class="enhanced-textarea"
          placeholder="AI-enhanced notes will appear here..."
        ></textarea>
        <p class="edit-hint">You can edit these notes before using them</p>
      </div>

      <div class="enhanced-actions">
        <button @click="cancelEnhancement" class="btn-secondary" type="button">
          Cancel
        </button>
        <button @click="editEnhancedNotes" class="btn-secondary" type="button">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
          </svg>
          Edit
        </button>
        <button @click="useEnhancedNotes" class="btn-primary" type="button">
          Use These Notes
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ai-notes-enhancer {
  margin-top: 0.5rem;
}

.warning-box {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #fef3c7;
  border: 1px solid #fbbf24;
  border-radius: 6px;
  color: #92400e;
  font-size: 0.875rem;
}

.enhance-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.enhance-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  background: linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%);
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  align-self: flex-start;
}

.enhance-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #6d28d9 0%, #4c1d95 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 6px rgba(124, 58, 237, 0.3);
}

.enhance-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.hint-text {
  font-size: 0.75rem;
  color: #6b7280;
  font-style: italic;
}

.error-box {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #fee2e2;
  border: 1px solid #fecaca;
  border-radius: 6px;
  color: #991b1b;
  font-size: 0.875rem;
}

.enhanced-display {
  border: 2px solid #7c3aed;
  border-radius: 8px;
  padding: 1rem;
  background: #faf5ff;
}

.enhanced-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.enhanced-title {
  font-weight: 600;
  color: #5b21b6;
}

.ai-badge {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
  background: #7c3aed;
  color: white;
  border-radius: 4px;
  font-weight: 600;
}

.enhanced-content {
  margin-bottom: 1rem;
}

.enhanced-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.875rem;
  line-height: 1.5;
  resize: vertical;
  background: white;
}

.enhanced-textarea:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.edit-hint {
  font-size: 0.75rem;
  color: #6b7280;
  margin-top: 0.5rem;
  font-style: italic;
}

.enhanced-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-primary {
  padding: 0.5rem 1rem;
  background: #7c3aed;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover {
  background: #6d28d9;
}

.btn-secondary {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.5rem 1rem;
  background: #f3f4f6;
  color: #374151;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.animate-spin {
  animation: spin 1s linear infinite;
}
</style>
