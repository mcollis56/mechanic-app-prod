-- Migration 002: Enhance Jobs Table
-- This migration adds vehicle-related fields and enhanced tracking to the jobs table

-- Add new columns to jobs table
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

-- Create index for vehicle_id
CREATE INDEX IF NOT EXISTS idx_jobs_vehicle_id ON jobs(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_jobs_technician_id ON jobs(technician_id);

-- Add comment
COMMENT ON COLUMN jobs.vehicle_id IS 'Reference to the vehicle being serviced';
COMMENT ON COLUMN jobs.technician_notes IS 'Internal notes from technician (shorthand)';
COMMENT ON COLUMN jobs.customer_notes IS 'Customer-facing notes';
COMMENT ON COLUMN jobs.ai_enhanced_notes IS 'AI-enhanced version of technician notes';
