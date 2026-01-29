-- Migration 009: Add rego renewal / pink slip workflow support
-- This adds the job_type column and additional statuses for eSafety inspections

-- Add job_type column to work_orders
ALTER TABLE work_orders
ADD COLUMN IF NOT EXISTS job_type text;

-- Update status check constraint to include new inspection statuses
-- First drop the existing constraint, then add the new one
ALTER TABLE work_orders DROP CONSTRAINT IF EXISTS work_orders_status_check;

ALTER TABLE work_orders
ADD CONSTRAINT work_orders_status_check
CHECK (status IN ('draft', 'in_progress', 'completed', 'awaiting_inspection', 'inspection_failed', 'pink_slip_lodged'));

-- Add index for job_type lookups
CREATE INDEX IF NOT EXISTS idx_work_orders_job_type ON work_orders(job_type);

-- Add RLS policies for work_orders if not already present
ALTER TABLE work_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow authenticated users to read work orders"
  ON work_orders FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated users to insert work orders"
  ON work_orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated users to update work orders"
  ON work_orders FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Allow admins to delete work orders"
  ON work_orders FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

COMMENT ON COLUMN work_orders.job_type IS 'Type of work order: null for standard, rego_renewal for pink slip inspections';
