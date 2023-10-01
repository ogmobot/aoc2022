manhattan((A, B), (C, D), Dist) :-
    maplist(integer, [A, B, C, D]),
    Dist is abs(A - C) + abs(B - D).
manhattan((A, B), (C, D), Dist) :-
    maplist(integer, [A, B, C, Dist]),
    (
        (D is abs(A - C) + B - Dist) ;
        (D is -abs(A - C) + B + Dist)
    ).

% Input and parsing

get_lines(Filename, Lines) :-
    open(Filename, read, Stream),
    read_lines(Stream, Lines),
    close(Stream).

read_lines(Stream, []) :- at_end_of_stream(Stream).
read_lines(Stream, [H | T]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, Line),
    line_to_probe(Line, H),
    read_lines(Stream, T).

line_to_probe(Line, (XP, YP, R)) :-
    re_split("-?\\d+", Line, [_, StrXP, _, StrYP, _, StrXB, _, StrYB | _]),
    number_string(XP, StrXP), number_string(YP, StrYP),
    number_string(XB, StrXB), number_string(YB, StrYB),
    manhattan((XP, YP), (XB, YB), R).

% Dealing with intervals

% Note that if the probe's radius doesn't reach this Y value, Half is negative.
interval_at_y(Y, (Px, Py, R), (Lower, Upper)) :-
    Y >= Py,
    Half  is R + Py - Y,
    Lower is Px - Half,
    Upper is Px + Half.
interval_at_y(Y, (Px, Py, R), I) :-
    Y < Py,
    interval_at_y(-Y, (Px, -Py, R), I).

merged_interval((La, Lb), X, X) :- La > Lb, !. % left interval doesn't exist
merged_interval(X, (Ra, Rb), X) :- Ra > Rb, !. % right interval doesn't exist
merged_interval((La, Lb), (Ra, Rb), (Ma, Mb)) :-
    % Assumes the lowest part of the Left probe has a smaller x value than
    % that of the right probe.
    La =< Lb, % left interval exists
    Ra =< Rb, % right interval exists
    Lb + 1 >= Ra,
    Ma is min(La, Ra),
    Mb is max(Lb, Rb), !.

find_gap([(Lower, Upper), Second | _], X) :-
    \+ merged_interval((Lower, Upper), Second, _),
    X is Upper + 1,
    between(0, 4000000, X).
find_gap([First, Second | Rest], X) :-
    merged_interval(First, Second, M),
    find_gap([M | Rest], X).

% Dealing with covering points

outline((Px, Py, R), (X, Y)) :-
    Lower is Px - R - 1,
    Upper is Px + R + 1,
    between(Lower, Upper, X),
    Dist is R + 1,
    manhattan((Px, Py), (X, Y), Dist).

entire_outline(Probe, Ps) :- setof(P, outline(Probe, P), Ps).

covered(Point, [(Px, Py, R) | _]) :-
    manhattan((Px, Py), Point, Dist),
    Dist =< R.
covered(Point, [_ | T]) :- covered(Point, T).

% The hard yakka

part1(Probes) :-
    % Assume that all intervals merge into a single interval
    maplist(interval_at_y(2000000), Probes, Unsorted),
    sort(Unsorted, Intervals),
    foldl(merged_interval, Intervals, (1, 0), (Lower, Upper)),
    Result is Upper - Lower,
    writeln(Result).

part2(Probes) :-
    between(0, 4000000, Y),
    maplist(interval_at_y(Y), Probes, Unsorted),
    sort(Unsorted, Intervals),
    find_gap(Intervals, X),
    Result is (X * 4000000) + Y,
    write(X), write(","), writeln(Y),
    writeln(Result).

main :-
    get_lines("input15.txt", Probes),
    part1(Probes),
    part2(Probes), % takes... a while.
    halt.

:- initialization(main).
