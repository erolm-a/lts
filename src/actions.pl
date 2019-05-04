% Copyright (C) 2019 by Enrico Trombetta

% Define your actions (and their behaviour) here...

action(takeH).
action(doNothingC).
action(doNothingH).
action(buyC).
action(compensateH).

% preconditions

precondition(State, takeH):-
    agent_state("Hal", State, HalState),
    member(isAlive, HalState).

% doNothing are trivially true forever
precondition(State, doNothingC):- State = state(_).

precondition(State, doNothingH):- State = state(_).

precondition(State, buyC):-
    agent_state("Carla", State, CarlaState),
    member(hasMoney, CarlaState),
    member(isAlive, CarlaState).

precondition(State, takeH):-
    agent_state("Hal", State, HalState),
    agent_state("Carla", State, CarlaState),
    member(isAlive, HalState),
    member(hasInsulin, CarlaState).
    
precondition(State, compensateH):-
    agent_state("Hal", State, HalState),
    agent_state("Carla", State, CarlaState),
    member(isAlive, HalState),
    member(hasInsulin, CarlaState).

perform_action(State, doNothingH, State).
perform_action(State, doNothingC, State).
/*perform_action(State, takeH, NewState):-
    precondition(State, takeH),
    agent_state("Hal").
*/
