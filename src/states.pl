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
    State = state([isAlive], [hasInsulin, isAlive]).

% Hal is poor, Carla is rich
poor_hal(State):-
    State = state([[isAlive], [hasInsulin, hasMoney, isAlive]]).

% Hal has the money but still cannot buy the insulin (he never does!). Carla is poor
poor_carla(State):-
    State = state([[hasMoney, isAlive], [hasInsulin, isAlive]]).

% Both Hal and Carla are rich.
rich_both(State):-
    State = state([[hasMoney, isAlive], [hasInsulin, hasMoney, isAlive]]).

initial_state(State):-
    poor_hal(State).
