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
        <div class="w-8 h-8 bg-indigo-600 rounded-md flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
        <span class="text-xl font-bold tracking-tight text-slate-900">MechanicApp</span>
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
            Stop Doing <br class="hidden lg:block" />
            Paperwork at Night.
          </h1>
          <p class="text-lg md:text-xl text-slate-600 mb-8 leading-relaxed">
            The all-in-one workshop manager that runs on your phone. Estimates, Inspections, and Invoices in one tap.
          </p>
          <div class="flex flex-col sm:flex-row gap-4">
            <button 
              @click="startTrial" 
              class="px-8 py-4 bg-indigo-600 text-white font-bold rounded-lg shadow-lg hover:bg-indigo-700 hover:shadow-xl transition-all transform hover:-translate-y-0.5 text-lg text-center"
            >
              Start Free Trial
            </button>
            <button 
              @click="navigateToLogin" 
              class="px-8 py-4 bg-white text-slate-700 font-semibold rounded-lg border border-slate-200 hover:bg-slate-50 hover:border-slate-300 transition-all text-lg text-center"
            >
              View Demo
            </button>
          </div>
          
          <div class="mt-8 flex items-center gap-4 text-sm text-slate-500">
            <div class="flex -space-x-2">
              <!-- Avatar Placeholders -->
              <div class="w-8 h-8 rounded-full bg-slate-200 border-2 border-white"></div>
              <div class="w-8 h-8 rounded-full bg-slate-300 border-2 border-white"></div>
              <div class="w-8 h-8 rounded-full bg-slate-400 border-2 border-white"></div>
            </div>
            <p>Trusted by 500+ Workshops</p>
          </div>
        </div>

        <!-- Right Visual (Placeholder) -->
        <div class="relative lg:h-full flex items-center justify-center">
          <!-- Main Image Container -->
          <div class="relative w-full aspect-[4/3] bg-slate-100 rounded-2xl overflow-hidden shadow-2xl border border-slate-200">
            <!-- Simulated App UI Abstract Representation -->
            <div class="absolute inset-0 bg-gradient-to-br from-slate-50 to-slate-100 p-8 flex flex-col justify-center items-center">
              
              <!-- Abstract UI Card -->
              <div class="w-full max-w-sm bg-white rounded-xl shadow-lg p-6 mb-4 transform rotate-[-2deg] hover:rotate-0 transition-transform duration-500">
                <div class="flex justify-between items-center mb-4">
                  <div class="h-4 w-24 bg-slate-200 rounded"></div>
                  <div class="h-6 w-16 bg-green-100 rounded-full flex items-center justify-center">
                    <div class="h-3 w-10 bg-green-500 rounded-full opacity-50"></div>
                  </div>
                </div>
                <div class="space-y-3">
                  <div class="h-3 w-full bg-slate-100 rounded"></div>
                  <div class="h-3 w-3/4 bg-slate-100 rounded"></div>
                  <div class="h-12 w-full bg-slate-50 rounded border border-dashed border-slate-200 mt-4 flex items-center justify-center text-slate-300 text-xs">
                    Vehicle Photo
                  </div>
                </div>
              </div>

              <!-- Floating Badge -->
              <div class="absolute bottom-10 right-10 bg-white p-4 rounded-lg shadow-xl border border-slate-100 transform translate-y-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 bg-indigo-100 rounded-full flex items-center justify-center text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs text-slate-500 uppercase font-bold tracking-wider">Invoice Sent</p>
                    <p class="text-lg font-bold text-slate-900">$1,240.00</p>
                  </div>
                </div>
              </div>

            </div>
          </div>
          
          <!-- Decorative Background Elements -->
          <div class="absolute -z-10 top-10 right-10 w-64 h-64 bg-indigo-100 rounded-full blur-3xl opacity-50 mix-blend-multiply filter"></div>
          <div class="absolute -z-10 bottom-10 left-10 w-64 h-64 bg-blue-100 rounded-full blur-3xl opacity-50 mix-blend-multiply filter"></div>
        </div>

      </div>
    </main>

    <!-- Simple Features Grid (Optional polish) -->
    <section class="max-w-7xl mx-auto px-6 py-16 border-t border-slate-100">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="p-6 bg-slate-50 rounded-xl">
          <div class="w-12 h-12 bg-white rounded-lg shadow-sm flex items-center justify-center mb-4 text-indigo-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Digital Estimates</h3>
          <p class="text-slate-600">Create professional quotes in seconds and send them via SMS for instant approval.</p>
        </div>
        <div class="p-6 bg-slate-50 rounded-xl">
          <div class="w-12 h-12 bg-white rounded-lg shadow-sm flex items-center justify-center mb-4 text-indigo-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Visual Inspections</h3>
          <p class="text-slate-600">Build trust with photo-based inspections. Show customers exactly what needs fixing.</p>
        </div>
        <div class="p-6 bg-slate-50 rounded-xl">
          <div class="w-12 h-12 bg-white rounded-lg shadow-sm flex items-center justify-center mb-4 text-indigo-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Fast Invoicing</h3>
          <p class="text-slate-600">Turn jobs into paid invoices with one click. Integrate with your accounting tools.</p>
        </div>
      </div>
    </section>
  </div>
</template>
