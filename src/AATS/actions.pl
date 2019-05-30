% @author Francesco Perrone
% @author Enrico Trombetta

% The format of the action is simple:
% action(action_name, agent) where both action_name and agent are atoms.

action(takeH, "Hal").
action(doNothingC, "Carla").
action(doNothingH, "Hal").
action(buyC, "Carla").
action(compensateH, "Hal").

% joint actions 
joint([doNothingH, doNothingC]).
joint([doNothingH, buyC]).
joint([compensateH, doNothingC]).
joint([takeH, doNothingC]).

precondition(doNothingC,  _).
precondition(doNothingH,  _).
precondition(buyC,        [[_, _, _], [0, 1, 1]]).
precondition(takeH,       [[0, _, 1], [1, _, _]]).
precondition(compensateH, [[1, 1, 1], [0, _, 1]]).
precondition(compensateH, [[1, 1, 1], [1, 0, 1]]).

% transition functions are defined in the following manner:
% transitate_(State, joint_action, NewState):- ...

% when none of the two agents acts one of them might die
transition([[0, M, 1], CarlaState],[doNothingH, doNothingC], [[0, M, 0], CarlaState],
                                   [demote(lifeHal)]).
transition([HalState, [0, N, 1]],  [doNothingH, doNothingC], [HalState, [0, N, 0]],
                                   [demote(lifeCarla)]).
% If both are dead just loop
transition([[0, A, 0], [0, B, 0]], [doNothingH, doNothingC], [[0, A, 0], [0, B, 0]], []).

% If one of them is alive the path simply terminates

% Hal steals the insulin from Carla
transition([[0, M, 1], [1, N, A]], [takeH, doNothingC]     , [[1, M, 1], [0, N, A]],
                                   []).

% Carla buys the insulin
transition([HalState,  [0, 1, 1]], [doNothingH, buyC]      , [HalState, [1, 0, 1]],
                                   [demote(freedomCarla)]).

% Hal may compensate Carla if he has the money.
transition([[1, 1, 1], [0, M, 1]], [compensateH, doNothingC],[[1, 0, 1], [1, M, 1]],
                                   [demote(freedomHal)]).
transition([[1, 1, 1], [1, 0, 1]], [compensateH, doNothingC],[[1, 0, 1], [1, 1, 1]],
                                   [demote(freedomHal)]).
