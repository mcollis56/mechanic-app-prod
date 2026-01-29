# Exact Code Changes Required

This document shows the EXACT line-by-line changes needed to fix the WorkOrders blank page issue.

---

## File 1: `src/main.js`

**Line 7 - CHANGE:**

```diff
- import { supabase } from './newSupabaseClient.js'; // Using our clean client
+ import { supabase } from './supabaseClient.js';
```

---

## File 2: `src/router/index.js`

**Line 2 - CHANGE:**

```diff
- import { supabase } from '@/newSupabaseClient' // adjust path if needed
+ import { supabase } from '@/supabaseClient.js'
```

---

## File 3: `src/components/WorkOrderList.vue`

**Line 41 - CHANGE:**

```diff
- import { supabase } from '@/newSupabaseClient' // adjust this path if your Supabase client lives elsewhere
+ import { supabase } from '@/supabaseClient.js'
```

**Lines 40-60 - ENHANCE (Optional but Recommended):**

Replace the script section with enhanced error handling:

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/supabaseClient.js'

const workOrders = ref([])
const loading = ref(true)
const error = ref(null)

const fetchWorkOrders = async () => {
  loading.value = true
  error.value = null
  
  try {
    console.log('🔄 Fetching work orders...')
    
    const { data, error: fetchError } = await supabase
      .from('work_orders')
      .select('*')
      .order('created_at', { ascending: false })

    if (fetchError) {
      console.error('❌ Error fetching work orders:', fetchError)
      throw fetchError
    }
    
    console.log('✅ Work orders fetched:', data?.length || 0, 'items')
    workOrders.value = data || []
  } catch (err) {
    console.error('❌ Unexpected error in fetchWorkOrders:', err)
    error.value = err
    workOrders.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  console.log('🚀 WorkOrderList component mounted')
  fetchWorkOrders()
})

onUnmounted(() => {
  console.log('👋 WorkOrderList component unmounted')
})
</script>
```

---

## File 4: `src/views/WorkOrderDetailView.vue`

**Line 175 - CHANGE:**

```diff
- import { supabase } from '@/newSupabaseClient.js'
+ import { supabase } from '@/supabaseClient.js'
```

---

## File 5: `src/views/WorkOrderCreate.vue`

**Find the import line (likely near top of script) - CHANGE:**

```diff
- import { supabase } from '@/newSupabaseClient.js'
+ import { supabase } from '@/supabaseClient.js'
```

---

## File 6: `src/views/WorkOrdersView.vue`

**REPLACE ENTIRE FILE (Optional but Recommended):**

```vue
<template>
  <div class="work-orders-view">
    <Suspense>
      <WorkOrderList />
      <template #fallback>
        <div class="loading">
          <div class="spinner"></div>
          <p>Loading work orders...</p>
        </div>
      </template>
    </Suspense>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, onErrorCaptured } from 'vue'
import WorkOrderList from '@/components/WorkOrderList.vue'

onMounted(() => {
  console.log('📄 WorkOrdersView mounted')
})

onUnmounted(() => {
  console.log('📄 WorkOrdersView unmounted')
})

onErrorCaptured((err, instance, info) => {
  console.error('❌ Error captured in WorkOrdersView:')
  console.error('  Error:', err)
  console.error('  Component info:', info)
  console.error('  Instance:', instance)
  return false
})
</script>

<style scoped>
.work-orders-view {
  padding: 1rem;
}

.loading {
  text-align: center;
  padding: 3rem;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading p {
  font-size: 1.1rem;
  color: #666;
}
</style>
```

---

## File 7: DELETE `src/newSupabaseClient.js`

**ACTION:** Remove this file entirely

```bash
rm src/newSupabaseClient.js
```

This file is a duplicate and causes the "Multiple GoTrueClient instances" warning.

---

## Summary of Changes

| File | Action | Line(s) | Change Type |
|------|--------|---------|-------------|
| `src/main.js` | Modify | 7 | Import fix |
| `src/router/index.js` | Modify | 2 | Import fix |
| `src/components/WorkOrderList.vue` | Modify | 41 | Import fix |
| `src/components/WorkOrderList.vue` | Enhance | 40-60 | Error handling (optional) |
| `src/views/WorkOrderDetailView.vue` | Modify | 175 | Import fix |
| `src/views/WorkOrderCreate.vue` | Modify | ~7 | Import fix |
| `src/views/WorkOrdersView.vue` | Replace | All | Add error boundary (optional) |
| `src/newSupabaseClient.js` | Delete | N/A | Remove duplicate |

---

## Minimum Changes Required (Core Fix)

If you only want the MINIMUM changes to fix the blank page:

1. **Change 5 import statements** (Files 1-5 above)
2. **Delete 1 file** (`src/newSupabaseClient.js`)

That's it! The page should work after these 6 changes.

---

## Recommended Changes (Full Fix)

For production-ready code with proper error handling:

1. **All minimum changes** (above)
2. **Enhance WorkOrderList.vue** with error handling
3. **Enhance WorkOrdersView.vue** with error boundary

---

## Automated Application

Instead of manual changes, run:

```bash
./FIXES/apply_fixes.sh
```

This applies ALL changes automatically (both minimum + recommended).

---

## Verification

After changes, verify with:

```bash
# Check no remaining newSupabaseClient imports
grep -r "newSupabaseClient" src/
# Should output: (nothing)

# Check file is deleted
ls src/newSupabaseClient.js
# Should output: No such file or directory
```

---

## Testing

1. Restart dev server
2. Navigate to `/work-orders`
3. Check console for:
   - ✅ "WorkOrdersView mounted"
   - ✅ "WorkOrderList component mounted"
   - ✅ "Work orders fetched: X items"
   - ❌ NO "Multiple GoTrueClient instances" warning

---

**Next Step**: Run `./FIXES/apply_fixes.sh` to apply all changes automatically.
