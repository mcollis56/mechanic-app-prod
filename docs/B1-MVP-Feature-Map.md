# B1 – MVP Feature Map

## Purpose

This document defines the **exact functional scope** of the Mechanics App MVP.

Anything not explicitly listed here:

* Is **out of scope**
* Is **not required** for the next demo
* Must not be built during MVP phase

The goal is **workflow parity** with the core daily functions of AutoFlow — not feature parity.

---

## 1. Core User

**Primary User:**
Independent mechanic or small workshop (1–5 techs)

**Daily Goal:**
Efficiently manage jobs from arrival → completion → invoicing without friction.

---

## 2. Core MVP Objects

These entities must exist in the MVP:

1. Customer
2. Vehicle
3. Work Order (primary object)
4. Part / Inventory Item
5. Job Note (manual + AI-assisted)

Everything else is secondary.

---

## 3. MVP Feature Set

### 3.1 Global Search (Critical)

**Purpose:** Instantly find anything.

Searchable:

* Customer name / phone
* Vehicle rego / VIN
* Work order number / status

Requirements:

* Keyboard accessible (`/`)
* Results grouped by type
* One-click navigation

---

### 3.2 Customer Management (Essential)

Features:

* Create / edit customer
* View customer history
* See all vehicles owned
* See all past work orders

Out of Scope:

* Marketing
* Reminders
* CRM automation

---

### 3.3 Vehicle Management (Essential)

Features:

* Add vehicle to customer
* Store rego, VIN, make, model, year
* View vehicle job history
* Quick-select vehicle when creating job

Out of Scope:

* Service schedules
* Automated maintenance reminders

---

### 3.4 Work Order System (Core)

This is the **heart of the app**.

Features:

* Create new work order
* Assign customer + vehicle
* Job status:

  * Draft
  * In Progress
  * Completed
* Add:

  * Notes
  * Parts
  * Labour description
* View previous work on same vehicle
* Clear save state & status visibility

Out of Scope:

* Multi-tech assignment
* Time tracking
* Invoicing integrations

---

### 3.5 Parts & Inventory (MVP Level)

Features:

* Add parts to a work order
* Track:

  * Part name
  * Cost
  * Quantity
* Auto-calculate job total (parts only)
* Optional inventory list

Out of Scope:

* Supplier integrations
* Stock alerts
* Purchase orders

---

### 3.6 AI-Assisted Notes (Supportive)

Features:

* Rewrite tech notes into customer-friendly language
* Highlight missing job info
* Suggest parts based on description

Rules:

* AI is optional
* AI output is editable
* AI never blocks saving or closing a job

---

## 4. Explicitly Out of Scope (MVP)

The following must **not** be built yet:

* Payments
* Invoicing
* SMS / Email notifications
* User roles & permissions
* Multi-location support
* Reporting dashboards
* Marketing features

---

## 5. MVP Success Criteria

The MVP is successful when:

* A mechanic can run a full job lifecycle
* Search replaces memory
* Work orders replace paper
* The mechanic does **not** miss AutoFlow during daily use

---

## 6. Build Guardrail

If a proposed feature does **not**:

* Reduce clicks
* Reduce time
* Reduce mental load

It does not belong in the MVP.

---

## Final Statement

This document is the **build contract**.

Deviations require explicit justification.

No exceptions.
