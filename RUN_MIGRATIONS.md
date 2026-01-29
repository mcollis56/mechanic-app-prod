# Database Migration Instructions

## Quick Method: Run All Migrations at Once

Copy and paste this entire SQL script into your Supabase SQL Editor:

```sql
-- ============================================
-- MIGRATION 001: Add Vehicles Table
-- ============================================

CREATE TABLE IF NOT EXISTS vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  vin VARCHAR(17) UNIQUE,
  registration VARCHAR(20),
  make VARCHAR(100) NOT NULL,
  model VARCHAR(100) NOT NULL,
  year INTEGER,
  color VARCHAR(50),
  engine_type VARCHAR(100),
  transmission VARCHAR(50),
  odometer INTEGER,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_vin ON vehicles(vin);
CREATE INDEX IF NOT EXISTS idx_vehicles_registration ON vehicles(registration);

CREATE OR REPLACE FUNCTION update_vehicles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_vehicles_updated_at
  BEFORE UPDATE ON vehicles
  FOR EACH ROW
  EXECUTE FUNCTION update_vehicles_updated_at();

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read vehicles"
  ON vehicles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert vehicles"
  ON vehicles FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update vehicles"
  ON vehicles FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow admins to delete vehicles"
  ON vehicles FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));

COMMENT ON TABLE vehicles IS 'Stores vehicle information linked to customers';

-- ============================================
-- MIGRATION 002: Enhance Jobs Table
-- ============================================

ALTER TABLE jobs ADD COLUMN IF NOT EXISTS vehicle_id UUID REFERENCES vehicles(id);
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS estimated_completion TIMESTAMPTZ;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS actual_completion TIMESTAMPTZ;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS labor_hours NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS labor_cost NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS parts_cost NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS total_cost NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS technician_notes TEXT;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS customer_notes TEXT;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS ai_enhanced_notes TEXT;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS technician_id UUID REFERENCES profiles(id);

CREATE INDEX IF NOT EXISTS idx_jobs_vehicle_id ON jobs(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_jobs_technician_id ON jobs(technician_id);

COMMENT ON COLUMN jobs.vehicle_id IS 'Reference to the vehicle being serviced';
COMMENT ON COLUMN jobs.technician_notes IS 'Internal notes from technician (shorthand)';
COMMENT ON COLUMN jobs.customer_notes IS 'Customer-facing notes';
COMMENT ON COLUMN jobs.ai_enhanced_notes IS 'AI-enhanced version of technician notes';

-- ============================================
-- MIGRATION 003: Add Service History Table
-- ============================================

CREATE TABLE IF NOT EXISTS service_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
  job_id UUID REFERENCES jobs(id),
  service_date TIMESTAMPTZ DEFAULT NOW(),
  service_type VARCHAR(100),
  description TEXT,
  odometer INTEGER,
  cost NUMERIC(10, 2),
  technician_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_service_history_vehicle_id ON service_history(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_service_history_job_id ON service_history(job_id);
CREATE INDEX IF NOT EXISTS idx_service_history_date ON service_history(service_date);

ALTER TABLE service_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read service history"
  ON service_history FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert service history"
  ON service_history FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update service history"
  ON service_history FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

COMMENT ON TABLE service_history IS 'Tracks all service events for vehicles';

-- ============================================
-- MIGRATION 004: Add Parts Usage Table
-- ============================================

CREATE TABLE IF NOT EXISTS parts_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  part_name VARCHAR(200) NOT NULL,
  part_number VARCHAR(100),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_cost NUMERIC(10, 2) NOT NULL DEFAULT 0,
  total_cost NUMERIC(10, 2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
  supplier_id UUID REFERENCES suppliers(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parts_usage_job_id ON parts_usage(job_id);
CREATE INDEX IF NOT EXISTS idx_parts_usage_supplier_id ON parts_usage(supplier_id);

CREATE OR REPLACE FUNCTION update_parts_usage_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_parts_usage_updated_at
  BEFORE UPDATE ON parts_usage
  FOR EACH ROW
  EXECUTE FUNCTION update_parts_usage_updated_at();

ALTER TABLE parts_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read parts usage"
  ON parts_usage FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert parts usage"
  ON parts_usage FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update parts usage"
  ON parts_usage FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete parts usage"
  ON parts_usage FOR DELETE TO authenticated USING (true);

COMMENT ON TABLE parts_usage IS 'Records parts used in each job';

-- ============================================
-- MIGRATION 005: Add Audit Logs Table
-- ============================================

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  action VARCHAR(50) NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all authenticated users to read audit logs"
  ON audit_logs FOR SELECT TO authenticated USING (true);

CREATE POLICY "System can insert audit logs"
  ON audit_logs FOR INSERT TO authenticated WITH CHECK (true);

COMMENT ON TABLE audit_logs IS 'Audit trail for all data modifications';

-- ============================================
-- MIGRATION 006: Add Role-Based Access Control
-- ============================================

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'technician';

CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
  CHECK (role IN ('admin', 'service_advisor', 'technician'));

CREATE OR REPLACE FUNCTION has_role(required_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = required_role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION has_any_role(required_roles TEXT[])
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = ANY(required_roles)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON COLUMN profiles.role IS 'User role: admin, service_advisor, or technician';
COMMENT ON FUNCTION has_role IS 'Check if current user has a specific role';
COMMENT ON FUNCTION has_any_role IS 'Check if current user has any of the specified roles';

-- ============================================
-- MIGRATION 007: Enhance Customers Table
-- ============================================

ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS preferred_contact VARCHAR(20) DEFAULT 'email';

ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_preferred_contact_check;
ALTER TABLE customers ADD CONSTRAINT customers_preferred_contact_check 
  CHECK (preferred_contact IN ('email', 'phone', 'sms'));

COMMENT ON COLUMN customers.address IS 'Customer physical address';
COMMENT ON COLUMN customers.notes IS 'Internal notes about the customer';
COMMENT ON COLUMN customers.preferred_contact IS 'Preferred method of contact: email, phone, or sms';

-- ============================================
-- MIGRATIONS COMPLETE
-- ============================================
```

## Steps to Run:

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard/project/tvsgzlxubjhpbnszwdik/sql/new

2. **Copy the SQL Above**
   - Select all the SQL code above (from `-- MIGRATION 001` to the end)
   - Copy it (Cmd+C)

3. **Paste into SQL Editor**
   - Click in the SQL editor
   - Paste the code (Cmd+V)

4. **Run the Migration**
   - Click the "Run" button (or press Cmd+Enter)
   - Wait for execution to complete

5. **Check Results**
   - ✅ Look for "Success" messages
   - ✅ "relation already exists" or "column already exists" is OK (means it was already created)
   - ❌ Any other errors should be reported

## Expected Output:

You should see messages like:
- `CREATE TABLE` - Success
- `CREATE INDEX` - Success  
- `CREATE POLICY` - Success
- `ALTER TABLE` - Success

Or:
- `relation "vehicles" already exists` - OK, skip
- `column "vehicle_id" already exists` - OK, skip

## Verification:

After running, verify the tables exist:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('vehicles', 'service_history', 'parts_usage', 'audit_logs')
ORDER BY table_name;
```

You should see all 4 new tables listed.

## Troubleshooting:

**Error: "relation does not exist"**
- Make sure you're running migrations in order
- Check that the referenced table (like `customers` or `jobs`) exists

**Error: "permission denied"**
- Make sure you're logged in as the project owner
- Check that you're in the correct project

**Error: "syntax error"**
- Make sure you copied the entire SQL block
- Check for any missing characters

---

Once you've run this successfully, your database will be ready for the new vehicle management features!
