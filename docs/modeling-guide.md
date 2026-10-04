# Modeling Guide

## Tools

- **TLC** (bundled with the TLA+ Toolbox) — exhaustive model checking of small state spaces.
- **Apalache** — symbolic model checking, inductive invariants; preferred for larger but still bounded models.
- **TLA+ Toolbox** — convenient editor and model-checking UI.

Installation instructions are maintained upstream:

- https://github.com/tlaplus/tlaplus
- https://github.com/apalache-mc/apalache

## Recommended workflow

1. Edit the `.tla` module.
2. Keep the corresponding `.cfg` in sync (INIT, NEXT, INVARIANTS, PROPERTIES, CONSTANTS).
3. Start with the smallest constant values that still exercise the property.
4. Run TLC or Apalache.
5. If a counter-example appears, decide whether the model or the intended property needs adjustment.
6. Record the command line and configuration used when reporting results.

## Constant sizing

All provided configurations deliberately use small cardinalities, for example:

- number of agents / identities ≤ 3
- number of parallel nets ≤ 2
- number of recovery steps ≤ 4

Larger values quickly make exhaustive checking infeasible.  
When you increase a constant, document the new bound and the tool used.

## Style conventions

- One primary module per concern; helpers go into `common/`.
- Operators that return a `Decision` are named with a verb or clear predicate (`Evaluate`, `MayProceed`, …).
- Comments above each invariant state the informal property in one sentence.
- Avoid recursive operators that make TLC exploration hard to predict unless necessary.

## Checking with TLC (example)

```bash
# from the repository root, after installing tlc
tlc -config examples/ethical_kernel_small.cfg specs/ethical_kernel/EthicalKernel.tla
```

## Checking with Apalache (example)

```bash
apalache-mc check --config=examples/ethical_kernel_small.cfg \
  specs/ethical_kernel/EthicalKernel.tla
```

Exact flags depend on the installed version; consult the Apalache documentation.

## Interpreting results

- “No error found” under a given configuration means the stated invariants/properties held for the explored states of that configuration.
- It does **not** mean the property holds for the real system, for larger parameters, or under unmodeled conditions.
- Always pair a positive result with the configuration and the list of checked properties.

## Extending a model

When you add a new action or variable:

1. Update `TypeOK`.
2. Update the next-state relation.
3. Re-examine every invariant; new states may violate previously true statements.
4. Add or adjust a small configuration that covers the new behavior.