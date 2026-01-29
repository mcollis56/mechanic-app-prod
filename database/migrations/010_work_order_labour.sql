-- Migration 010: Add work order labour tracking table
-- Separates labour/service charges from parts for better tracking

CREATE TABLE IF NOT EXISTS work_order_labour (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id uuid REFERENCES work_orders(id) ON DELETE CASCADE,
  description text NOT NULL,
  hours numeric(5,2) NOT NULL DEFAULT 1,
  rate numeric(10,2) NOT NULL DEFAULT 0,
  total numeric(10,2) GENERATED ALWAYS AS (hours * rate) STORED,
  created_at timestamp DEFAULT now()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_work_order_labour_work_order_id ON work_order_labour(work_order_id);

-- Enable RLS
ALTER TABLE work_order_labour ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Allow authenticated users to read work order labour"
  ON work_order_labour FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert work order labour"
  ON work_order_labour FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update work order labour"
  ON work_order_labour FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete work order labour"
  ON work_order_labour FOR DELETE
  TO authenticated
  USING (true);

COMMENT ON TABLE work_order_labour IS 'Tracks labour/service charges for work orders';
COMMENT ON COLUMN work_order_labour.hours IS 'Number of hours for this labour item';
COMMENT ON COLUMN work_order_labour.rate IS 'Hourly rate in dollars';
COMMENT ON COLUMN work_order_labour.total IS 'Automatically calculated as hours * rate';
