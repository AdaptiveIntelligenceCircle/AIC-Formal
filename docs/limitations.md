# Limitations

This document is part of the under-claim posture of AIC-Formal.  
Read it before treating any model-checking result as evidence about a real system.

## 1. Finite and small state spaces

All models are finite-state.  
Provided configurations use very small constants.  
Properties that hold for 2–3 identities may fail (or become intractable) for realistic populations.

## 2. Abstraction of cryptography and real identity

SSI models treat bind / revoke / rotate as abstract state transitions.  
They do not model:

- cryptographic hardness,
- key compromise,
- side-channel leakage,
- concrete credential formats.

A checked SSI invariant does not imply that any particular cryptographic implementation is secure.

## 3. Abstraction of time and concurrency

Most models use interleaving semantics with a single next-state relation.  
They do not capture:

- real-time deadlines,
- partial failures with arbitrary message delay,
- Byzantine behavior beyond what is explicitly coded.

## 4. No claim about the C++ TestNet or any deployment

The Parallel TestNet and other implementation repositories may be inspired by these models.  
A successful model check does **not** prove that the implementation satisfies the property.  
Implementation bugs, divergent interpretations, and unmodeled platform behavior remain possible.

## 5. Human gate is idealized

The `NeedHuman` outcome is modeled as a distinct state that requires an explicit human confirmation action.  
In reality, human attention, interface design, and social processes can fail.  
The models do not address those failures.

## 6. Recovery models are sketches

Recovery modules explore the idea that recovery should not silently escalate privilege.  
They are not complete models of disaster recovery, backup integrity, or multi-site failover.

## 7. Absence of economic variables is structural, not proven

We simply do not declare token or stake variables.  
This is a design choice visible by inspection, not a deep theorem about all possible extensions.

## 8. Tool limitations

- TLC may miss behaviors if the configuration is incomplete or the state space is only partially explored.
- Apalache relies on SMT solvers; solver incompleteness or encoding choices can affect results.
- Both tools can produce false confidence when the model itself is wrong.

## 9. Pre-Covenant status

Nothing in this repository advances or constitutes a Covenant declaration.  
Formal results are inputs to engineering judgment, not substitutes for the Covenant checklist.

## 10. Entity ≠ immunity

Successful model checks do not grant Adaptive Intelligence Circle, its maintainers, or any other party immunity from criticism, liability, or regulatory requirements.

---

When in doubt, treat a positive model-checking result as: