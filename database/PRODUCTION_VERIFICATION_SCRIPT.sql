-- ============================================
-- PRODUCTION DATABASE VERIFICATION SCRIPT
-- ============================================
-- Euro Motor Works - Mechanic Shop Management System
-- 
-- Purpose: Verify database schema is production-ready
-- Run this in Supabase SQL Editor BEFORE deployment
-- 
-- Contact: Mark Collis (info@small-ai.com)
-- Date: January 5, 2026
-- Version: 1.1 (Fixed table_type error)
-- 
-- This script performs READ-ONLY checks and makes NO changes
-- ============================================

-- ============================================
-- SECTION 1: TABLE EXISTENCE CHECKS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 1: CHECKING TABLE EXISTENCE';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check for core tables
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers' AND table_schema = 'public')
        THEN '✅ customers table EXISTS'
        ELSE '❌ customers table MISSING - CRITICAL ERROR'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vehicles' AND table_schema = 'public')
        THEN '✅ vehicles table EXISTS'
        ELSE '❌ vehicles table MISSING - CRITICAL ERROR'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'work_orders' AND table_schema = 'public')
        THEN '✅ work_orders table EXISTS'
        ELSE '❌ work_orders table MISSING - CRITICAL ERROR'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
        THEN '✅ jobs table EXISTS'
        ELSE '⚠️  jobs table MISSING - Check if using work_orders instead'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'inspection_templates' AND table_schema = 'public')
        THEN '✅ inspection_templates table EXISTS'
        ELSE '⚠️  inspection_templates table MISSING - May not be implemented yet'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'invoices' AND table_schema = 'public')
        THEN '✅ invoices table EXISTS'
        ELSE '❌ invoices table MISSING - CRITICAL ERROR'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'service_history' AND table_schema = 'public')
        THEN '✅ service_history table EXISTS'
        ELSE '⚠️  service_history table MISSING - Check migrations'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'parts_usage' AND table_schema = 'public')
        THEN '✅ parts_usage table EXISTS'
        ELSE '⚠️  parts_usage table MISSING - Check migrations'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'suppliers' AND table_schema = 'public')
        THEN '✅ suppliers table EXISTS'
        ELSE '⚠️  suppliers table MISSING - Check migrations'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
        THEN '✅ profiles table EXISTS'
        ELSE '❌ profiles table MISSING - CRITICAL ERROR (needed for auth)'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs' AND table_schema = 'public')
        THEN '✅ audit_logs table EXISTS'
        ELSE '⚠️  audit_logs table MISSING - No audit trail available'
    END AS check_result;

-- Summary of table count
SELECT 
    '📊 TOTAL TABLES IN DATABASE: ' || COUNT(*)::TEXT AS summary
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';

-- ============================================
-- SECTION 2: ROW LEVEL SECURITY (RLS) CHECKS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 2: CHECKING ROW LEVEL SECURITY (RLS)';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check RLS on critical tables
SELECT 
    tablename AS table_name,
    CASE 
        WHEN rowsecurity = TRUE THEN '✅ RLS ENABLED'
        ELSE '❌ RLS DISABLED - SECURITY RISK!'
    END AS rls_status
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices', 'profiles', 'service_history', 'parts_usage', 'suppliers', 'audit_logs')
ORDER BY tablename;

-- Count tables without RLS
SELECT 
    '⚠️  TABLES WITHOUT RLS: ' || COUNT(*)::TEXT AS warning
FROM pg_tables
WHERE schemaname = 'public'
    AND rowsecurity = FALSE;

-- List all tables without RLS (if any)
SELECT 
    '❌ Table missing RLS: ' || tablename AS security_issue
FROM pg_tables
WHERE schemaname = 'public'
    AND rowsecurity = FALSE
ORDER BY tablename;

-- ============================================
-- SECTION 3: RLS POLICIES CHECK
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 3: CHECKING RLS POLICIES';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check for existence of RLS policies on key tables
SELECT 
    schemaname,
    tablename,
    policyname,
    CASE 
        WHEN cmd = 'SELECT' THEN '👁️  SELECT policy'
        WHEN cmd = 'INSERT' THEN '➕ INSERT policy'
        WHEN cmd = 'UPDATE' THEN '✏️  UPDATE policy'
        WHEN cmd = 'DELETE' THEN '🗑️  DELETE policy'
        ELSE cmd
    END AS policy_type,
    CASE 
        WHEN roles = '{public}' THEN '🌐 PUBLIC access'
        ELSE '🔒 Role-restricted'
    END AS access_level
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices', 'profiles')
ORDER BY tablename, cmd;

-- Count policies per table
SELECT 
    tablename,
    COUNT(*) AS policy_count,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ Good coverage (4+ policies)'
        WHEN COUNT(*) >= 2 THEN '⚠️  Partial coverage (2-3 policies)'
        ELSE '❌ Insufficient coverage (<2 policies)'
    END AS assessment
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- SECTION 4: INDEX CHECKS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 4: CHECKING INDEXES';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check for indexes on work_orders foreign keys
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE tablename = 'work_orders' 
                AND indexdef LIKE '%customer_id%'
        )
        THEN '✅ Index exists on work_orders.customer_id'
        ELSE '❌ INDEX MISSING on work_orders.customer_id - PERFORMANCE ISSUE!'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE tablename = 'work_orders' 
                AND indexdef LIKE '%vehicle_id%'
        )
        THEN '✅ Index exists on work_orders.vehicle_id'
        ELSE '❌ INDEX MISSING on work_orders.vehicle_id - PERFORMANCE ISSUE!'
    END AS check_result;

-- If 'jobs' table exists, check its indexes too
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
        THEN
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM pg_indexes 
                    WHERE tablename = 'jobs' 
                        AND indexdef LIKE '%customer_id%'
                )
                THEN '✅ Index exists on jobs.customer_id'
                ELSE '❌ INDEX MISSING on jobs.customer_id - PERFORMANCE ISSUE!'
            END
        ELSE '⚠️  jobs table not found, skipping index check'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
        THEN
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM pg_indexes 
                    WHERE tablename = 'jobs' 
                        AND indexdef LIKE '%vehicle_id%'
                )
                THEN '✅ Index exists on jobs.vehicle_id'
                ELSE '❌ INDEX MISSING on jobs.vehicle_id - PERFORMANCE ISSUE!'
            END
        ELSE '⚠️  jobs table not found, skipping index check'
    END AS check_result;

-- Check for other critical indexes
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE tablename = 'vehicles' 
                AND indexdef LIKE '%customer_id%'
        )
        THEN '✅ Index exists on vehicles.customer_id'
        ELSE '⚠️  Index missing on vehicles.customer_id'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE tablename = 'vehicles' 
                AND indexdef LIKE '%vin%'
        )
        THEN '✅ Index exists on vehicles.vin'
        ELSE '⚠️  Index missing on vehicles.vin - May impact search performance'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pg_indexes 
            WHERE tablename = 'service_history' 
                AND indexdef LIKE '%vehicle_id%'
        )
        THEN '✅ Index exists on service_history.vehicle_id'
        ELSE '⚠️  Index missing on service_history.vehicle_id'
    END AS check_result;

-- List ALL indexes on public schema tables
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Count total indexes
SELECT 
    '📊 TOTAL INDEXES: ' || COUNT(*)::TEXT AS summary
FROM pg_indexes
WHERE schemaname = 'public';

-- ============================================
-- SECTION 5: FOREIGN KEY CONSTRAINTS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 5: CHECKING FOREIGN KEY CONSTRAINTS';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- List all foreign key constraints
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    '✅ FK constraint exists' AS status
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- Count foreign keys
SELECT 
    '📊 TOTAL FOREIGN KEYS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';

-- ============================================
-- SECTION 6: COLUMN EXISTENCE CHECKS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 6: CHECKING CRITICAL COLUMNS';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check work_orders/jobs table structure
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name IN ('work_orders', 'jobs') 
                AND column_name = 'customer_id'
                AND table_schema = 'public'
        )
        THEN '✅ customer_id column exists in work_orders/jobs'
        ELSE '❌ customer_id column MISSING - CRITICAL ERROR!'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name IN ('work_orders', 'jobs') 
                AND column_name = 'vehicle_id'
                AND table_schema = 'public'
        )
        THEN '✅ vehicle_id column exists in work_orders/jobs'
        ELSE '❌ vehicle_id column MISSING - CRITICAL ERROR!'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name IN ('work_orders', 'jobs') 
                AND column_name = 'status'
                AND table_schema = 'public'
        )
        THEN '✅ status column exists in work_orders/jobs'
        ELSE '❌ status column MISSING - CRITICAL ERROR!'
    END AS check_result;

-- Check customers table
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'customers' 
                AND column_name = 'email'
                AND table_schema = 'public'
        )
        THEN '✅ email column exists in customers'
        ELSE '⚠️  email column missing in customers'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'customers' 
                AND column_name = 'phone'
                AND table_schema = 'public'
        )
        THEN '✅ phone column exists in customers'
        ELSE '⚠️  phone column missing in customers'
    END AS check_result;

-- Check vehicles table
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'vehicles' 
                AND column_name = 'vin'
                AND table_schema = 'public'
        )
        THEN '✅ vin column exists in vehicles'
        ELSE '⚠️  vin column missing in vehicles'
    END AS check_result;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'vehicles' 
                AND column_name = 'registration'
                AND table_schema = 'public'
        )
        THEN '✅ registration column exists in vehicles'
        ELSE '⚠️  registration column missing in vehicles'
    END AS check_result;

-- ============================================
-- SECTION 7: AUDIT LOG FUNCTIONALITY
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 7: CHECKING AUDIT LOG SETUP';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check if audit_logs table has required columns
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'audit_logs'
                AND table_schema = 'public'
        )
        THEN '✅ audit_logs table exists with ' || 
            (SELECT COUNT(*)::TEXT FROM information_schema.columns WHERE table_name = 'audit_logs' AND table_schema = 'public') || 
            ' columns'
        ELSE '❌ audit_logs table MISSING - No audit trail!'
    END AS check_result;

-- List audit_logs columns if table exists
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'audit_logs'
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- ============================================
-- SECTION 8: USER PROFILES & ROLES
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 8: CHECKING USER PROFILES';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Check profiles table structure
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'profiles' 
                AND column_name = 'role'
                AND table_schema = 'public'
        )
        THEN '✅ role column exists in profiles'
        ELSE '❌ role column MISSING in profiles - RBAC won''t work!'
    END AS check_result;

-- Count existing profiles
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
        THEN '📊 User profiles in database: ' || (SELECT COUNT(*)::TEXT FROM profiles)
        ELSE '⚠️  Cannot count profiles - table missing'
    END AS summary;

-- Check if admin user exists
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
        THEN
            CASE 
                WHEN EXISTS (SELECT 1 FROM profiles WHERE role = 'admin')
                THEN '✅ Admin user exists'
                ELSE '❌ NO ADMIN USER - You won''t be able to manage the system!'
            END
        ELSE '⚠️  Cannot check for admin - profiles table missing'
    END AS check_result;

-- ============================================
-- SECTION 9: DATABASE FUNCTIONS & TRIGGERS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 9: CHECKING TRIGGERS & FUNCTIONS';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- List all functions
SELECT 
    routine_name AS function_name,
    '✅ Function exists' AS status
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- Count functions
SELECT 
    '📊 TOTAL FUNCTIONS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION';

-- List all triggers
SELECT 
    trigger_name,
    event_object_table AS table_name,
    event_manipulation AS trigger_event,
    '✅ Trigger exists' AS status
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Count triggers
SELECT 
    '📊 TOTAL TRIGGERS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- Check for updated_at triggers on key tables
SELECT 
    t.table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.triggers 
            WHERE event_object_table = t.table_name
                AND trigger_name LIKE '%updated_at%'
        )
        THEN '✅ Has updated_at trigger'
        ELSE '⚠️  Missing updated_at trigger'
    END AS status
FROM information_schema.tables t
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND t.table_name IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices')
ORDER BY t.table_name;

-- ============================================
-- SECTION 10: FINAL SUMMARY & RECOMMENDATIONS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 10: FINAL SUMMARY';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- Overall database health summary
SELECT 
    '📊 DATABASE SUMMARY' AS section,
    '' AS details
UNION ALL
SELECT 
    '├─ Tables:', 
    (SELECT COUNT(*)::TEXT FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
UNION ALL
SELECT 
    '├─ Indexes:', 
    (SELECT COUNT(*)::TEXT FROM pg_indexes WHERE schemaname = 'public')
UNION ALL
SELECT 
    '├─ Foreign Keys:', 
    (SELECT COUNT(*)::TEXT FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public')
UNION ALL
SELECT 
    '├─ RLS Enabled Tables:', 
    (SELECT COUNT(*)::TEXT FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = TRUE)
UNION ALL
SELECT 
    '├─ RLS Policies:', 
    (SELECT COUNT(*)::TEXT FROM pg_policies WHERE schemaname = 'public')
UNION ALL
SELECT 
    '├─ Functions:', 
    (SELECT COUNT(*)::TEXT FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION')
UNION ALL
SELECT 
    '├─ Triggers:', 
    (SELECT COUNT(*)::TEXT FROM information_schema.triggers WHERE trigger_schema = 'public')
UNION ALL
SELECT 
    '└─ User Profiles:', 
    COALESCE((SELECT COUNT(*)::TEXT FROM profiles), '0 (table missing)');

-- Critical issues check
DO $$
DECLARE
    critical_issues INTEGER := 0;
    warnings INTEGER := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'PRODUCTION READINESS ASSESSMENT';
    RAISE NOTICE '================================================';
    
    -- Check critical tables
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers' AND table_schema = 'public') THEN
        critical_issues := critical_issues + 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vehicles' AND table_schema = 'public') THEN
        critical_issues := critical_issues + 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name IN ('work_orders', 'jobs') AND table_schema = 'public') THEN
        critical_issues := critical_issues + 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'invoices' AND table_schema = 'public') THEN
        critical_issues := critical_issues + 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN
        critical_issues := critical_issues + 1;
    END IF;
    
    -- Check RLS
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices') AND rowsecurity = FALSE) THEN
        critical_issues := critical_issues + 1;
    END IF;
    
    -- Check indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename IN ('work_orders', 'jobs') AND indexdef LIKE '%customer_id%') THEN
        warnings := warnings + 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename IN ('work_orders', 'jobs') AND indexdef LIKE '%vehicle_id%') THEN
        warnings := warnings + 1;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Critical Issues Found: %', critical_issues;
    RAISE NOTICE 'Warnings Found: %', warnings;
    RAISE NOTICE '';
    
    IF critical_issues = 0 AND warnings = 0 THEN
        RAISE NOTICE '✅ ✅ ✅ DATABASE IS PRODUCTION READY! ✅ ✅ ✅';
    ELSIF critical_issues = 0 THEN
        RAISE NOTICE '⚠️  DATABASE IS MOSTLY READY - Address % warning(s) before go-live', warnings;
    ELSE
        RAISE NOTICE '❌ DATABASE NOT READY - Fix % critical issue(s) before deployment!', critical_issues;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Review the detailed checks above for specific issues.';
    RAISE NOTICE '';
    RAISE NOTICE 'Contact: Mark Collis (info@small-ai.com)';
    RAISE NOTICE 'Date: January 5, 2026';
    RAISE NOTICE '================================================';
END $$;

-- End of verification script
