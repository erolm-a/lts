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


% The agents are defined here
% As a generalization, every agent will have a unique id that is useful for defining the states

aats_agent("Hal", 0).
aats_agent("Carla", 1).

% total number of agents
no_agents(N):-
    findall(X, aats_agent(X, _), L), length(L, N).

% Q is implemented via a list of sets of propositions.

aats_prop(isAlive).
aats_prop(hasInsulin).
aats_prop(hasMoney).

aats_props(Propositions):-
    sort(Propositions, Propositions),
    is_set(Propositions),
    maplist(aats_prop, Propositions).

aats_state(Proposition_List):-
    is_list(Proposition_List),
    length(Proposition_List, Proposition_Length),
    no_agents(Proposition_Length),
    maplist(aats_props, Proposition_List).

% Given an agent and a state, return the subset of the propositions that concern that specific agent
aats_agent_state(Agent, State, AgentState):-
    aats_agent(Agent, Id),
    State = aats_state(_),
    nth0(Id, State, AgentState).

% Define your actions (and their behaviour) here...
aats_action(takeH).
aats_action(doNothingC).
aats_action(doNothingH).
aats_action(buyC).
aats_action(compensateH).

aats_joint(Actions):-
    is_list(Actions),
    no_agents(N),
    length(Actions, N),
    maplist(aats_action, Actions).

% preconditions

aats_check(State, takeH):-
    aats_agent_state("Hal", State, HalState),
    member(isAlive, HalState).

% doNothing are trivially true forever, however
aats_check(State, doNothingC):- State = aats_state(_).

aats_check(State, doNothingH):- State = aats_state(_).

aats_check(State, buyC):-
    aats_agent_state("Carla", State, CarlaState),
    member(hasMoney, CarlaState),
    member(isAlive, CarlaState).

aats_check(State, takeH):-
    aats_agent_state("Hal", State, HalState),
    aats_agent_state("Carla", State, CarlaState),
    member(isAlive, HalState),
    member(hasInsulin, CarlaState).
    
aats_check(State, compensateH):-
    aats_agent_state("Hal", State, HalState),
    aats_agent_state("Carla", State, CarlaState),
    member(isAlive, HalState),
    member(hasInsulin, CarlaState).

aats_perform_action(State, doNothingH, State).
aats_perform_action(State, doNothingC, State).
aats_perform_action(State, takeH, NewState):-
    aats_check(State, takeH),
    aats_agent_state("Hal")

