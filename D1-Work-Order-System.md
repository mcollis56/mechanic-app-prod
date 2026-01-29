# D1 – Work Order System (Implementation Plan)

## Purpose

This document defines **how to implement the MVP Work Order system** safely and incrementally, using the existing Supabase schema where possible and introducing new structures only when required.

It provides:
- A canonical Work Order model
- A consolidation strategy for existing tables
- A safe migration plan
- A UI build order

This document is where **building resumes**.

---

## 1. Canonical MVP Work Order Model

From this point forward, the MVP treats **WorkOrder** as a first-class object.

### Canonical Fields

```
work_orders
- id (uuid, pk)
- customer_id (fk → customers)
- vehicle_id (fk → vehicles)
- status (draft | in_progress | completed)
- summary (text)
- labour_notes (text)
- created_at
- completed_at (nullable)
```

This model obeys:
- C1 (data)
- C2 (state)
- B1 (scope)

---

## 2. Mapping Existing Tables → MVP Model

### Current Reality → Target Reality

| Existing Table     | Action | Reason |
|--------------------|--------|-------|
| `jobs`             | KEEP (temporary) | Closest match to WorkOrder |
| `job_parts`        | KEEP (temporary) | Maps to WorkOrderItem |
| `invoices`         | READ-ONLY VIEW   | Represents completed jobs |
| `invoice_items`    | IGNORE (for now) | Superseded by job_parts |
| `bookings`         | IGNORE (MVP)     | Scheduling out of scope |

⚠️ **Nothing is deleted in MVP phase**

---

## 3. Migration Strategy (Safe & Incremental)

### Phase 1 — Introduce `work_orders` (Non-Destructive)

- Create new `work_orders` table
- Do **not** remove `jobs`
- New UI uses `work_orders`
- Old data remains untouched

This avoids:
- Data loss
- Downtime
- Broken demos

### Phase 2 — Introduce `work_order_items`

- New table mirrors MVP definition
- Initially populated only for new jobs
- Legacy `job_parts` remains untouched

### Phase 3 — Read Legacy Data (Optional)

If needed for demo:
- Read from `jobs` + `job_parts`
- Display as read-only “legacy jobs”

No backfill required for MVP.

---

## 4. Supabase Migration Order

### Migration 1 — work_orders

```sql
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
```

### Migration 2 — work_order_items

```sql
create table work_order_items (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references work_orders(id),
  name text,
  unit_cost numeric,
  quantity integer,
  created_at timestamp default now()
);
```

### Migration 3 — job_notes

```sql
create table job_notes (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid references work_orders(id),
  content text,
  source text check (source in ('manual','ai')),
  created_at timestamp default now()
);
```

---

## 5. UI Build Order (Critical)

Build in this order only:

### Step 1 — Work Order List
- Filter by status
- Searchable
- Click-through to detail

### Step 2 — Create Work Order (Draft)
- Select customer
- Select vehicle
- Enter summary

### Step 3 — Work Order Detail
- Status badge
- Notes section
- Parts section
- State-based actions

### Step 4 — State Transitions
- Draft → In Progress
- In Progress → Completed
- Enforce C2 rules

---

## 6. UI Guardrails (From A1 + C2)

- No editing in `completed`
- Status controls always visible
- Primary action is state-driven
- No hidden automation
- AI is optional and clearly marked

---

## 7. What NOT to Build Yet

Explicitly forbidden during D1 execution:

- Invoice editor
- Payments
- Notifications
- Multi-user roles
- Analytics dashboards

---

## 8. Definition of “Done” for D1

D1 is complete when:

- A mechanic can:
  - Create a work order
  - Add parts & notes
  - Move through all states
  - View a completed job
- No legacy tables are broken
- No data is lost
- No workflow violates C2

---

## Final Rule

If implementation complexity increases:
- Stop
- Re-read C2
- Simplify

The Work Order system is the product.
