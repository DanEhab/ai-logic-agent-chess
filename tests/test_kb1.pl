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


:- begin_tests(kb1_poss).

test(action_count, N == 25) :-
    setof(A, poss(A, s0), As),
    length(As, N).

test(knight_moves, Ks == [k(1,2), k(1,4), k(2,1), k(2,5), k(4,1),
                          k(4,3), k(4,5), k(5,2), k(5,4), k(6,3)]) :-
    setof(k(H,V), poss(k(H,V), s0), Ks).

test(bishop_moves, Bs == [b(1,3), b(1,4), b(2,1), b(2,2), b(2,3),
                          b(2,4), b(3,5), b(4,1), b(4,3), b(4,4),
                          b(5,4), b(5,5), b(6,4), b(6,5), b(6,6)]) :-
    setof(b(H,V), poss(b(H,V), s0), Bs).

% findall keeps duplicates, so this shows each action is found only once.
test(each_action_found_once, N == 25) :-
    findall(A, poss(A, s0), L),
    length(L, N).

% The first moves of samples 1 and 2.
test(sample_first_moves, nondet) :-
    poss(b(2,2), s0),
    poss(b(5,4), s0),
    poss(k(4,3), s0).

% Sample 5's move: no bishop is on a diagonal with (1,2).
test(sample5_illegal_bishop_move) :-
    \+ poss(b(1,2), s0).

% A knight on (5,1) could jump to (3,2), but a bishop is standing there.
test(knight_target_taken, nondet) :-
    knight_jump(5, 1, 3, 2),
    \+ poss(k(3,2), s0).

% (3,3) is on the (1,1) bishop's diagonal, but a knight is standing there.
test(bishop_target_taken, nondet) :-
    bishop_slide(1, 1, 3, 3),
    \+ poss(b(3,3), s0).

test(not_a_move) :-
    \+ poss(k(4,4), s0),
    \+ poss(k(7,2), s0),
    \+ poss(b(3,1), s0).

% Two bishops can reach (5,5); only the lower one, (1,1), is the mover.
test(two_bishops_one_mover) :-
    setof((X,Y), ( bishop(X, Y, s0), bishop_slide(X, Y, 5, 5) ), Both),
    Both == [(1,1), (4,6)],
    setof((X,Y), bishop_mover(X, Y, 5, 5, s0), Mover),
    Mover == [(1,1)],
    aggregate_all(count, poss(b(5,5), s0), 1).

:- end_tests(kb1_poss).


:- begin_tests(kb1_ssa).

% A bishop move leaves the knights where they were (the frame part).
test(bishop_move_keeps_knights) :-
    pieces(result(b(2,2), s0), Ks, Bs),
    Ks == [(3,3), (5,1)],
    Bs == [(2,2), (3,2), (4,6)].

test(sample1_plan) :-
    pieces(result(k(4,3), result(b(2,2), s0)), Ks, Bs),
    Ks == [(3,3), (4,3)],
    Bs == [(2,2), (3,2), (4,6)].

test(sample3_plan) :-
    S = result(k(3,4), result(k(4,2), result(k(2,1), result(b(4,4), s0)))),
    pieces(S, Ks, Bs),
    Ks == [(3,4), (5,1)],
    Bs == [(3,2), (4,4), (4,6)].

% An illegal move leaves no piece anywhere, and nothing after it can
% bring them back (sample 5's plan).
test(illegal_move_empties_board) :-
    pieces(result(b(1,2), s0), [], []),
    pieces(result(k(4,3), result(b(1,2), s0)), [], []).

% Two bishops can reach (5,5); the one on (1,1) moves, the one on (4,6) stays.
test(lower_bishop_moves) :-
    pieces(result(b(5,5), s0), Ks, Bs),
    Ks == [(3,3), (5,1)],
    Bs == [(3,2), (4,6), (5,5)].

% After any two allowed moves there are still 2 knights and 3 bishops,
% each on its own cell.
test(two_moves_keep_every_piece) :-
    forall(( poss(A1, s0), poss(A2, result(A1, s0)) ),
           ( pieces(result(A2, result(A1, s0)), Ks, Bs),
             length(Ks, 2),
             length(Bs, 3),
             append(Ks, Bs, All),
             sort(All, Cells),
             length(Cells, 5) )).

:- end_tests(kb1_ssa).
