-- Migration 004: Add Parts Usage Table
-- This migration creates the parts_usage table for tracking parts used in jobs

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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_parts_usage_job_id ON parts_usage(job_id);
CREATE INDEX IF NOT EXISTS idx_parts_usage_supplier_id ON parts_usage(supplier_id);

-- Create updated_at trigger
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

-- Enable RLS
ALTER TABLE parts_usage ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
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

-- Add comment
COMMENT ON TABLE parts_usage IS 'Records parts used in each job';
