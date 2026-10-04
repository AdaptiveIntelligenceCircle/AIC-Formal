# Overview — AIC-Formal

## Why formal models exist here

AIC places ethical constraints near the authorization path (Ethical Kernel) and treats human judgment as a first-class outcome (`NeedHuman`).  
These constraints are easy to state in prose and easy to erode in implementation.  

Small TLA+ models make selected constraints checkable on finite state spaces.  
They serve as:

- a precise language for discussing properties,
- a regression surface when design intent changes,
- a teaching aid for contributors who want to understand the intended boundaries.

They are **not** a verification of any running system.

## Modeling approach

We use:

- **TLA+** for specification of state machines and properties,
- **TLC** for exhaustive checking of small configurations,
- **Apalache** (preferred when available) for inductive invariant checking and larger but still bounded models.

State spaces are kept intentionally small.  
Constants that control cardinality (number of agents, identities, nets, etc.) are set to low values in the provided `.cfg` files.

## Core decision type

Most models revolve around a three-valued decision:

```
Decision == {"Allow", "Deny", "NeedHuman"}
```

- `Allow` — the requested action may proceed under the modeled constraints.
- `Deny` — the requested action is refused (fail-closed default).
- `NeedHuman` — automated evaluation is insufficient; a human gate is required before any further progress.

The models treat `NeedHuman` as a distinct, non-bypassable outcome.

## Module families

| Family | Focus |
|--------|-------|
| `common` | Shared types, constants, helper operators |
| `ethical_kernel` | Core evaluate function and fail-closed properties |
| `governance` | Governance evaluation and succession sketches |
| `ssi` | Simplified bind / revoke / rotate |
| `recovery` | Recovery orchestration sketches |
| `parallel_nets` | Isolation and default-deny bridge behavior |

## How to read a model

1. Start with the constants and type definitions.
2. Read the state variables and the next-state relation.
3. Examine the invariants and temporal properties.
4. Check the accompanying `.cfg` to see which constants and properties are actually checked.
5. Consult `docs/limitations.md` before drawing conclusions.

## Status language

Throughout this repository we use:

- “model checks” / “no violation found under the given configuration”
- never “verified”, “proven safe”, or “production ready”

This language is deliberate.