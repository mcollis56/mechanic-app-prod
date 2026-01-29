-- Get current user and update their role to admin
-- First, let's see what users exist
SELECT id, email FROM auth.users;

-- To make a user admin, you'll need to run:
-- UPDATE profiles SET role = 'admin' WHERE id = 'YOUR_USER_ID';
