----------------------------- MODULE Recovery -----------------------------
(***************************************************************************)
(* Recovery orchestration sketch.                                          *)
(*                                                                         *)
(* Goal: recovery actions restore a prior safe state or move into a        *)
(* restricted mode; they do not silently create new privileges.            *)
(*                                                                         *)
(* This is an abstract state machine only.  See docs/limitations.md.       *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, AICTypes

CONSTANTS
  MaxSteps,
  Privileges         \* abstract privilege labels

ASSUME MaxSteps \in Nat /\ MaxSteps > 0
ASSUME IsFiniteSet(Privileges)

VARIABLES
  step,
  mode,              \* "normal" | "degraded" | "recovery"
  heldPrivileges,    \* privileges currently held
  snapshotPrivileges,\* privileges frozen at the start of recovery
  history

vars == <<step, mode, heldPrivileges, snapshotPrivileges, history>>

Modes == {"normal", "degraded", "recovery"}

TypeOK ==
  /\ step \in 0..MaxSteps
  /\ mode \in Modes
  /\ heldPrivileges \subseteq Privileges
  /\ snapshotPrivileges \subseteq Privileges
  /\ history \in Seq(Modes \cup {"snapshot", "restore", "restrict"})

Init ==
  /\ step = 0
  /\ mode = "normal"
  /\ heldPrivileges = Privileges   \* start with full set for the small model
  /\ snapshotPrivileges = {}
  /\ history = << >>

(***************************************************************************)
(* Enter degraded mode (e.g., after detecting inconsistency).              *)
(***************************************************************************)
EnterDegraded ==
  /\ step < MaxSteps
  /\ mode = "normal"
  /\ mode' = "degraded"
  /\ history' = Append(history, "degraded")
  /\ UNCHANGED <<heldPrivileges, snapshotPrivileges>>
  /\ step' = step + 1

(***************************************************************************)
(* Begin recovery: take a snapshot of current privileges.                  *)
(***************************************************************************)
BeginRecovery ==
  /\ step < MaxSteps
  /\ mode \in {"normal", "degraded"}
  /\ mode' = "recovery"
  /\ snapshotPrivileges' = heldPrivileges
  /\ history' = Append(history, "snapshot")
  /\ UNCHANGED heldPrivileges
  /\ step' = step + 1

(***************************************************************************)
(* Restrict: drop privileges during recovery (fail-closed direction).      *)
(***************************************************************************)
Restrict(priv) ==
  /\ step < MaxSteps
  /\ mode = "recovery"
  /\ priv \in heldPrivileges
  /\ heldPrivileges' = heldPrivileges \ {priv}
  /\ history' = Append(history, "restrict")
  /\ UNCHANGED <<mode, snapshotPrivileges>>
  /\ step' = step + 1

(***************************************************************************)
(* Restore from snapshot: privileges become a subset of the snapshot.      *)
(* This prevents escalation beyond what was held when recovery started.    *)
(***************************************************************************)
Restore ==
  /\ step < MaxSteps
  /\ mode = "recovery"
  /\ heldPrivileges' \subseteq snapshotPrivileges
  /\ mode' = "normal"
  /\ history' = Append(history, "restore")
  /\ UNCHANGED snapshotPrivileges
  /\ step' = step + 1

Nop ==
  /\ step < MaxSteps
  /\ UNCHANGED <<mode, heldPrivileges, snapshotPrivileges>>
  /\ history' = Append(history, mode)
  /\ step' = step + 1

Next ==
  \/ EnterDegraded
  \/ BeginRecovery
  \/ \E p \in Privileges : Restrict(p)
  \/ Restore
  \/ Nop

Spec == Init /\ [][Next]_vars

(***************************************************************************)
(* Invariants                                                              *)
(***************************************************************************)

Inv_TypeOK == TypeOK

\* After a restore, held privi
...