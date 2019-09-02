/*
 Implementation of an Action-Based Alternating Transition Systems
 
 @author Francesco Perrone
 @author Enrico Trombetta
 @license GPLv3
 
 An AATS is defined by the following tuple:
 - a set of states Q
 - a set of agents Ag{1..n}
 - a set of actions*
 - a precondition function p for each action
 - a transition function t
 - a (global) set of atomic propositions
 - a (per-agent) set of values
 - an interpretation function
 - a valuation function delta which defines the status of a value after a transition

 * The original paper distinguishes between single actions and joint actions.
   A path of the AATS works on joint actions only, even though this is perfectly
   obvious and equivalent with other conventions (see LTS and LTS.pl)


  DO NOT MODIFY THIS BY GROUNDING TERMS!!!
*/

use(library(ordsets)).

%!  no_agents(-N:int) is det.
%
%   True if N is the number of agents defined in agents.pl
no_agents(N):-
    findall(X, agent(X, _), L), length(L, N).

%!  no_propositions(-N:int) is det.
%
%   True if N is the number of propositions defined in propositions.pl
no_propositions(N):-
    findall(X, proposition(X, _), L), length(L, N).

%!  agent_state(+Proposition_List) is det.
%!  agent_state(?Proposition_List) is nondet.
%!  agent_state(-Proposition_List) is multi.
%
%   True if Proposition_List is a state of a single agent, that is it gives
%   an interpretation for each proposition that applies to the agent.
agent_state(List):-
    no_propositions(N),
    length(List, N),
    check_domain(List, 0).

check_domain([], N):-
    no_propositions(N).

check_domain([Head|Rest], N):-
    proposition(Prop, N),
    domain(Prop, Domain),
    member(Head, Domain),
    Nincr is N+1,
    check_domain(Rest, Nincr).

%!  state(+Agent_States:list) is det.
%!  state(?Agent_States:list) is nondet.
%!  state(-Agent_States:list) is multi.
%
%   True if Agent_States is a list of agent states.
%   Each element of Agent_States must satisfy state_of_agent/1
%   If Agent_States is (partially) unbound then state generates every possible state.
%
%   @see agent_state/1
state(Agent_States):-
    no_agents(N),
    length(Agent_States, N),
    maplist(agent_state, Agent_States).

% values should be defined in values.pl
promote(Value):-
    value(Value).

demote(Value):-
    value(Value).

%!  values(+List) is det
%   True if List is made only of promotions and demotions, i.e. instantiations of promote or demote 
values(List):-
    maplist(either_, List).

either_(Value):-
    Value = promote(_) ; Value = demote(_).
    


% transitate(?State:List, ?Joint:List, -NewState:List, -Valuations:List) is nondet
%
% True if there is a transition between State and NewState through the joint
% action Joint which bring the valuations Valuations.
%
% State, NewState must both satisfy the predicate state/1,
% Joint is an instantiation of joint/1, defined in actions.pl .
% Each element in Valuations must either satisfy the predicates
% promote/1 or demote/1
transitate(State, Joint, NewState, Valuations):-
    state(State),
    joint(Joint),
    check_precondition_(State, Joint),
    transition(State, Joint, NewState, Valuations).

% check_precondition_(+State:List, +Actions:List) is semidet
% True if each action in Actions can be performed on the state State.
%
% See the documentation of transitate for the types of State and Actions
check_precondition_(_, []).
check_precondition_(State, [Action|T]):-
    precondition(Action, State),
    check_precondition_(State, T).

%!  path(+CurrentState, -PathTrail) is multi.
%   
%   True if PathTrail is a path in the current aats.
%   
%
%

path(CurrentState, [[CurrentState, Joint, Values]|PathTrail]):-
    transitate(CurrentState, Joint, NewState, Values),
    CurrentState \= NewState,
    path(NewState, PathTrail).

% As a simple way to avoid loops, if a transition 
path(CurrentState, [CurrentState]):-
    transitate(CurrentState, _, NewState, _),
    CurrentState = NewState.

% A path is ended if we reached a dead end.
path(CurrentState, [CurrentState]):-
    \+ transitate(CurrentState, _, _, _).
