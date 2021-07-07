%%%% -*- Mode: Prolog -*-

%%%% Ponti Federico  817395


%%%% json_parse

json_parse(JSONString, Object) :-
    is_object(JSONString, Object, NextChars),
    !,
    NextChars = [].

json_parse(JSONString, Obj) :-
    string_codes(JSONString, Codes),
    is_array(Codes, Obj, NextChars),
    !,
    NextChars = [].


%%%% is_object

is_object(JSONString, Object, NextChars) :-
    string_codes(JSONString, JSONChars),
    skip_all_wrong_characters(JSONChars, [FirstChar | OthersChar]),
    isParentesiGraffaAperta(FirstChar),
    is_member(OthersChar, OggettiDaMember, [LastMemberChar | NextChars]),
    isParentesiGraffaChiusa(LastMemberChar),
    Object = json_obj(OggettiDaMember),
    !.


%%%% is_member

is_member([], []) :-
    !.

is_member([Char | RestChars ], [], [Char | RestChars ]) :-
    isParentesiGraffaChiusa(Char),
    !.

is_member(Characters, [(Attribute, Value) | OthersPair], LastChar) :-
    skip_virgola(Characters, NoWS),
    is_pair(NoWS, NextWords, Attribute, Value),
    is_member(NextWords, OthersPair, LastChar).

is_member(Chracters, [(Attribute, Value) | OthersPair], LastChar) :-
    skip_white_space(Chracters, NoWS),
    is_pair(NoWS, NextWords, Attribute, Value),
    is_member(NextWords, OthersPair, LastChar).


%%%% is_pair

is_pair(Pair, NextWords, SAttribute, SValue) :-
	is_DQ_string(Pair, Next, Attribute),
    string_codes(SAttribute, Attribute),
    is_due_punti(Next, Last),
    is_value(Last, SValue, NextWords).


%%%% is_value

is_value(Chars, SValue, RestString) :-
    is_DQ_string(Chars, RestString, Value),
    string_codes(SValue, Value).

is_value(Chars, SValue, RestString) :-
    is_number(Chars, Value, RestString),
    string_codes(SValue, Value).

is_value(Chars, Value, RestString) :-
    string_codes(SChars, Chars),
    is_object(SChars, Value, RestString).

is_value([FirstChar, SecondChar | OtherChars], Value, RestString) :-
    is_parentesi_quadra_aperta(FirstChar),
    is_array([FirstChar, SecondChar | OtherChars], Value, RestString).


%%%% is_DQ_string

is_DQ_string([Char | Rest], NextWords, Parola) :-
    is_DQ(Char),
    is_string(Rest, Parola, [DQ | NextWords]),
    is_DQ(DQ),
    !.


%%%% is_string

is_string([Char | Rest], [Char | RestoPrimaParola], NextWords) :-
    char_type(Char, alnum),
    is_string(Rest, RestoPrimaParola, NextWords).

is_string([Char , DQ | Rest], [Char], [DQ | Rest]) :-
    char_type(Char, alnum),
    is_DQ(DQ).


%%%% is_char_number

is_char_number(Char) :-
    Char > 47,
    Char < 58.


%%%% is_minus

is_minus(Char) :-
    Char =:= 45.


%%%% is_number

is_number([FirstChar | OtherChars], [FirstChar | OtherMembers], RestString) :-
    FirstChar > 47,
    FirstChar < 58,
    !,
    other_number_chars(OtherChars, OtherMembers, RestString).

is_number([FirstChar, SecondChar | OtherChars],
          [FirstChar, SecondChar | OtherMembers], RestString) :-
    FirstChar =:= 45,
    SecondChar > 47,
    SecondChar < 58,
    !,
    other_number_chars(OtherChars, OtherMembers, RestString).


%%%% other_number_chars

other_number_chars([FirstChar | OtherChars],
                   [FirstChar | OtherMembers], RestString) :-
    FirstChar > 47,
    FirstChar < 58,
    !,
    other_number_chars(OtherChars, OtherMembers, RestString).

other_number_chars([FirstChar | OtherChars], [], [FirstChar | OtherChars]) :-
    FirstChar =< 47.

other_number_chars([FirstChar | OtherChars], [], [FirstChar | OtherChars]) :-
    FirstChar >= 58.


%%%% is_array

is_array(Chars, Value, RestString) :-
    skip_all_wrong_characters(Chars, [FirstChar | OthersChar]),
    is_parentesi_quadra_aperta(FirstChar),
    scroll_array(OthersChar, Elements, RestString),
    Value = json_array(Elements).


%%%% scroll_array

scroll_array([FirstChar | Rest], [], Rest) :-
    is_parentesi_quadra_chiusa(FirstChar),
    !.

scroll_array([FirstChar | RestChars], Elements, RestString) :-
    is_virgola(FirstChar),
    !,
    scroll_array(RestChars, Elements, RestString).

scroll_array(Chars, [Element | OtherElements], RestString) :-
    is_value(Chars, Element, NextChars),
    Element = json_array(_),
    !,
    skip_white_space(NextChars, NoWS),
    scroll_array(NoWS, OtherElements, RestString).

scroll_array(Chars, [Element | OtherElements], RestString) :-
    is_value(Chars, Element, NextChars),
    Element = json_obj(_),
    !,
    skip_white_space(NextChars, NoWS),
    scroll_array(NoWS, OtherElements, RestString).

scroll_array(Chars, [SElement | OtherElements], RestString) :-
    is_value(Chars, Element, NextChars),
    !,
    string_codes(SElement, Element),
    skip_white_space(NextChars, NoWS),
    scroll_array(NoWS, OtherElements, RestString).


%%%% 

isParentesiGraffaAperta(123).

isParentesiGraffaChiusa(125).

is_parentesi_quadra_aperta(91).

is_parentesi_quadra_chiusa(93).

is_DQ(34).


%%%% is_due_punti

is_due_punti([Char | Rest], Rest) :-
    Char = 58.

is_due_punti(Chars, Result) :-
    skip_white_space(Chars, [FirstChar | NextChars]),
    FirstChar = 58,
    skip_white_space(NextChars, Result).


%%%% 

is_virgola(44).


%%%% skip_white_space

skip_white_space([Char | OtherChars], Rest) :-
    is_white_space(Char),
    !,
    skip_white_space(OtherChars, Rest).

skip_white_space(Chars, Chars).


%%%% skip_all_wrong_characters

skip_all_wrong_characters([Char | OtherChars], CharsString) :-
    is_white_space(Char),
    !,
    skip_all_wrong_characters(OtherChars, CharsString).

skip_all_wrong_characters([Char | OtherChars], [Char | CharsString]) :-
    skip_all_wrong_characters(OtherChars, CharsString).

skip_all_wrong_characters([], []).


%%%% skip_virgola

skip_virgola([Char | OtherChars], OtherChars) :-
    is_virgola(Char).

skip_virgola(Chars, Result) :-
    skip_white_space(Chars, [FirstChar | NextChars]),
    is_virgola(FirstChar),
    skip_white_space(NextChars, Result).


%%%% is_white_space

is_white_space(Char) :-
    char_type(Char, white) ; char_type(Char, newline).


%%%% json_access

json_access(JSON_obj, [Field], Result) :-
    find_pair(JSON_obj, Field, Result), !.

json_access(JSON_obj, Fields, Result) :-
    find_pair(JSON_obj, Fields, Result), !.


find_pair(json_obj([], _, _)) :-
    false.

find_pair(json_obj([FirstPair | _]), [Field, Position], Value) :-
    FirstPair = (Field, ArrayList),
    ArrayList = json_array(ValoriArray),
    !,
    find_position(ValoriArray, Position, Value).

find_pair(json_obj([FirstPair | _]), Field, Value) :-
    FirstPair = (Field, Value),
    !.

find_pair(json_obj([FirstPair | OtherPairs]), Field, Value) :-
    FirstPair \= (Field, Value),
    !,
    find_pair(json_obj(OtherPairs), Field, Value).

find_position([], _, _) :-
    false.

find_position([_ | OtherElements], Position, Resp) :-
    Position > 0,
    NewPosition is Position - 1,
    find_position(OtherElements, NewPosition, Resp).

find_position([FirstElement | _], Position, FirstElement) :-
    Position = 0.


%%%% json_read

json_read(FileName, JSON) :-
    read_file_to_codes(FileName, Codes, []),
    json_parse(Codes, JSON).


%%%% json_dump

json_dump(JSON, FileName) :-
    write_object(JSON, [], Codes),
    !,
    string_codes(Result, Codes),
    write_string_to_file(FileName, Result).

json_dump(JSON, FileName) :-
    write_array(JSON, [], Codes),
    !,
    string_codes(Result, Codes),
    write_string_to_file(FileName, Result).

write_object(json_obj(Object), Done, Result) :-
    append(Done, [123], TmpDone),
    write_pair(Object, TmpDone, TmpResult),
    append(TmpResult, [125], Result).

write_array(json_array(Array), Done, Result) :-
    append(Done, [91], TmpDone),
    write_values(Array, TmpDone, TmpResult),
    append(TmpResult, [93], Result).

write_values([], [91], Result) :-
    !,
    append([], [91], Result).

write_values([], Done, Result) :-
    !,
    remove_last(Done, Result).

write_values([Head_Values | Tail_Values], Done, Result) :-
    !,
    write_value(Head_Values, Done, TmpDone),
    append(TmpDone, [44], TmpResult),
    write_values(Tail_Values, TmpResult, Result).

write_pair([], [123], Result) :-
    !,
    append([], [123], Result).

write_pair([], Done, Result) :-
    !,
    remove_last(Done, Result).

write_pair([(String, Value) | MorePair], Done, Result) :-
    atom_codes(String, Codes),
    !,
    append([34 | Codes], [34], Tmp_String),
    append(Done, Tmp_String, TmpDone),
    append(TmpDone, [58], TmpPair),
    write_value(Value, TmpPair, TmpResult),
    append(TmpResult, [44], Pair),
    write_pair(MorePair, Pair, Result).

write_value(json_obj(Object), Done, Result) :-
    !,
    write_object(json_obj(Object), Done, Result).

write_value(json_array(Array), Done, Result) :-
    !,
    write_array(json_array(Array), Done, Result).

write_value(String, Done, Result) :-
    string(String),
    !,
    string_codes(String, Codes),
    append([34 | Codes], [34], Tmp_String),
    append(Done, Tmp_String, Result).

write_value(Number, Done, Result) :-
    number_codes(Number, Codes),
    append(Done, Codes, Result).

remove_last(In, Out) :-
    append(Out, [_], In).

write_string_to_file(Filename, Result) :-
    open(Filename, write, Out),
    write(Out, Result),
    close(Out).

%%%% end of file -- json-parse.pl --