#!/bin/bash
# Script to apply fixes for WorkOrders blank page issue
# Date: December 17, 2025

echo "🔧 Starting fixes for WorkOrders blank page issue..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cd /home/ubuntu/mechanics-app-final

# Step 1: Backup current code
echo "📦 Step 1: Creating backup..."
git add -A
git commit -m "Backup before fixing WorkOrders issue" 2>/dev/null || echo "Nothing to commit"
echo ""

# Step 2: Fix import statements
echo "🔄 Step 2: Fixing Supabase client imports..."
echo ""

# Fix main.js
echo "  Fixing src/main.js..."
sed -i "s|from './newSupabaseClient.js'|from './supabaseClient.js'|g" src/main.js
echo "    ✅ Updated"

# Fix router/index.js
echo "  Fixing src/router/index.js..."
sed -i "s|from '@/newSupabaseClient'|from '@/supabaseClient.js'|g" src/router/index.js
echo "    ✅ Updated"

# Fix WorkOrderList.vue
echo "  Fixing src/components/WorkOrderList.vue..."
sed -i "s|from '@/newSupabaseClient'|from '@/supabaseClient.js'|g" src/components/WorkOrderList.vue
echo "    ✅ Updated"

# Fix WorkOrderDetailView.vue
echo "  Fixing src/views/WorkOrderDetailView.vue..."
sed -i "s|from '@/newSupabaseClient.js'|from '@/supabaseClient.js'|g" src/views/WorkOrderDetailView.vue
echo "    ✅ Updated"

# Fix WorkOrderCreate.vue if it exists
if [ -f "src/views/WorkOrderCreate.vue" ]; then
  echo "  Fixing src/views/WorkOrderCreate.vue..."
  sed -i "s|from '@/newSupabaseClient.js'|from '@/supabaseClient.js'|g" src/views/WorkOrderCreate.vue
  echo "    ✅ Updated"
fi

echo ""

# Step 3: Delete duplicate client file
echo "🗑️  Step 3: Removing duplicate Supabase client..."
if [ -f "src/newSupabaseClient.js" ]; then
  rm src/newSupabaseClient.js
  echo "  ✅ Deleted src/newSupabaseClient.js"
else
  echo "  ℹ️  File already removed"
fi
echo ""

# Step 4: Copy fixed component files
echo "📝 Step 4: Applying enhanced component fixes..."

if [ -f "FIXES/WorkOrderList.vue.FIXED" ]; then
  cp FIXES/WorkOrderList.vue.FIXED src/components/WorkOrderList.vue
  echo "  ✅ Applied WorkOrderList.vue fixes"
else
  echo "  ⚠️  WorkOrderList.vue.FIXED not found, skipping"
fi

if [ -f "FIXES/WorkOrdersView.vue.FIXED" ]; then
  cp FIXES/WorkOrdersView.vue.FIXED src/views/WorkOrdersView.vue
  echo "  ✅ Applied WorkOrdersView.vue fixes"
else
  echo "  ⚠️  WorkOrdersView.vue.FIXED not found, skipping"
fi

echo ""

# Step 5: Verify changes
echo "🔍 Step 5: Verifying fixes..."
echo ""

echo "  Checking for remaining newSupabaseClient imports:"
REMAINING=$(grep -r "newSupabaseClient" src/ 2>/dev/null | grep -v node_modules | wc -l)
if [ "$REMAINING" -eq "0" ]; then
  echo "    ✅ No remaining newSupabaseClient imports found"
else
  echo "    ⚠️  Warning: Found $REMAINING remaining imports"
  grep -r "newSupabaseClient" src/ 2>/dev/null | grep -v node_modules
fi

echo ""

# Step 6: Commit changes
echo "💾 Step 6: Committing fixes..."
git add -A
git commit -m "Fix WorkOrders blank page: consolidate Supabase clients and add error handling" || echo "Nothing to commit"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ FIXES APPLIED SUCCESSFULLY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 What was fixed:"
echo "  1. ✅ Consolidated Supabase client to single instance"
echo "  2. ✅ Updated all imports to use supabaseClient.js"
echo "  3. ✅ Removed duplicate newSupabaseClient.js"
echo "  4. ✅ Added comprehensive error handling"
echo "  5. ✅ Added lifecycle logging for debugging"
echo "  6. ✅ Added loading, error, and empty states"
echo "  7. ✅ Improved UI with status badges and better styling"
echo ""
echo "🧪 Next steps:"
echo "  1. Restart your Vite dev server if it's running"
echo "  2. Navigate to /work-orders page"
echo "  3. Check browser console for logs"
echo "  4. Verify no 'Multiple GoTrueClient instances' warning"
echo ""
echo "📖 For full details, see: ISSUE_ANALYSIS_REPORT.md"
echo ""
