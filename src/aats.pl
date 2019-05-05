% Implementation of an Action-Based Alternating Transition Systems
%
% Copyright 2019 (C) Enrico Trombetta
%

% An AATS is defined by the following tuple:
% - a set of states Q
% - a set of agents Ag{1..n}
% - a set of actions*
% - a precondition function p for each action
% - a transition function t
% - a (global) set of atomic propositions
% - a (per-agent) set of values
% - an interpretation function
% - a valuation function delta which defines the status of a value after a transition
%
% * The original paper distinguishes between single actions and joint actions.
%   A path of the AATS works on joint actions only, even though this is perfectly
%   obvious and equivalent with other conventions (see LTS and LTS.pl)


% DO NOT MODIFY THIS BY GROUNDING TERMS!!!
% The files agents.pl, states.pl and actions.pl are made specifically for that.

use(library(ordsets)).

% Total number of agents.
% The definition of agents is provided in agents.pl 
no_agents(N):-
    findall(X, agent(X, _), L), length(L, N).

% Q is implemented via a list of sets of propositions.
% The single propositions should be provided in states.pl .
props(Propositions):-
    is_ordset(Propositions),
    maplist(prop, Propositions).

state(Proposition_List):-
    is_list(Proposition_List),
    length(Proposition_List, Proposition_Length),
    no_agents(Proposition_Length),
    maplist(props, Proposition_List).

% Given an agent and a state, return the subset of the propositions that concern that specific agent
agent_state(Agent, State, AgentState):-
    agent(Agent, Id),
    state(State),
    nth0(Id, State, AgentState).

% The actions, their preconditions and transitions should be grounded in actions.pl

% A joint action is an ordered tuple of actions of the single agents. Each agent can execute
% only one action at a time.
%
joint_action(Actions):-
    is_list(Actions),
    no_agents(N),
    length(Actions, N),
    check_joint_(Actions, 0).

check_joint_([H|T], Index):-
    agent(Agent, Index),
    action(H, Agent),
    ( length(T, N),
        N > 0 *-> (
            IndexIncr is Index+1,
            check_joint_(T, IndexIncr)
        ) ; true
    ).


% Utility function for replacing single elements in lists
substitute(State, Index, NewElement, NewList):-
    substitute_(State, Index, NewElement, NewList).

substitute_([_|T], 0, NewElement, NewList):-
    append([NewElement], T, NewList).

substitute_([H|T], Index, NewElement, NewList):-
    Index_decr is Index-1,
    substitute_(T, Index_decr, NewElement, NewList_substituted), !,
    append([H], NewList_substituted, NewList).

check_property_of_agent(Agent, State, Property):-
    agent_state(Agent, State, AgentState), !,
    ord_memberchk(Property, AgentState), !.

toggle_property(Agent, State, Property, NewState):-
    agent(Agent, Id),
    agent_state(Agent, State, AgentState),
    (
        ord_memberchk(Property, AgentState) -> ord_del_element(AgentState, Property, NewAgentState)
                                            ;  ord_add_element(AgentState, Property, NewAgentState)
    ),
    substitute(State, Id, NewAgentState, NewState).


precondition(Action, State):-
    action(Action, _),
    state(State),
    precondition_(Action, State).

% A transition function gives a new state
transitate(State, Joint, NewState):-
    state(State),
    joint_action(Joint),
    check_precondition_(State, Joint),
    transitate_(State, Joint, NewState),
    state(NewState).

check_precondition_(_, []).
check_precondition_(State, [Action|T]):-
    precondition(Action, State),
    check_precondition_(State, T).

