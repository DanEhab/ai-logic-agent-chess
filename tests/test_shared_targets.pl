% Tests on tests/kbs/shared_targets.pl: 5x5 board, knights (1,1) (3,1),
% bishops (1,5) (5,5). Two pieces of the same type can reach one cell.

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('tests/kbs/shared_targets.pl').

:- begin_tests(shared_targets).

test(both_knights_reach_2_3, nondet) :-
    knight_jump(1, 1, 2, 3),
    knight_jump(3, 1, 2, 3).

test(knight_mover_is_lower, M == [(1,1)]) :-
    setof((X,Y), knight_mover(X, Y, 2, 3, s0), M).

% Exactly one knight leaves: (1,1) goes to (2,3), (3,1) stays.
test(one_knight_moves) :-
    pieces(result(k(2,3), s0), Ks, Bs),
    Ks == [(2,3), (3,1)],
    Bs == [(1,5), (5,5)].

test(one_bishop_moves) :-
    pieces(result(b(3,3), s0), Ks, Bs),
    Ks == [(1,1), (3,1)],
    Bs == [(3,3), (5,5)].

% The knight that stayed behind can still be moved afterwards.
test(other_knight_moves_next) :-
    pieces(result(k(1,2), result(k(2,3), s0)), Ks, _),
    Ks == [(1,2), (2,3)].

test(two_moves_keep_every_piece) :-
    forall(( poss(A1, s0), poss(A2, result(A1, s0)) ),
           ( pieces(result(A2, result(A1, s0)), Ks, Bs),
             length(Ks, 2),
             length(Bs, 2),
             append(Ks, Bs, All),
             sort(All, Cells),
             length(Cells, 4) )).

:- end_tests(shared_targets).
