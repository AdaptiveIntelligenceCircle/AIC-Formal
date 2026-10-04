# AIC-Formal

**Formal models (TLA+ / Apalache) for Adaptive Intelligence Circle reference properties.**

Status: **pre-Covenant**, experimental, under-claim.  

> These models are design aids and property checks for Parallel TestNet components.  

> They do **not** constitute a verified production system, a Covenant declaration, or any form of certification.

## Purpose

AIC-Formal provides machine-checkable models of selected invariants that appear in the Ethical Kernel, governance evaluation, SSI operations, recovery paths, and parallel-net isolation.

The models exist so that:

- contributors can state properties precisely,
- regressions in design intent can be detected early,
- the gap between “we intend fail-closed” and “we can check a small model of fail-closed” is reduced.

They are **not** a substitute for testing, code review, or operational judgment.

## Scope (explicit limits)

| In scope | Out of scope |
|----------|--------------|
| Small-state models of Allow / Deny / NeedHuman | Full protocol verification |
| Fail-closed and human-gate properties | Performance or liveness of real deployments |
| SSI bind / revoke / rotate invariants (simplified) | Cryptographic correctness proofs |
| Recovery orchestration sketches | Mainnet or Covenant claims |
| Parallel-net isolation (default-deny bridge) | Token or economic models |

## Layout

```
AIC-Formal/
├── README.md
├── LICENSE
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── SECURITY.md
├── docs/
│   ├── overview.md
│   ├── properties.md
│   ├── modeling-guide.md
│   └── limitations.md
├── specs/
│   ├── common/           # shared constants, types, helpers
│   ├── ethical_kernel/   # core evaluate decision
│   ├── governance/       # governance evaluate & succession sketches
│   ├── ssi/              # bind / revoke / rotate
│   ├── recovery/         # recovery orchestrator sketches
│   └── parallel_nets/    # isolation & default-deny bridge
├── tools/                # helper scripts (Apalache / TLC)
└── examples/             # small runnable configurations
```

## Quick start

1. Install [TLA+ Toolbox](https://github.com/tlaplus/tlaplus) or use command-line TLC / Apalache.
2. Read `docs/overview.md` and `docs/limitations.md`.
3. Open a module under `specs/` and its corresponding `.cfg`.
4. Run model checking on the small configurations provided in `examples/`.

Apalache is preferred for inductive invariants; TLC is sufficient for small exhaustive checks.

## Relationship to other AIC repositories

- **AIC-TestNet / Parallel TestNet** — these models abstract selected behaviors that the C++ reference nets implement.
- **AIC-Covenant** — criteria and checklists may reference properties stated here; models do not declare Covenant readiness.
- **AIC-TransparencyDashboard** — formal results (when produced) can be logged as audit events; no automatic pipeline is assumed.
- **AIC-Start-Here / MyVision** — philosophical and onboarding context; formal models stay technical and bounded.

## Principles observed

- **Under-claim**: models are partial, finite-state, and explicitly limited.
- **Fail-closed**: default behavior in models is Deny when conditions are not met.
- **No token rule-power**: no economic variables appear in any module.
- **Entity ≠ immunity**: formal results do not grant any organization or person special status.
- **Pre-Covenant**: nothing in this repository advances a mainnet or Covenant declaration.

## License

GPL-3.0-or-later (see LICENSE).  
Documentation may be dual-licensed under CC-BY-4.0 where noted.

## Maintenance note

During periods of reduced maintainer availability the repository remains public.  
Contributions that preserve under-claim language and do not expand scope beyond the documented limits are welcome.