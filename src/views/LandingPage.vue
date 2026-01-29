<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const navigateToLogin = () => {
  router.push('/login')
}

const startTrial = () => {
  // For now, redirect to login or registration (using login for simplicity as per instructions)
  router.push('/login')
}
</script>

<template>
  <div class="min-h-screen bg-white font-sans text-slate-900">
    <!-- Navigation -->
    <nav class="flex items-center justify-between px-6 py-4 max-w-7xl mx-auto">
      <div class="flex items-center space-x-2">
        <!-- Simple Logo Icon -->
        <div class="w-8 h-8 bg-amber-400 rounded-md flex items-center justify-center shadow-sm">
          <span class="text-xl">🐵</span>
        </div>
        <span class="text-xl font-bold tracking-tight text-slate-900">MechanicMonkey</span>
      </div>
      <div>
        <button 
          @click="navigateToLogin" 
          class="text-sm font-semibold text-slate-600 hover:text-slate-900 transition-colors"
        >
          Login
        </button>
      </div>
    </nav>

    <!-- Hero Section -->
    <main class="max-w-7xl mx-auto px-6 py-16 md:py-24 lg:py-32">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
        
        <!-- Left Content -->
        <div class="max-w-2xl">
          <h1 class="text-4xl md:text-5xl lg:text-6xl font-extrabold tracking-tight text-slate-900 leading-tight mb-6">
            Quit Monkeying <br class="hidden lg:block" />
            Around with Paperwork.
          </h1>
          <p class="text-lg md:text-xl text-slate-600 mb-8 leading-relaxed">
            The simple app that handles inspections, invoices, and bookings while you fix cars.
          </p>
          <div class="flex flex-col sm:flex-row gap-4">
            <button 
              @click="startTrial" 
              class="px-8 py-4 bg-slate-900 text-white font-bold rounded-lg shadow-lg hover:bg-slate-800 hover:shadow-xl transition-all transform hover:-translate-y-0.5 text-lg text-center"
            >
              Start Free Trial
            </button>
            <button 
              @click="navigateToLogin" 
              class="px-8 py-4 bg-amber-50 text-slate-900 font-semibold rounded-lg border border-amber-200 hover:bg-amber-100 transition-all text-lg text-center"
            >
              View Demo
            </button>
          </div>
          
          <div class="mt-8 flex items-center gap-4 text-sm text-slate-500">
            <div class="flex -space-x-2">
              <!-- Avatar Placeholders -->
              <div class="w-8 h-8 rounded-full bg-amber-200 border-2 border-white"></div>
              <div class="w-8 h-8 rounded-full bg-slate-300 border-2 border-white"></div>
              <div class="w-8 h-8 rounded-full bg-amber-400 border-2 border-white"></div>
            </div>
            <p>Trusted by 500+ Workshops</p>
          </div>
        </div>

        <!-- Right Visual (Placeholder) -->
        <div class="relative lg:h-full flex items-center justify-center">
          <!-- Main Image Container -->
          <div class="relative w-full aspect-[4/3] bg-amber-50 rounded-2xl overflow-hidden shadow-2xl border border-amber-100">
            <div class="absolute inset-0 flex items-center justify-center">
               <!-- Abstract Monkey Mechanic Placeholder -->
               <div class="text-center">
                  <div class="text-9xl mb-4">🐵 🛠️</div>
                  <p class="text-lg font-bold text-amber-900 opacity-50 uppercase tracking-widest">Mechanic at Work</p>
               </div>
            </div>
            
            <!-- Simulated UI Element Overlay -->
            <div class="absolute bottom-10 right-10 bg-white p-4 rounded-lg shadow-xl border border-slate-100 transform translate-y-4 rotate-[-2deg]">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center text-green-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs text-slate-500 uppercase font-bold tracking-wider">Job Complete</p>
                    <p class="text-lg font-bold text-slate-900">Bananas Earned!</p>
                  </div>
                </div>
              </div>
          </div>
          
          <!-- Decorative Background Elements -->
          <div class="absolute -z-10 top-10 right-10 w-64 h-64 bg-amber-300 rounded-full blur-3xl opacity-30 mix-blend-multiply filter"></div>
          <div class="absolute -z-10 bottom-10 left-10 w-64 h-64 bg-yellow-200 rounded-full blur-3xl opacity-40 mix-blend-multiply filter"></div>
        </div>

      </div>
    </main>

    <!-- Simple Features Grid (Optional polish) -->
    <section class="max-w-7xl mx-auto px-6 py-16 border-t border-slate-100">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="p-6 bg-amber-50 rounded-xl border border-amber-100">
          <div class="w-12 h-12 bg-amber-400 rounded-lg shadow-sm flex items-center justify-center mb-4 text-slate-900 text-2xl">
            ⚡️
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Digital Estimates</h3>
          <p class="text-slate-600">Create professional quotes in seconds and send them via SMS for instant approval.</p>
        </div>
        <div class="p-6 bg-amber-50 rounded-xl border border-amber-100">
          <div class="w-12 h-12 bg-amber-400 rounded-lg shadow-sm flex items-center justify-center mb-4 text-slate-900 text-2xl">
            📷
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Visual Inspections</h3>
          <p class="text-slate-600">Build trust with photo-based inspections. Show customers exactly what needs fixing.</p>
        </div>
        <div class="p-6 bg-amber-50 rounded-xl border border-amber-100">
          <div class="w-12 h-12 bg-amber-400 rounded-lg shadow-sm flex items-center justify-center mb-4 text-slate-900 text-2xl">
            🍌
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Fast Invoicing</h3>
          <p class="text-slate-600">Turn jobs into paid invoices with one click. Simple enough for monkeys.</p>
        </div>
      </div>
    </section>
  </div>
</template>
