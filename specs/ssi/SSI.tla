------------------------------- MODULE SSI -------------------------------
(***************************************************************************)
(* Simplified SSI lifecycle: bind / revoke / rotate.                       *)
(*                                                                         *)
(* Models abstract identity bindings.  No cryptography is present.         *)
(*                                                                         *)
(* Properties of interest:                                                 *)
(*   - A revoked binding cannot be treated as active.                      *)
(*   - Rotate replaces the previous active binding.                        *)
(*                                                                         *)
(* Limitations: see docs/limitations.md.                                   *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, AICTypes

CONSTANTS
  MaxSteps

ASSUME MaxSteps \in Nat /\ MaxSteps > 0

VARIABLES
  step,
  active,          \* set of currently active identity bindings
  revoked,         \* set of revoked identities (cannot be active)
  history          \* sequence of operation labels for inspection

vars == <<step, active, revoked, history>>

Ops == {"bind", "revoke", "rotate", "nop"}

TypeOK ==
  /\ step \in 0..MaxSteps
  /\ active \subseteq Identities
  /\ revoked \subseteq Identities
  /\ active \cap revoked = {}          \* maintained by actions; also an invariant
  /\ history \in Seq(Ops)

Init ==
  /\ step = 0
  /\ active = {}
  /\ revoked = {}
  /\ history = << >>

(***************************************************************************)
(* Bind: add an identity that is not currently revoked.                    *)
(***************************************************************************)
Bind(id) ==
  /\ step < MaxSteps
  /\ id \in Identities
  /\ id \notin revoked
  /\ id \notin active
  /\ active' = active \cup {id}
  /\ UNCHANGED revoked
  /\ history' = Append(history, "bind")
  /\ step' = step + 1

(***************************************************************************)
(* Revoke: move an identity from active (or even inactive) into revoked.   *)
(* Once revoked it stays out of active until a future policy allows        *)
(* re-bind (not modeled here beyond the set separation).                   *)
(***************************************************************************)
Revoke(id) ==
  /\ step < MaxSteps
  /\ id \in Identities
  /\ active' = active \ {id}
  /\ revoked' = revoked \cup {id}
  /\ history' = Append(history, "revoke")
  /\ step' = step + 1

(***************************************************************************)
(* Rotate: replace oldId with newId.                                       *)
(* oldId is revoked; newId becomes active (if not already revoked).        *)
(***************************************************************************)
Rotate(oldId, newId) ==
  /\ step < MaxSteps
  /\ oldId \in active
  /\ newId \in Identities
  /\ newId \notin revoked
  /\ newId # oldId
  /\ active' = (active \ {oldId}) \cup {newId}
  /\ revoked' = revoked \cup {oldId}
  /\ history' = Append(history, "rotate")
  /\ step' = step + 1

Nop ==
  /\ step < MaxSteps
  /\ UNCHANGED <<active, revoked>>
  /\ history' = Append(history, "nop")
  /\ step' = step + 1

Next ==
  \/ \E id \in Identities : Bind(id)
  \/ \E id \in Identities : Revoke(id)
  \/ \E o, n \in Identities : Rotate(o, n)
  \/ Nop

Spec == Init /\ [][Next]_vars

(***************************************************************************)
(* Invariants                                                              *)
(***************************************************************************)

Inv_TypeOK == TypeOK

\* A revoked identity is never active.
Inv_RevokedNotActive ==
  active \cap revoked = {}

\* After a rotate that mentions oldId, oldId is not active.
\* (Global form: no identity is both active and revoked — already above.)
Inv_RotateReplaces ==
  \A id \in Identities :
    id \in 
...