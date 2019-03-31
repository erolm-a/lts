% Author: Enrico Trombetta

% A Labelled Transition System is:
% - a collection of states
% - a collection of actions
% - a collection of transitions, i.e. a triplet (state, action, new state)
% States can really be anything but for us suppose that a state is a pair of
% sets of propositions.

% let's define a list of propositions, briefly referred to as "prop"'s.

% By now, we will implement the "insuline" scenario.

% use_module(library(csv)).

% Do I dispose of an insuline supply
prop(hasSupply).
% Am I still alive?
prop(isAlive).
% can I buy another supply?
prop(canBuy).

% prop_set(@Set) is nondet
% check (or generate) a set of predicates
prop_set(Set):-
    is_set(Set),
    maplist(prop, Set),
    sort(Set, Set).

% the basic state in a LTS
lts_state(HalState, CarlaState):-
    prop_set(HalState), prop_set(CarlaState).


% Let us define a set of actions

action('CarlaBuysSupply').
action('HalSteals').
action('HalDies').
action('CarlaDies').

% Hal must still be alive before dying
precondition('HalDies', lts_state(HalState, _)):-
    member(isAlive, HalState),
    not(member(canBuy, HalState)),
    not(member(hasSupply, HalState)).

% Similarly for Carla
precondition('CarlaDies', lts_state(_, CarlaState)):-
    member(isAlive, CarlaState),
    not(member(canBuy, CarlaState)),
    not(member(hasSupply, CarlaState)).

% Carla can buy another insuline supply if she is still alive.
precondition('CarlaBuysSupply', lts_state(_, CarlaState)):-
    member(isAlive, CarlaState),
    member(canBuy, CarlaState),
    not(member(hasSupply, CarlaState)).

% Hal can steal Carla's insuline supply if he is still alive Carla keeps another
% supply.
precondition('HalSteals', lts_state(HalState, CarlaState)):-
    % Hal has to be alive but not Carla - nothing prevents Hal from looting
    member(isAlive, HalState),
    member(hasSupply, CarlaState),
    not(member(hasSupply, HalState)).

% Execution section
exec_action('HalDies', OldState, NewState):-
    OldState = lts_state(OldHalState, CarlaState),
    delete(OldHalState, isAlive, NewHalState),
    NewState = lts_state(NewHalState, CarlaState).

exec_action('CarlaDies', OldState, NewState):-
    OldState = lts_state(HalState, OldCarlaState),
    delete(OldCarlaState, isAlive, NewCarlaState),
    NewState = lts_state(HalState, NewCarlaState).

exec_action('CarlaBuysSupply', OldState, NewState):-
    OldState = lts_state(HalState, OldCarlaState),
    delete(OldCarlaState, canBuy, MiddleCarlaState),
    merge(MiddleCarlaState, [hasSupply], NewCarlaState),
    NewState = lts_state(HalState, NewCarlaState).

exec_action('HalSteals', OldState, NewState):-
    OldState = lts_state(OldHalState, OldCarlaState),
    merge(OldHalState, [hasSupply], NewHalState),
    delete(OldCarlaState, hasSupply, NewCarlaState),
    NewState = lts_state(NewHalState, NewCarlaState).


% before executing an action, check if it is acceptable
perform_action(Action, OldState, NewState):-
    action(Action),
    precondition(Action, OldState),
    exec_action(Action, OldState, NewState).

% in order to end the LTS from evolving to the infinite, put a braking
% clause
evolvable_state(lts_state(HalState, CarlaState)):-
    (member(isAlive, HalState), member(isAlive, CarlaState)),
    not((member(hasSupply, HalState), member(hasSupply, CarlaState))).

% In a LTS, a path is the projection of a sequence of transitions,
path(CurrentState, [CurrentState]):-
    not(evolvable_state(CurrentState)).

path(CurrentState, [CurrentState, action(Action)|PathTrail]):-
    perform_action(Action, CurrentState, NewState),
    path(NewState, PathTrail).

% convert a LTS path into a string.
% The idea is that a path should be expressable in csv format - even though the
% field number is not guaranteed to be the same.
%
% The serialization of a single state lts_state([P1, P2, ... Pi], [Q1, Q2, ..., Qj]) is:
% "P1,P2,...,Pi;Q1,Q2,...Qj" where ';' is a separator between the first and the second set.
% Nothing prevents the state to start or end with ; or even contain a single ; between
% the quotes.
% the serialization of an action is the string version of the atom representing an action,
% without quotes.
serialize(lts_state(A, B), Output):-
    !,
    atomics_to_string(A, ',', Serialized1_),
    string_concat(Serialized1_, ';', Serialized1),
    atomics_to_string(B, ',', Serialized2),
    string_concat('"', Serialized1, Prefix),
    string_concat(Serialized2, '"', Suffix),
    string_concat(Prefix, Suffix, Output).

serialize(action(Action), Output):-
    atom_string(Action, Output).

serialize([X], Output):-
    serialize(X, Output), !.

serialize([Head|Rest], Output):-
    serialize(Head, Out1_), !,
    string_concat(Out1_, ',', Out1),
    serialize(Rest, Out2), !,
    string_concat(Out1, Out2, Output).

% Serialize every possible LTS that are rooted by a given seed and writes down the results in a file.
export_tree(FileName, Seed):-
    open(FileName, write, OutStream),
    forall(path(Seed, Path), (
            serialize(Path, Output),
            write(OutStream, Output), nl(OutStream)
        )
    ),
    close(OutStream).

initial_state(lts_state([isAlive], [canBuy, hasSupply, isAlive])).
