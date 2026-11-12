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


:- begin_tests(kb2_geometry).

test(cell_count, N == 30) :-
    aggregate_all(count, on_board(_, _), N).

% The first coordinate runs over the width (6), the second over the height (5).
test(width_then_height) :-
    on_board(6, 5),
    \+ on_board(5, 6).

test(knight_from_corner, T == [(4,4), (5,3)]) :-
    setof((X,Y), knight_jump(6, 5, X, Y), T).

test(knight_from_centre, T == [(1,2), (1,4), (2,1), (2,5), (4,1), (4,5), (5,2), (5,4)]) :-
    setof((X,Y), knight_jump(3, 3, X, Y), T).

test(bishop_from_corner, T == [(2,2), (3,3), (4,4), (5,5)]) :-
    setof((X,Y), bishop_slide(1, 1, X, Y), T).

test(bishop_from_2_3, T == [(1,2), (1,4), (3,2), (3,4), (4,1), (4,5)]) :-
    setof((X,Y), bishop_slide(2, 3, X, Y), T).

:- end_tests(kb2_geometry).
