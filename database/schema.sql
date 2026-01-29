-- ============================================
-- MECHANIC APP - COMPLETE DATABASE SCHEMA
-- ============================================
-- This file contains the complete database schema for the mechanic shop application
-- Run migrations in the /database/migrations folder for incremental updates

-- ============================================
-- VEHICLES TABLE
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

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_vin ON vehicles(vin);
CREATE INDEX IF NOT EXISTS idx_vehicles_registration ON vehicles(registration);

-- ============================================
-- SERVICE HISTORY TABLE
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

-- ============================================
-- PARTS USAGE TABLE
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

-- ============================================
-- AUDIT LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE
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

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

-- Vehicles updated_at trigger
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

-- Parts usage updated_at trigger
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

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE parts_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Vehicles policies
CREATE POLICY "Allow authenticated users to read vehicles"
  ON vehicles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert vehicles"
  ON vehicles FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update vehicles"
  ON vehicles FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow admins to delete vehicles"
  ON vehicles FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Service history policies
CREATE POLICY "Allow authenticated users to read service history"
  ON service_history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert service history"
  ON service_history FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update service history"
  ON service_history FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Parts usage policies
CREATE POLICY "Allow authenticated users to read parts usage"
  ON parts_usage FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert parts usage"
  ON parts_usage FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update parts usage"
  ON parts_usage FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete parts usage"
  ON parts_usage FOR DELETE
  TO authenticated
  USING (true);

-- Audit logs policies (read-only for non-admins)
CREATE POLICY "Allow all authenticated users to read audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "System can insert audit logs"
  ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================
-- VIEWS FOR EASIER QUERYING
-- ============================================

-- Vehicle with customer info view
CREATE OR REPLACE VIEW vehicle_details AS
SELECT 
  v.*,
  c.name as customer_name,
  c.email as customer_email,
  c.phone as customer_phone,
  COUNT(DISTINCT sh.id) as service_count,
  MAX(sh.service_date) as last_service_date
FROM vehicles v
LEFT JOIN customers c ON v.customer_id = c.id
LEFT JOIN service_history sh ON v.id = sh.vehicle_id
GROUP BY v.id, c.id;

-- Job with full details view
CREATE OR REPLACE VIEW job_full_details AS
SELECT 
  j.*,
  c.name as customer_name,
  c.email as customer_email,
  c.phone as customer_phone,
  v.make as vehicle_make,
  v.model as vehicle_model,
  v.year as vehicle_year,
  v.registration as vehicle_registration,
  v.vin as vehicle_vin,
  COALESCE(SUM(pu.total_cost), 0) as total_parts_cost,
  COUNT(pu.id) as parts_count
FROM jobs j
LEFT JOIN customers c ON j.customer_id = c.id
LEFT JOIN vehicles v ON j.vehicle_id = v.id
LEFT JOIN parts_usage pu ON j.id = pu.job_id
GROUP BY j.id, c.id, v.id;

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE vehicles IS 'Stores vehicle information linked to customers';
COMMENT ON TABLE service_history IS 'Tracks all service events for vehicles';
COMMENT ON TABLE parts_usage IS 'Records parts used in each job';
COMMENT ON TABLE audit_logs IS 'Audit trail for all data modifications';
