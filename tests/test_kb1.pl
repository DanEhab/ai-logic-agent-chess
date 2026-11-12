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


:- begin_tests(kb1_geometry).

test(cell_count, N == 36) :-
    aggregate_all(count, on_board(_, _), N).

test(off_board) :-
    \+ on_board(7, 1),
    \+ on_board(0, 3),
    \+ on_board(3, 7).

test(knight_from_centre, T == [(1,2), (1,4), (2,1), (2,5), (4,1), (4,5), (5,2), (5,4)]) :-
    setof((X,Y), knight_jump(3, 3, X, Y), T).

test(knight_from_edge, T == [(3,2), (4,3), (6,3)]) :-
    setof((X,Y), knight_jump(5, 1, X, Y), T).

test(knight_check, nondet) :-
    knight_jump(3, 3, 4, 5).

test(knight_not_a_jump) :-
    \+ knight_jump(3, 3, 4, 4),
    \+ knight_jump(3, 3, 3, 5),
    \+ knight_jump(5, 1, 7, 2).

% If a knight can jump from A to B it can jump back from B to A.
test(knight_jumps_go_both_ways) :-
    forall(( on_board(X, Y), knight_jump(X, Y, A, B) ),
           knight_jump(A, B, X, Y)).

% Every knight jump lands on the other square shade.
test(knight_changes_shade) :-
    forall(( on_board(X, Y), knight_jump(X, Y, A, B) ),
           (X + Y) mod 2 =\= (A + B) mod 2).

test(bishop_from_corner, T == [(2,2), (3,3), (4,4), (5,5), (6,6)]) :-
    setof((X,Y), bishop_slide(1, 1, X, Y), T).

test(bishop_from_3_2, T == [(1,4), (2,1), (2,3), (4,1), (4,3), (5,4), (6,5)]) :-
    setof((X,Y), bishop_slide(3, 2, X, Y), T).

test(bishop_from_4_6, T == [(1,3), (2,4), (3,5), (5,5), (6,4)]) :-
    setof((X,Y), bishop_slide(4, 6, X, Y), T).

test(bishop_check, nondet) :-
    bishop_slide(1, 1, 6, 6).

% (1,2) is the cell of sample 5's illegal move: no bishop is on a diagonal with it.
test(bishop_not_a_slide) :-
    \+ bishop_slide(1, 1, 1, 2),
    \+ bishop_slide(3, 2, 1, 2),
    \+ bishop_slide(4, 6, 1, 2),
    \+ bishop_slide(1, 1, 1, 1).

% Listing the targets never gives the same cell twice.
test(bishop_no_duplicates) :-
    forall(on_board(X, Y),
           ( findall((A,B), bishop_slide(X, Y, A, B), L),
             msort(L, Sorted),
             sort(L, Sorted) )).

% A bishop never leaves its square shade.
test(bishop_keeps_shade) :-
    forall(( on_board(X, Y), bishop_slide(X, Y, A, B) ),
           (X + Y) mod 2 =:= (A + B) mod 2).

:- end_tests(kb1_geometry).


:- begin_tests(kb1_s0).

test(knights_in_s0, Ks == [(3,3), (5,1)]) :-
    setof((X,Y), knight(X, Y, s0), Ks).

test(bishops_in_s0, Bs == [(1,1), (3,2), (4,6)]) :-
    setof((X,Y), bishop(X, Y, s0), Bs).

test(occupied_cells, Cs == [(1,1), (3,2), (3,3), (4,6), (5,1)]) :-
    setof((X,Y), occupied(X, Y, s0), Cs).

test(occupied_by_bishop, nondet) :-
    occupied(3, 2, s0).

test(occupied_by_knight, nondet) :-
    occupied(3, 3, s0).

% (2,2) and (4,3) are the target cells of sample 1, so they must start empty.
test(empty_cells) :-
    \+ occupied(2, 2, s0),
    \+ occupied(4, 3, s0).

test(one_piece_per_cell) :-
    \+ ( knight(X, Y, s0), bishop(X, Y, s0) ).

:- end_tests(kb1_s0).
