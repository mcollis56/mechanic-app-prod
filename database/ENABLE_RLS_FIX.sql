-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
-- Euro Motor Works - Security Fix
-- Contact: Mark Collis (info@small-ai.com)
-- Date: January 5, 2026
-- ============================================

-- STEP 1: ENABLE RLS ON TABLES

ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.work_order_items ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.job_notes ENABLE ROW LEVEL SECURITY;

-- STEP 2: CREATE POLICIES FOR WORK_ORDERS

CREATE POLICY "Enable read access for authenticated users"
ON public.work_orders
FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users"
ON public.work_orders
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users"
ON public.work_orders
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users"
ON public.work_orders
FOR DELETE
USING (auth.role() = 'authenticated');

-- STEP 3: CREATE POLICIES FOR WORK_ORDER_ITEMS

CREATE POLICY "Enable read access for authenticated users"
ON public.work_order_items
FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users"
ON public.work_order_items
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users"
ON public.work_order_items
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users"
ON public.work_order_items
FOR DELETE
USING (auth.role() = 'authenticated');

-- STEP 4: CREATE POLICIES FOR JOB_NOTES

CREATE POLICY "Enable read access for authenticated users"
ON public.job_notes
FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users"
ON public.job_notes
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users"
ON public.job_notes
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users"
ON public.job_notes
FOR DELETE
USING (auth.role() = 'authenticated');

-- STEP 5: VERIFY EVERYTHING

SELECT 
    tablename,
    rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('work_orders', 'work_order_items', 'job_notes');

SELECT 
    schemaname,
    tablename,
    policyname,
    cmd AS operation
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('work_orders', 'work_order_items', 'job_notes')
ORDER BY tablename, cmd;

SELECT 
    tablename,
    COUNT(*) AS policy_count
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('work_orders', 'work_order_items', 'job_notes')
GROUP BY tablename
ORDER BY tablename;
