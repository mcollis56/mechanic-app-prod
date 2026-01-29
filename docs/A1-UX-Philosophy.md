# A1 – UX Philosophy & Design Principles

## Purpose of This Document

This document defines the **non-negotiable UX rules** for the Mechanics App MVP.
Every screen, workflow, and feature must conform to these principles.

The goal is **not novelty**.
The goal is **replacement**.

This app must feel immediately usable to a professional mechanic currently relying on tools like AutoFlow — with *less friction*, *greater speed*, and *clearer control*.

If a design decision violates these principles, it is wrong — regardless of technical elegance.

---

## 1. Core UX Philosophy

### 1.1 Workflow First, Screens Second

Mechanics do not think in “pages.”
They think in **jobs**.

The application is organized around **real workshop workflows**, not abstract feature sets.

* The **Work Order** is the central object in the system
* Every action must relate back to:

  * A job
  * A vehicle
  * A customer
* Navigation should feel like *moving through work*, not browsing software

> If a feature does not clearly support a mechanic completing or managing a job, it does not belong in the MVP.

---

### 1.2 Speed Is a Feature

Speed is not an optimization — it is a **core requirement**.

#### Design mandates:

* **Fewer clicks** over visual polish
* **Minimal page loads**
* **Instant feedback** for every action
* **Keyboard-first workflows** where possible

Examples:

* `/` focuses global search
* `N` creates a new work order
* `Cmd/Ctrl + Enter` saves and advances workflow state

If AutoFlow completes a task in 3 actions, this app must do it in **3 or fewer**.

---

## 2. Familiarity Over Innovation

### 2.1 Low Cognitive Load

The mechanic should not have to *learn* the app — only confirm it behaves as expected.

* Use **industry-standard language**
* Avoid clever naming
* Avoid hidden gestures
* Prefer explicit actions over smart guesses

> Familiarity builds trust. Trust enables adoption.

---

### 2.2 Predictable UI Patterns

Consistency is non-negotiable.

* Primary actions always appear in the same location
* Destructive actions are always:

  * Clearly labeled
  * Red
  * Confirmed
* Save actions always:

  * Provide immediate feedback
  * Never silently fail

Shared components must be reused across the entire application.

---

## 3. Information Architecture Principles

### 3.1 Progressive Disclosure

Show **only what is needed right now**.

Complex entities (like Work Orders) must:

* Display critical info by default
* Allow deeper detail on demand
* Never overwhelm the user with everything at once

Examples:

* Job summary first
* Expandable sections for:

  * Parts
  * Notes
  * History
  * AI suggestions

---

### 3.2 Everything Is Connected

Relationships must be navigable and obvious.

From a Work Order, the user must be able to:

* Open the customer profile
* Open the vehicle profile
* View previous jobs for that vehicle
* Jump to inventory items used

Navigation should feel **linked**, not siloed.

---

## 4. AI Design Principles

### 4.1 AI Is an Assistant, Not an Authority

AI exists to **augment** the mechanic — never override them.

* AI suggestions must always be:

  * Optional
  * Editable
  * Clearly marked as AI-generated
* The mechanic always has the final say

Examples:

* Rewrite technical notes into customer-friendly language
* Suggest parts based on job description
* Flag missing information in a work order

---

### 4.2 Graceful Failure

AI features must **never block core workflows**.

If AI fails:

* The user continues manually
* No job data is lost
* No workflow is interrupted

The app must remain fully functional without AI.

---

## 5. Trust & Reliability

### 5.1 No Surprises

Mechanics trust tools that behave consistently.

* No unexpected automation
* No silent changes
* No hidden system decisions

If something changes:

* The user is informed
* The change is reversible where possible

---

### 5.2 Data Safety & Confidence

The mechanic must feel safe using this app in a real business.

* Clear save states
* Obvious job status
* Explicit confirmations
* Undo where feasible

If a mechanic asks “Did that save?”, the UI has failed.

---

## 6. MVP Guardrails

For the MVP phase:

* Prefer **clarity over completeness**
* Prefer **manual control over automation**
* Prefer **working workflows over edge cases**
* Do not build for scale prematurely
* Do not add features to “impress”

> The MVP succeeds when a mechanic can run their day inside it — not when it demos well.

---

## 7. Success Definition

The MVP UX is successful when:

* A mechanic can:

  * Create a job
  * Find a customer or vehicle instantly
  * Add parts and notes
  * Close the job
* …without asking how the app works
* …and without wanting to switch back to AutoFlow

---

## Final Rule

If a design choice conflicts with:

* Speed
* Familiarity
* Control
* Trust

**It must be rejected.**

This document is the UX constitution of the Mechanics App MVP.
