---------------------------- MODULE Isolation ----------------------------
(***************************************************************************)
(* Parallel-net isolation and default-deny bridge.                         *)
(*                                                                         *)
(* Models a small number of nets and a bridge permission that is           *)
(* denied by default.  Cross-net influence requires an explicit            *)
(* bridge grant.                                                           *)
(*                                                                         *)
(* Limitations: see docs/limitations.md.                                   *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, AICTypes

CONSTANTS
  MaxSteps,
  Nets               \* set of parallel net identifiers

ASSUME MaxSteps \in Nat /\ MaxSteps > 0
ASSUME IsFiniteSet(Nets) /\ Nets # {}

VARIABLES
  step,
  bridgeGranted,     \* set of ordered pairs <<from, to>> that are allowed
  messages,          \* abstract messages that have crossed (for inspection)
  history

vars == <<step, bridgeGranted, messages, history>>

TypeOK ==
  /\ step \in 0..MaxSteps
  /\ bridgeGranted \subseteq (Nets \X Nets)
  /\ \A pair \in bridgeGranted : pair[1] # pair[2]   \* no self-bridge needed
  /\ messages \subseteq (Nets \X Nets)
  /\ history \in Seq(STRING)

Init ==
  /\ step = 0
  /\ bridgeGranted = {}          \* default-deny
  /\ messages = {}
  /\ history = << >>

(***************************************************************************)
(* Grant a bridge from one net to another (explicit permission).           *)
(***************************************************************************)
GrantBridge(from, to) ==
  /\ step < MaxSteps
  /\ from \in Nets /\ to \in Nets /\ from # to
  /\ bridgeGranted' = bridgeGranted \cup {<<from, to>>}
  /\ history' = Append(history, "grant")
  /\ UNCHANGED messages
  /\ step' = step + 1

(***************************************************************************)
(* Revoke a bridge.                                                        *)
(***************************************************************************)
RevokeBridge(from, to) ==
  /\ step < MaxSteps
  /\ <<from, to>> \in bridgeGranted
  /\ bridgeGranted' = bridgeGranted \ {<<from, to>>}
  /\ history' = Append(history, "revoke")
  /\ UNCHANGED messages
  /\ step' = step + 1

(***************************************************************************)
(* Attempt to send a cross-net message.                                    *)
(* Succeeds only if the bridge has been granted.                           *)
(***************************************************************************)
Send(from, to) ==
  /\ step < MaxSteps
  /\ from \in Nets /\ to \in Nets /\ from # to
  /\ IF <<from, to>> \in bridgeGranted
    THEN /\ messages' = messages \cup {<<from, to>>}
         /\ history' = Append(history, "send_ok")
    ELSE /\ UNCHANGED messages
         /\ history' = Append(history, "send_denied")
  /\ UNCHANGED bridgeGranted
  /\ step' = step + 1

Nop ==
  /\ step < MaxSteps
  /\ UNCHANGED <<bridgeGranted, messages>>
  /\ history' = Append(history, "nop")
  /\ step' = step + 1

Next ==
  \/ \E f, t \in Nets : GrantBridge(f, t)
  \/ \E f, t \in Nets : RevokeBridge(f, t)
  \/ \E f, t \in Nets : Send(f, t)
  \/ Nop

Spec == Init /\ [][Next]_vars

(***************************************************************************)
(* Invariants                                                              *)
(***************************************************************************)

Inv_TypeOK == TypeOK

\* Default-deny: a message appears only if a bridge was granted.
Inv_DefaultDenyBridge ==
  \A pair \in messages : pair \in bridgeGranted

\* Bridge relation never contains self-loops (by construction).
Inv_NoSelfBridge ==
  \A pair \in bridgeGranted : pair[1] # pair[2]

=============================================================================
\* AIC-Formal — Parallel-net i
...