import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Singleton pattern: Create only if not already created
let supabaseInstance = null

function getSupabaseClient() {
  if (!supabaseInstance) {
    console.log('🔧 Creating new Supabase client instance')
    supabaseInstance = createClient(supabaseUrl, supabaseAnonKey)
  } else {
    console.log('♻️ Reusing existing Supabase client instance')
  }
  return supabaseInstance
}

export const supabase = getSupabaseClient()

// Prevent HMR from creating new instances
if (import.meta.hot) {
  import.meta.hot.accept(() => {
    console.log('🔥 HMR: Preserving Supabase client instance')
  })
}
