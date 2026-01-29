-- Migration 003: Add Service History Table
-- This migration creates the service_history table for tracking vehicle service records

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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_service_history_vehicle_id ON service_history(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_service_history_job_id ON service_history(job_id);
CREATE INDEX IF NOT EXISTS idx_service_history_date ON service_history(service_date);

-- Enable RLS
ALTER TABLE service_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
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

-- Add comment
COMMENT ON TABLE service_history IS 'Tracks all service events for vehicles';
