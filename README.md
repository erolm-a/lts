# Labelled Transition System

**Authors**: [Enrico Trombetta](mailto:2396702t@student.gla.ac.uk), [Francesco Perrone](mailto:Francesco.Perrone@glasgow.ac.uk)

> In theoretical computer science, a **transition system** is a concept used in the study of computation. It is used to describe the potential behavior of discrete systems. It consists of states and transitions between states, which may be labeled with labels chosen from a set; the same label may appear on more than one transition. If the label set is a singleton, the system is essentially unlabeled, and a simpler definition that omits the labels is possible.

Taken from Wikipedia.

This is the scenario I've started working on:

> The problem involves two agents, Hal and Carla. Hal, diabetic, lost his insulin by accident and urgently needs to take some to stay alive. He doesn't have enough time to buy a new supply, but he knows that Carla keeps some insulin at home, very close by. Hal doesn't have permission to access Carla's property, besides Hal knows that Carla is diabetic too and he might be putting her life in danger by taking her supply. On the other hand, Hal believes that Carla may be able to buy some insulin later on.

A brief discussion about this scenario can be found in `notes/LTS_insulin.pdf` (LaTex source is available under the `src` folder).

An implementation sketch is provided in `src/LTS.pl` in Prolog (in particular, we decided to adopt [SWI Prolog](http://www.swi-prolog.org/)).

To invoke a path, load the knowledgebase in the interpreter, load the initial state and execute a path.

For example:

```Prolog
?- [LTS].
initial_state(InitialState), path(InitialState, Path).
InitialState = ...
Path = ...
[And a bunch of alternative paths]
true.

?- initial_state(InitialState), tree(InitialState, Tree).
InitialState = ...
Tree = ...
true.
```

The latter command should return a parsable tree which can then be parsed and converted in a TikZ image.

Milestone:

[ ] Finish the LTS implementation of the tree function.

[ ] Implement a parser

[ ] Improve the discussion of the LTS

[ ] Add labeling to transitions.

[ ] ...
