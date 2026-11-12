% Tests on KB1: 6x6 board, knights (3,3) (5,1), bishops (1,1) (3,2) (4,6).

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('KB1.pl').

:- begin_tests(kb1_board).

test(solution_loaded) :-
    source_file(File),
    file_base_name(File, Name),
    sub_atom(Name, 0, _, _, chess_), !.

test(grid) :-
    grid(6, 6).

test(knights, Ks == [(3,3), (5,1)]) :-
    findall((X,Y), knight_at(X, Y), L),
    msort(L, Ks).

test(bishops, Bs == [(1,1), (3,2), (4,6)]) :-
    findall((X,Y), bishop_at(X, Y), L),
    msort(L, Bs).

:- end_tests(kb1_board).
