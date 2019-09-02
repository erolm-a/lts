%!  serialize(+Run, -Output) is det.
%
%   True if Run is a path (i.e. satisfies `path/2`) and Output is the serialization of Run.
%
% serialize a joint
serialize(Joint, Output):-
    joint(Joint),
    maplist(atom_string, Joint, JointStringList),
    interleave_and_concat(JointStringList, ';', Output), !.

% serialize a valuation
serialize(Values, Output):-
    values(Values),
    maplist(convert_value, Values, ValueStringList),
    interleave_and_concat(ValueStringList, ';', Output), !.

% Serialize a state
serialize(CurrentState, Output):-
    state(CurrentState),
    maplist(number_list_to_string, CurrentState, TranslatedState),
    interleave_and_concat(TranslatedState, ';', Output), !.

serialize([FinalState], Output):-
    serialize(FinalState, Output), !.

% General case
serialize([[CurrentState, JointAction, Values] | Tail], Output):-
    serialize(CurrentState, CurrentStateString),
    serialize(JointAction, JointActionString),
    serialize(Values, ValueString),
    interleave_and_concat([CurrentStateString, JointActionString, ValueString], ':', EvolutionString),
    serialize(Tail, RestOutput),
    interleave_and_concat([EvolutionString, RestOutput], ',', Output).


number_list_to_string(AtomList, Result):-
    maplist(atom_number, AtomStrings_, AtomList),
    reverse(AtomStrings_, AtomStrings),
    foldl(string_concat, AtomStrings, '', Result).

%!  convert_value(+Valuation, -Output) is det.
convert_value(promote(Valuation), Output):-
    atom_string(Valuation, String),
    string_concat(String, '+', Output).

convert_value(demote(Valuation), Output):-
    atom_string(Valuation, String),
    string_concat(String, '-', Output).


%! interleave(+List, +Element, -OutputList) is det.
%
%  True if OutputList is an inteleaved version of List, that is it follows this format:
%
%  List = [L1, L2, ..., Ln-1, Ln]
%  OutputList = [L1, Element, L2, ..., Ln-1, Element, Ln]
%
interleave([], _, []):- !.

interleave([X], _, [X]):- !.

interleave([Head|Tail], Separator, [Head, Separator|OutputTail]):-
    interleave(Tail, Separator, OutputTail).

%!  interleave_and_concat(+List, +Separator:String, -Output:String) is det.
%   True when List is interleaved with a separator and the resulting string
%   list is then concatenated into the Output string
interleave_and_concat(List, Separator, Output):-
    interleave(List, Separator, Interleaved_),
    % Apparently foldl/4 pops the list from the end rather than from the beginning,
    % causing the resulting string to have its components reversed.
    reverse(Interleaved_, Interleaved),
    foldl(string_concat, Interleaved, '', Output).


% export_tree(+FileName:string, ?InitialState) is semidet
%
% True wen serializes every possible path that is rooted by a given InitialState and writes down the results in a file.
% If InitialState is not grounded then every suitable InitialState will be instantiated
export_tree(FileName):-
    open(FileName, write, OutStream),
    forall(path(_, Path), (
        serialize(Path, Output),
        write(OutStream, Output), nl(OutStream)
        )
    ),
    close(OutStream).
