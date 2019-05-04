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


% Total number of agents.
% The definition of agents is provided in agents.pl 
no_agents(N):-
    findall(X, agent(X, _), L), length(L, N).

% Q is implemented via a list of sets of propositions.
% The single propositions should be provided in states.pl .
props(Propositions):-
    sort(Propositions, Propositions),
    is_set(Propositions),
    maplist(prop, Propositions).

state(Proposition_List):-
    is_list(Proposition_List),
    length(Proposition_List, Proposition_Length),
    no_agents(Proposition_Length),
    maplist(props, Proposition_List).

% Given an agent and a state, return the subset of the propositions that concern that specific agent
agent_state(Agent, State, AgentState):-
    agent(Agent, Id),
    State = state(_),
    nth0(Id, State, AgentState).

joint_action(Actions):-
    is_list(Actions),
    no_agents(N),
    length(Actions, N),
    maplist(action, Actions).

% Utility function for replacing single properties in agents

% substitute(List)
