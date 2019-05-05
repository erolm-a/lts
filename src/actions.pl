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

% transition functions are defined in the following manner:
%
% transitate_(State, joint_action, NewState):- ...

% when none of the two agents acts they might die
transitate_(State, [doNothingH, doNothingC], NewState, Valutations):-
    % If one of the two does not have insulin, that person will die

    ValutationTemp = [],
    agent_state("Hal", State, HalState),
    agent_state("Carla", State, CarlaState),
    (
        (member(isAlive, HalState), \+ member(hasInsulin, HalState)) ->
            (
                ord_del_element(HalState, isAlive, HalStatePrime),
                demote(lifeHal, DemotedHalLife),
                append(ValutationTemp, DemotedHalLife, ValuationTemp2)
            ) ; (
                HalStatePrime = HalState,
                ValutationTemp2 = ValutationTemp
            )
    ),
    (
        (member(isAlive, CarlaState), \+ member(hasInsulin, CarlaState)) ->
            (
                ord_del_element(CarlaState, isAlive, CarlaStatePrime),
                demote(lifeCarla, DemotedCarlaLife),
                append(ValutationTemp2, DemotedCarlaLife, Valutations)
            ); (
                CarlaStatePrime = CarlaState,
                Valutations = ValutationsTemp2
            )
    ),
    agent("Hal", IdHal),
    agent("Carla", IdCarla),
    substitute(State, IdHal, HalStatePrime, NewStatePrime),
    substitute(NewStatePrime, IdCarla, CarlaStatePrime, NewState).

transitate_(State, [takeH, doNothingC], NewState, []):-
    toggle_property("Hal", State, hasInsulin, NewStatePrime),
    toggle_property("Carla", NewStatePrime, hasInsulin, NewState).

transitate_(State, [doNothingH, buyC], NewState, [DemotedFreedomCarla]):-
    toggle_property("Carla", State, hasMoney, NewStatePrime),
    toggle_property("Carla", NewStatePrime, hasInsulin, NewState),
    demote(freedomCarla, DemotedFreedomCarla).

transitate_(State, [compensateH, doNothingC], NewState, [DemotedFreedomHal]):-
    toggle_property("Hal", State, hasMoney, NewStatePrime),

    % If Carla lacks of insulin then provide it to her, otherwise she lacks the money
    (
    \+ check_property_of_agent("Carla", NewStatePrime, hasInsulin) *->
        toggle_property("Carla", NewStatePrime, hasInsulin, NewState);
        toggle_property("Carla", NewStatePrime, hasMoney, NewState)
    ),

    demote(freedomHal, DemotedFreedomHal).
