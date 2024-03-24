Outside the range

------------------------ MODULE bridge_controller_m0 ------------------------

\*This is not outside range, hence can not be used as comment!
(*
This is a mult-line comment
*)

EXTENDS Integers, Naturals, Sequences, TLC
CONSTANT d, bound (* bound denotes the length of interleaving of events *)
AXIOM d \in Nat /\ d > 0


(*
--algorithm bridgeController_m0 {

    variable n=0, i=1;
    
    procedure ml_out() {
        ml_out_Invoked: 
        n := n +1;
        return;
    }
    
    procedure ml_in() {
        ml_in_Invoked:
        n := n-1;
        return;
    }
    
    
    {
        loop:
        while(i < bound) {
            either {
                if(TRUE) { 
                    ml_out_Invocation: call ml_out(); 
                }; 
            } or {
                if(n>0) {
                    call ml_in();
                };
            };
            loopValue: i := i+1;
        }
    }

}
*)
\* BEGIN TRANSLATION (chksum(pcal) = "67f130d" /\ chksum(tla) = "8445bf92")
VARIABLES n, i, pc, stack

vars == << n, i, pc, stack >>

Init == (* Global variables *)
        /\ n = 0
        /\ i = 1
        /\ stack = << >>
        /\ pc = "loop"

ml_out_Invoked == /\ pc = "ml_out_Invoked"
                  /\ n' = n +1
                  /\ pc' = Head(stack).pc
                  /\ stack' = Tail(stack)
                  /\ i' = i

ml_out == ml_out_Invoked

ml_in_Invoked == /\ pc = "ml_in_Invoked"
                 /\ n' = n-1
                 /\ pc' = Head(stack).pc
                 /\ stack' = Tail(stack)
                 /\ i' = i

ml_in == ml_in_Invoked

loop == /\ pc = "loop"
        /\ IF i < bound
              THEN /\ \/ /\ IF TRUE
                               THEN /\ pc' = "ml_out_Invocation"
                               ELSE /\ pc' = "loopValue"
                         /\ stack' = stack
                      \/ /\ IF n>0
                               THEN /\ stack' = << [ procedure |->  "ml_in",
                                                     pc        |->  "loopValue" ] >>
                                                 \o stack
                                    /\ pc' = "ml_in_Invoked"
                               ELSE /\ pc' = "loopValue"
                                    /\ stack' = stack
              ELSE /\ pc' = "Done"
                   /\ stack' = stack
        /\ UNCHANGED << n, i >>

loopValue == /\ pc = "loopValue"
             /\ i' = i+1
             /\ pc' = "loop"
             /\ UNCHANGED << n, stack >>

ml_out_Invocation == /\ pc = "ml_out_Invocation"
                     /\ stack' = << [ procedure |->  "ml_out",
                                      pc        |->  "loopValue" ] >>
                                  \o stack
                     /\ pc' = "ml_out_Invoked"
                     /\ UNCHANGED << n, i >>

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == pc = "Done" /\ UNCHANGED vars

Next == ml_out \/ ml_in \/ loop \/ loopValue \/ ml_out_Invocation
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(pc = "Done")

\* END TRANSLATION 

\* model variables
inv0_1 == n \in Nat
inv0_2 == n <= d

ML_in_event_guard == TRUE
ML_out_event_guard == TRUE
deadlock_free == ML_in_event_guard \/ ML_out_event_guard

=============================================================================
\* Modification History
\* Last modified Sun Mar 24 21:55:48 IST 2024 by Tisan
\* Created Mon Mar 18 21:27:49 IST 2024 by Tisan


This is also outside the range, and can be used for comment
