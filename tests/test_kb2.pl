% Tests on KB2: 6x5 board, knights (6,5) (3,3), bishops (1,1) (2,3).

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('KB2.pl').

:- begin_tests(kb2_board).

% If the include had not been swapped we would see KB1's 6x6 grid here.
test(grid) :-
    grid(6, 5),
    \+ grid(6, 6).

test(knights, Ks == [(3,3), (6,5)]) :-
    findall((X,Y), knight_at(X, Y), L),
    msort(L, Ks).

test(bishops, Bs == [(1,1), (2,3)]) :-
    findall((X,Y), bishop_at(X, Y), L),
    msort(L, Bs).

:- end_tests(kb2_board).
