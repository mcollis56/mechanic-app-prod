-- Migration: Add enable_messaging to settings table
ALTER TABLE settings
ADD COLUMN IF NOT EXISTS enable_messaging BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN settings.enable_messaging IS 'Toggle to enable/disable the messaging service add-on feature';
