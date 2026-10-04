---------------------------- MODULE AICTypes ----------------------------
(***************************************************************************)
(* Shared types and constants for AIC-Formal models.                       *)
(*                                                                         *)
(* These definitions are intentionally minimal. They exist so that         *)
(* multiple modules can refer to the same Decision vocabulary and          *)
(* basic identity concepts without duplication.                            *)
(***************************************************************************)

EXTENDS Naturals, Sequences, FiniteSets

(***************************************************************************)
(* Core decision type used by Ethical Kernel and Governance.               *)
(***************************************************************************)
Decision == {"Allow", "Deny", "NeedHuman"}

(***************************************************************************)
(* Abstract identity.  In real systems this would be backed by SSI         *)
(* credentials; here it is only a distinct name drawn from a finite set.   *)
(***************************************************************************)
CONSTANT Identities
ASSUME Identities \subseteq STRING \/ Identities \subseteq Nat
ASSUME IsFiniteSet(Identities)

(***************************************************************************)
(* Abstract action / request labels.                                       *)
(***************************************************************************)
CONSTANT Actions
ASSUME IsFiniteSet(Actions)

(***************************************************************************)
(* Helper: whether a decision is permissive.                               *)
(***************************************************************************)
IsPermissive(d) == d = "Allow"

IsRestrictive(d) == d \in {"Deny", "NeedHuman"}

(***************************************************************************)
(* Type correctness helper for Decision values.                            *)
(***************************************************************************)
IsDecision(d) == d \in Decision

=============================================================================
\* Modification History
\* Created for AIC-Formal — pre-Covenant, under-claim models