-- Migration 007: Enhance Customers Table
-- This migration adds additional fields to the customers table

-- Add new columns to customers table
ALTER TABLE customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS preferred_contact VARCHAR(20) DEFAULT 'email';

-- Add constraint for preferred_contact
ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_preferred_contact_check;
ALTER TABLE customers ADD CONSTRAINT customers_preferred_contact_check 
  CHECK (preferred_contact IN ('email', 'phone', 'sms'));

-- Add comments
COMMENT ON COLUMN customers.address IS 'Customer physical address';
COMMENT ON COLUMN customers.notes IS 'Internal notes about the customer';
COMMENT ON COLUMN customers.preferred_contact IS 'Preferred method of contact: email, phone, or sms';
