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


:- begin_tests(kb2_s0).

test(knights_in_s0, Ks == [(3,3), (6,5)]) :-
    setof((X,Y), knight(X, Y, s0), Ks).

test(bishops_in_s0, Bs == [(1,1), (2,3)]) :-
    setof((X,Y), bishop(X, Y, s0), Bs).

test(occupied_cells, Cs == [(1,1), (2,3), (3,3), (6,5)]) :-
    setof((X,Y), occupied(X, Y, s0), Cs).

% (3,3) holds a knight in s0, which is why KB2 sample 1 must move it
% away before a bishop can land there.
test(bishop_target_starts_taken, nondet) :-
    knight(3, 3, s0),
    occupied(3, 3, s0).

test(empty_cells) :-
    \+ occupied(6, 1, s0),
    \+ occupied(3, 2, s0).

:- end_tests(kb2_s0).


:- begin_tests(kb2_poss).

test(action_count, N == 19) :-
    setof(A, poss(A, s0), As),
    length(As, N).

test(knight_moves, Ks == [k(1,2), k(1,4), k(2,1), k(2,5), k(4,1),
                          k(4,4), k(4,5), k(5,2), k(5,3), k(5,4)]) :-
    setof(k(H,V), poss(k(H,V), s0), Ks).

test(bishop_moves, Bs == [b(1,2), b(1,4), b(2,2), b(3,2), b(3,4),
                          b(4,1), b(4,4), b(4,5), b(5,5)]) :-
    setof(b(H,V), poss(b(H,V), s0), Bs).

test(each_action_found_once, N == 19) :-
    findall(A, poss(A, s0), L),
    length(L, N).

% Sample 1 cannot start with b(3,3): the knight on (3,3) must move first.
test(sample1_bishop_waits, nondet) :-
    \+ poss(b(3,3), s0),
    poss(k(1,2), s0).

% The first moves of samples 2 and 3.
test(sample_first_moves, nondet) :-
    poss(b(3,2), s0),
    poss(k(4,1), s0).

:- end_tests(kb2_poss).
