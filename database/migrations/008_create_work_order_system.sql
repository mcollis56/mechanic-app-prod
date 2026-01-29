-- Migration for work order system: create work_orders, work_order_items, job_notes tables

create table work_orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  vehicle_id uuid references vehicles(id),
  status text check (status in ('draft','in_progress','completed')),
  summary text,
  labour_notes text,
  created_at timestamp default now(),
  completed_at timestamp
);

create table work_order_items (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references work_orders(id),
  name text,
  unit_cost numeric,
  quantity integer,
  created_at timestamp default now()
);

create table job_notes (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references work_orders(id),
  content text,
  source text check (source in ('manual','ai')),
  created_at timestamp default now()
);
