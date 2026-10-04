# Properties of Interest

This document lists the properties that the models in AIC-Formal aim to express.  
Each property is stated in informal English first, then linked to the modules that attempt to capture it.

All properties are subject to the limitations described in `limitations.md`.

## 1. Fail-closed default

**Informal statement**  
When the conditions required for `Allow` are not met, the decision is `Deny` (or `NeedHuman` when human judgment is required).  
There is no implicit fall-through to permission.

**Modules**  
- `ethical_kernel/EthicalKernel.tla`  
- `governance/GovernanceEvaluate.tla`

**Typical invariant name**  
`Inv_FailClosed`

## 2. Human gate is non-bypassable

**Informal statement**  
If evaluation yields `NeedHuman`, no subsequent automated transition may turn the decision into `Allow` without an explicit human confirmation action modeled in the state machine.

**Modules**  
- `ethical_kernel/EthicalKernel.tla`  
- `governance/GovernanceEvaluate.tla`

**Typical property name**  
`Prop_HumanGateRequired`

## 3. SSI lifecycle integrity (simplified)

**Informal statement**  
- An identity cannot be used after it has been revoked (until a new bind occurs).  
- Rotate replaces the active binding; the previous binding is no longer active.  
- Bind requires the necessary preconditions (modeled abstractly).

**Modules**  
- `ssi/SSI.tla`

**Typical invariants**  
`Inv_RevokedNotActive`, `Inv_RotateReplaces`

## 4. Recovery does not silently expand authority

**Informal statement**  
Recovery actions restore a previously authorized state or move the system into a restricted safe state.  
They do not create new privileges that did not exist before the failure.

**Modules**  
- `recovery/Recovery.tla`

**Typical invariant**  
`Inv_RecoveryNoPrivilegeEscalation`

## 5. Parallel-net isolation (default-deny bridge)

**Informal statement**  
Traffic or state influence between distinct parallel nets is denied by default.  
An explicit, modeled bridge permission is required for any cross-net effect.

**Modules**  
- `parallel_nets/Isolation.tla`

**Typical invariant**  
`Inv_DefaultDenyBridge`

## 6. No token rule-power (structural absence)

**Informal statement**  
No variable representing token balance, stake, or economic weight appears in any decision path.  
Governance and kernel decisions depend on identity, policy, and human gates only.

**Modules**  
- All modules (structural check by inspection; no economic variables are declared)

## Property naming convention

- `Inv_*` — safety invariants (always true in reachable states)
- `Prop_*` — temporal properties (usually `[]` or `~>` forms)
- `TypeOK` — type correctness of the state

## Adding a new property

1. State it informally in this file.
2. Implement it in the appropriate module (or a new module under the correct family).
3. Add a small configuration that checks it.
4. Document any new assumptions in `limitations.md` or in module comments.