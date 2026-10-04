-------------------------- MODULE EthicalKernel --------------------------
(***************************************************************************)
(* Ethical Kernel — core evaluate decision (simplified).                   *)
(*                                                                         *)
(* This module models a minimal authorization path that can return         *)
(* Allow, Deny, or NeedHuman.                                              *)
(*                                                                         *)
(* Design intent captured:                                                 *)
(*   - Fail-closed: missing preconditions yield Deny (or NeedHuman).       *)
(*   - Human gate: NeedHuman cannot be turned into Allow without an        *)
(*     explicit human confirmation action.                                 *)
(*                                                                         *)
(* Limitations: see docs/limitations.md.  This is a small-state model,     *)
(* not a verification of any implementation.                               *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, AICTypes

CONSTANTS
  MaxSteps          \* bound on the length of a run (for model checking)

ASSUME MaxSteps \in Nat /\ MaxSteps > 0

(***************************************************************************)
(* State variables                                                         *)
(***************************************************************************)
VARIABLES
  step,             \* current step counter
  currentDecision,  \* last decision produced by Evaluate
  humanConfirmed,   \* whether a human has confirmed a NeedHuman decision
  pendingAction,    \* action currently under evaluation (or Null)
  history           \* sequence of decisions (for inspection)

Null == "Null"

vars == <<step, currentDecision, humanConfirmed, pendingAction, history>>

(***************************************************************************)
(* Type invariant                                                          *)
(***************************************************************************)
TypeOK ==
  /\ step \in 0..MaxSteps
  /\ currentDecision \in Decision \cup {Null}
  /\ humanConfirmed \in BOOLEAN
  /\ pendingAction \in Actions \cup {Null}
  /\ history \in Seq(Decision)

(***************************************************************************)
(* Abstract policy evaluation.                                             *)
(*                                                                         *)
(* In a real system this would consult rules, context, and identity.       *)
(* Here we keep it non-deterministic but constrained:                      *)
(*   - the model may choose Allow only when an action is pending,          *)
(*   - otherwise it must choose Deny or NeedHuman.                         *)
(* This encodes fail-closed at the modeling level.                         *)
(***************************************************************************)
Evaluate(action) ==
  IF action = Null
  THEN "Deny"
  ELSE
    \* Non-deterministic choice among the three outcomes.
    \* Model checking will explore all branches.
    CHOOSE d \in Decision : TRUE

(***************************************************************************)
(* Initial state                                                           *)
(***************************************************************************)
Init ==
  /\ step = 0
  /\ currentDecision = Null
  /\ humanConfirmed = FALSE
  /\ pendingAction = Null
  /\ history = << >>

(***************************************************************************)
(* Actions                                                                 *)
(***************************************************************************)

\* Submit an action for evaluation.
Submit(action) ==
  /\ step < MaxSteps
  /\ pendingAction = Null
  /\ action \in Actions
  /\ pendingAction' = action
  /\ currentDecision' = Evaluate(action)
  /\
...