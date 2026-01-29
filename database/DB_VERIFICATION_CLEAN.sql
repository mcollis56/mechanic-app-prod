-- ============================================
-- PRODUCTION DATABASE VERIFICATION SCRIPT
-- ============================================
-- Euro Motor Works - Mechanic Shop Management System
-- 
-- Contact: Mark Collis (info@small-ai.com)
-- Date: January 5, 2026
-- Version: 1.2 (Clean - No Syntax Errors)
-- 
-- READ-ONLY checks - Makes NO changes to database
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 1: TABLE EXISTENCE CHECKS';
    RAISE NOTICE '================================================';
END $$;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers' AND table_schema = 'public')
    THEN '✅ customers table EXISTS'
    ELSE '❌ customers table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vehicles' AND table_schema = 'public')
    THEN '✅ vehicles table EXISTS'
    ELSE '❌ vehicles table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'work_orders' AND table_schema = 'public')
    THEN '✅ work_orders table EXISTS'
    ELSE '❌ work_orders table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
    THEN '✅ jobs table EXISTS'
    ELSE '⚠️  jobs table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'inspection_templates' AND table_schema = 'public')
    THEN '✅ inspection_templates table EXISTS'
    ELSE '⚠️  inspection_templates table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'invoices' AND table_schema = 'public')
    THEN '✅ invoices table EXISTS'
    ELSE '❌ invoices table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'service_history' AND table_schema = 'public')
    THEN '✅ service_history table EXISTS'
    ELSE '⚠️  service_history table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'parts_usage' AND table_schema = 'public')
    THEN '✅ parts_usage table EXISTS'
    ELSE '⚠️  parts_usage table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'suppliers' AND table_schema = 'public')
    THEN '✅ suppliers table EXISTS'
    ELSE '⚠️  suppliers table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
    THEN '✅ profiles table EXISTS'
    ELSE '❌ profiles table MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs' AND table_schema = 'public')
    THEN '✅ audit_logs table EXISTS'
    ELSE '⚠️  audit_logs table MISSING'
END AS check_result;

SELECT '📊 TOTAL TABLES: ' || COUNT(*)::TEXT AS summary
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 2: ROW LEVEL SECURITY CHECKS';
    RAISE NOTICE '================================================';
END $$;

SELECT 
    tablename AS table_name,
    CASE WHEN rowsecurity = TRUE THEN '✅ RLS ENABLED' ELSE '❌ RLS DISABLED' END AS rls_status
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices', 'profiles')
ORDER BY tablename;

SELECT '⚠️  TABLES WITHOUT RLS: ' || COUNT(*)::TEXT AS warning
FROM pg_tables
WHERE schemaname = 'public' AND rowsecurity = FALSE;

SELECT '❌ Table missing RLS: ' || tablename AS security_issue
FROM pg_tables
WHERE schemaname = 'public' AND rowsecurity = FALSE
ORDER BY tablename;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 3: RLS POLICIES';
    RAISE NOTICE '================================================';
END $$;

SELECT 
    tablename,
    policyname,
    CASE 
        WHEN cmd = 'SELECT' THEN '👁️  SELECT'
        WHEN cmd = 'INSERT' THEN '➕ INSERT'
        WHEN cmd = 'UPDATE' THEN '✏️  UPDATE'
        WHEN cmd = 'DELETE' THEN '🗑️  DELETE'
        ELSE cmd
    END AS policy_type
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd;

SELECT 
    tablename,
    COUNT(*) AS policy_count,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ Good coverage'
        WHEN COUNT(*) >= 2 THEN '⚠️  Partial coverage'
        ELSE '❌ Insufficient'
    END AS assessment
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 4: INDEX CHECKS';
    RAISE NOTICE '================================================';
END $$;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'work_orders' AND indexdef LIKE '%customer_id%')
    THEN '✅ Index on work_orders.customer_id'
    ELSE '❌ MISSING INDEX: work_orders.customer_id'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'work_orders' AND indexdef LIKE '%vehicle_id%')
    THEN '✅ Index on work_orders.vehicle_id'
    ELSE '❌ MISSING INDEX: work_orders.vehicle_id'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
    THEN
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'jobs' AND indexdef LIKE '%customer_id%')
            THEN '✅ Index on jobs.customer_id'
            ELSE '❌ MISSING INDEX: jobs.customer_id'
        END
    ELSE '⚠️  jobs table not found'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'jobs' AND table_schema = 'public')
    THEN
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'jobs' AND indexdef LIKE '%vehicle_id%')
            THEN '✅ Index on jobs.vehicle_id'
            ELSE '❌ MISSING INDEX: jobs.vehicle_id'
        END
    ELSE '⚠️  jobs table not found'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'vehicles' AND indexdef LIKE '%customer_id%')
    THEN '✅ Index on vehicles.customer_id'
    ELSE '⚠️  Missing: vehicles.customer_id'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'vehicles' AND indexdef LIKE '%vin%')
    THEN '✅ Index on vehicles.vin'
    ELSE '⚠️  Missing: vehicles.vin'
END AS check_result;

SELECT '📊 TOTAL INDEXES: ' || COUNT(*)::TEXT AS summary
FROM pg_indexes WHERE schemaname = 'public';

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 5: FOREIGN KEY CONSTRAINTS';
    RAISE NOTICE '================================================';
END $$;

SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table,
    ccu.column_name AS foreign_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
ORDER BY tc.table_name;

SELECT '📊 TOTAL FOREIGN KEYS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public';

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 6: CRITICAL COLUMNS';
    RAISE NOTICE '================================================';
END $$;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name IN ('work_orders', 'jobs') AND column_name = 'customer_id' AND table_schema = 'public')
    THEN '✅ customer_id exists'
    ELSE '❌ customer_id MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name IN ('work_orders', 'jobs') AND column_name = 'vehicle_id' AND table_schema = 'public')
    THEN '✅ vehicle_id exists'
    ELSE '❌ vehicle_id MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name IN ('work_orders', 'jobs') AND column_name = 'status' AND table_schema = 'public')
    THEN '✅ status exists'
    ELSE '❌ status MISSING'
END AS check_result;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 7: USER PROFILES';
    RAISE NOTICE '================================================';
END $$;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role' AND table_schema = 'public')
    THEN '✅ role column exists'
    ELSE '❌ role column MISSING'
END AS check_result;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
    THEN '📊 Profiles: ' || (SELECT COUNT(*)::TEXT FROM profiles)
    ELSE '⚠️  profiles table missing'
END AS summary;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
    THEN
        CASE 
            WHEN EXISTS (SELECT 1 FROM profiles WHERE role = 'admin')
            THEN '✅ Admin user exists'
            ELSE '❌ NO ADMIN USER'
        END
    ELSE '⚠️  Cannot check admin'
END AS check_result;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SECTION 8: FUNCTIONS AND TRIGGERS';
    RAISE NOTICE '================================================';
END $$;

SELECT '📊 TOTAL FUNCTIONS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';

SELECT '📊 TOTAL TRIGGERS: ' || COUNT(*)::TEXT AS summary
FROM information_schema.triggers
WHERE trigger_schema = 'public';

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'FINAL SUMMARY';
    RAISE NOTICE '================================================';
END $$;

SELECT '📊 DATABASE SUMMARY' AS section, '' AS details
UNION ALL
SELECT '├─ Tables:', (SELECT COUNT(*)::TEXT FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
UNION ALL
SELECT '├─ Indexes:', (SELECT COUNT(*)::TEXT FROM pg_indexes WHERE schemaname = 'public')
UNION ALL
SELECT '├─ Foreign Keys:', (SELECT COUNT(*)::TEXT FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public')
UNION ALL
SELECT '├─ RLS Tables:', (SELECT COUNT(*)::TEXT FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = TRUE)
UNION ALL
SELECT '├─ Policies:', (SELECT COUNT(*)::TEXT FROM pg_policies WHERE schemaname = 'public')
UNION ALL
SELECT '└─ Profiles:', COALESCE((SELECT COUNT(*)::TEXT FROM profiles), '0');

DO $$
DECLARE
    critical INTEGER := 0;
    warnings INTEGER := 0;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers' AND table_schema = 'public') THEN critical := critical + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vehicles' AND table_schema = 'public') THEN critical := critical + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name IN ('work_orders', 'jobs') AND table_schema = 'public') THEN critical := critical + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'invoices' AND table_schema = 'public') THEN critical := critical + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN critical := critical + 1; END IF;
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('customers', 'vehicles', 'work_orders', 'jobs', 'invoices') AND rowsecurity = FALSE) THEN critical := critical + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename IN ('work_orders', 'jobs') AND indexdef LIKE '%customer_id%') THEN warnings := warnings + 1; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename IN ('work_orders', 'jobs') AND indexdef LIKE '%vehicle_id%') THEN warnings := warnings + 1; END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'PRODUCTION READINESS ASSESSMENT';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Critical Issues: %', critical;
    RAISE NOTICE 'Warnings: %', warnings;
    RAISE NOTICE '';
    
    IF critical = 0 AND warnings = 0 THEN
        RAISE NOTICE '✅ ✅ ✅ DATABASE IS PRODUCTION READY! ✅ ✅ ✅';
    ELSIF critical = 0 THEN
        RAISE NOTICE '⚠️  MOSTLY READY - % warnings to address', warnings;
    ELSE
        RAISE NOTICE '❌ NOT READY - Fix % critical issues!', critical;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Contact: Mark Collis (info@small-ai.com)';
    RAISE NOTICE '================================================';
END $$;
