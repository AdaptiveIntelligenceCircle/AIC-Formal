---------------------- MODULE GovernanceEvaluate ----------------------
(***************************************************************************)
(* Governance evaluation sketch.                                           *)
(*                                                                         *)
(* Extends the same Decision vocabulary as the Ethical Kernel.             *)
(* Adds a minimal notion of a governance proposal and a succession flag.   *)
(*                                                                         *)
(* Intent:                                                                 *)
(*   - Governance decisions also respect fail-closed and human gate.       *)
(*   - Succession is an explicit state change, not an implicit privilege.  *)
(*                                                                         *)
(* This is a sketch only.  See docs/limitations.md.                        *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, AICTypes

CONSTANTS
  MaxSteps,
  Proposals          \* abstract proposal identifiers

ASSUME MaxSteps \in Nat /\ MaxSteps > 0
ASSUME IsFiniteSet(Proposals)

VARIABLES
  step,
  currentDecision,
  humanConfirmed,
  activeProposal,
  successionMode,    \* TRUE when succession procedure is active
  history

vars == <<step, currentDecision, humanConfirmed, activeProposal,
          successionMode, history>>

Null == "Null"

TypeOK ==
  /\ step \in 0..MaxSteps
  /\ currentDecision \in Decision \cup {Null}
  /\ humanConfirmed \in BOOLEAN
  /\ activeProposal \in Proposals \cup {Null}
  /\ successionMode \in BOOLEAN
  /\ history \in Seq(Decision \cup {"succession_enter", "succession_exit"})

Init ==
  /\ step = 0
  /\ currentDecision = Null
  /\ humanConfirmed = FALSE
  /\ activeProposal = Null
  /\ successionMode = FALSE
  /\ history = << >>

(***************************************************************************)
(* Submit a governance proposal for evaluation.                            *)
(***************************************************************************)
SubmitProposal(p) ==
  /\ step < MaxSteps
  /\ activeProposal = Null
  /\ p \in Proposals
  /\ ~successionMode          \* ordinary proposals blocked during succession
  /\ activeProposal' = p
  /\ currentDecision' = CHOOSE d \in Decision : TRUE
  /\ humanConfirmed' = FALSE
  /\ history' = Append(history, currentDecision')
  /\ UNCHANGED successionMode
  /\ step' = step + 1

HumanConfirm ==
  /\ step < MaxSteps
  /\ currentDecision = "NeedHuman"
  /\ ~humanConfirmed
  /\ humanConfirmed' = TRUE
  /\ UNCHANGED <<activeProposal, currentDecision, successionMode, history>>
  /\ step' = step + 1

PostHumanDecision ==
  /\ step < MaxSteps
  /\ currentDecision = "NeedHuman"
  /\ humanConfirmed
  /\ \E d \in Decision :
       /\ currentDecision' = d
       /\ history' = Append(history, d)
  /\ humanConfirmed' = FALSE
  /\ activeProposal' = Null
  /\ UNCHANGED successionMode
  /\ step' = step + 1

Clear ==
  /\ step < MaxSteps
  /\ currentDecision \in {"Allow", "Deny"}
  /\ activeProposal' = Null
  /\ currentDecision' = Null
  /\ humanConfirmed' = FALSE
  /\ UNCHANGED <<successionMode, history>>
  /\ step' = step + 1

(***************************************************************************)
(* Succession: explicit enter / exit.  No automatic privilege gain.        *)
(***************************************************************************)
EnterSuccession ==
  /\ step < MaxSteps
  /\ ~successionMode
  /\ activeProposal = Null
  /\ successionMode' = TRUE
  /\ history' = Append(history, "succession_enter")
  /\ UNCHANGED <<currentDecision, humanConfirmed, activeProposal>>
  /\ step' = step + 1

ExitSuccession ==
  /\ step < MaxSteps
  /\ successionMode
  /\ successionMode' = FALSE
  /\ history' = Append(history, "succession_exit")
  /\ UNCHANGED <<currentDecision, humanConfirmed, activeProposal>>
  /\ step' = step + 1

Stutter ==
  /\ step < MaxSteps
  /\ UNCHANGED <<currentDecision, humanConfirmed, activeProposal,
                 successionMo
...