% Copyright (C) 2019 by Enrico Trombetta

% The format of the action is simple:
% action(action_name, agent) where both action_name and agent are atoms.

% Define your actions (and their behaviour) here...

action(takeH, "Hal").
action(doNothingC, "Carla").
action(doNothingH, "Hal").
action(buyC, "Carla").
action(compensateH, "Hal").

% doNothing are trivially true forever
precondition_(doNothingC, _).
precondition_(doNothingH, _).

precondition_(buyC, State):-
    check_property_of_agent("Carla", State, isAlive), !,
    check_property_of_agent("Carla", State, hasMoney), !.

precondition_(takeH, State):-
    check_property_of_agent("Hal", State, isAlive), !,
    check_property_of_agent("Carla", State, hasInsulin), !.
    
precondition_(compensateH, State):-
    check_property_of_agent("Hal", State, isAlive), !,
    check_property_of_agent("Hal", State, hasMoney), !,
    check_property_of_agent("Carla", State, isAlive), !,
    (
        \+ check_property_of_agent("Carla", State, hasInsulin);
        \+ check_property_of_agent("Carla", State, hasMoney)
    ).

/*
perform_action(State, doNothingH, State).
perform_action(State, doNothingC, State).

% Hal takes Carla's insulin
perform_action(State, takeH, NewState):-
    precondition(State, takeH), !,
    toggle_property_to_agent("Hal", State, hasInsulin, NewState_), !,
    toggle_property_to_agent("Carla", NewState_, hasInsulin, NewState), !.

perform_action(State, compensateH, 
*/


transitate_(State, [doNothingH, doNothingC], NewState):-
    % If one of the two does not have insulin, that person will die
    agent_state("Hal", State, HalState),
    agent_state("Carla", State, CarlaState),
    (
        (member(isAlive, HalState), \+ member(hasInsulin, HalState)) ->
            ord_del_element(HalState, isAlive, HalStatePrime) ; HalStatePrime = HalState
    ),
    (
        (member(isAlive, CarlaState), \+ member(hasInsulin, CarlaState)) ->
            ord_del_element(CarlaState, isAlive, CarlaStatePrime) ; CarlaStatePrime = CarlaState
    ),
    agent("Hal", IdHal),
    agent("Carla", IdCarla),
    substitute(State, IdHal, HalStatePrime, NewStatePrime),
    substitute(NewStatePrime, IdCarla, CarlaStatePrime, NewState).

transitate_(State, [takeH, doNothingC], NewState):-
    toggle_property("Hal", State, hasInsulin, NewStatePrime),
    toggle_property("Carla", NewStatePrime, hasInsulin, NewState).

transitate_(State, [doNothingH, buyC], NewState):-
    toggle_property("Carla", State, hasMoney, NewStatePrime),
    toggle_property("Carla", NewStatePrime, hasInsulin, NewState).

transitate_(State, [compensateH, doNothingC], NewState):-
    toggle_property("Hal", State, hasMoney, NewStatePrime),

    % If Carla lacks of insulin then provide it to her, otherwise she lacks the money
    \+ check_property_of_agent("Carla", NewStatePrime, hasInsulin) *->
        toggle_property("Carla", NewStatePrime, hasInsulin, NewState);
        toggle_property("Carla", NewStatePrime, hasMoney, NewState).
