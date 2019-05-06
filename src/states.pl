% Copyright (C) 2019 by Enrico Trombetta

% propositions are simply defined with the prop functor

prop(hasInsulin).
prop(hasMoney).
prop(isAlive).

% states are list of predicates. The order depends on the numbering of the agents.
% See agents.pl for details.

% The initial state should be called initial_state.
%
% The format is: initial_state(X):- X = state([], [], ...)
% where each of the lists must be a sorted set.
%
% Here are some example, if we follow the semantics of the paper and the Diabetes example
%
% Both Carla and Hal are poor, the ending won't be good
poor_both(State):-
    state(State) = state([[isAlive], [hasInsulin, isAlive]]).

% Hal is poor, Carla is rich
poor_hal(State):-
    state(State) = state([[isAlive], [hasInsulin, hasMoney, isAlive]]).

% Hal has the money but still cannot buy the insulin (he never does!). Carla is poor
poor_carla(State):-
    state(State) = state([[hasMoney, isAlive], [hasInsulin, isAlive]]).

% Both Hal and Carla are rich.
rich_both(State):-
    state(State) = state([[hasMoney, isAlive], [hasInsulin, hasMoney, isAlive]]).

initial_state(State):-
    poor_hal(State).
/*
% It is important to define a final state.
% For example, Hal and Carla could iterate (doNothing, doNothing) once they reach a leaf.
% final states have the following semantics:
% 
% final_state(State) where state(State) is a valid state.
%
% In this example, a final state is reached if either one of the two agents is dead or both the two
% agents have insulin.

final_state(State):-
    \+ both_alive(State).

final_state(State):-
    both_alive(State),
    check_property_of_agent("Hal", State, hasInsulin),
    check_property_of_agent("Carla", State, hasInsulin).

both_alive(State):-
    check_property_of_agent("Hal", State, isAlive),
    check_property_of_agent("Carla", State, isAlive).
*/
