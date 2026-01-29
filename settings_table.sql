-- Create settings table
-- This table will only ever have ONE row containing global application settings
CREATE TABLE settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  business_name TEXT,
  address TEXT,
  abn TEXT,
  phone TEXT,
  email TEXT,
  hourly_rate NUMERIC(10, 2) DEFAULT 150.00,
  tax_rate NUMERIC(5, 2) DEFAULT 10.00,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_settings_updated_at
  BEFORE UPDATE ON settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert the initial settings row (there should only ever be ONE row)
INSERT INTO settings (business_name, address, abn, phone, email, hourly_rate, tax_rate)
VALUES (
  'Euro Motor Works',
  '',
  '',
  '',
  '',
  150.00,
  10.00
);

-- Create a constraint to ensure only one row exists
-- This prevents accidental insertion of multiple settings rows
CREATE OR REPLACE FUNCTION prevent_multiple_settings()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM settings) >= 1 THEN
    RAISE EXCEPTION 'Only one settings row is allowed. Use UPDATE instead.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_single_settings_row
  BEFORE INSERT ON settings
  FOR EACH ROW
  EXECUTE FUNCTION prevent_multiple_settings();

-- Enable Row Level Security
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Create policy allowing all authenticated users to read settings
CREATE POLICY "Allow authenticated users to read settings"
  ON settings
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policy allowing authenticated users to update settings
CREATE POLICY "Allow authenticated users to update settings"
  ON settings
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Query to verify the settings table and initial data
SELECT * FROM settings;
