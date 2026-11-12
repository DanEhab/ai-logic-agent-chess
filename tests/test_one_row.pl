% Tests on tests/kbs/one_row.pl: a 5x1 board, knight (1,1), bishop (3,1).
% Nothing can move here.

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('tests/kbs/one_row.pl').

:- begin_tests(one_row).

test(no_moves_at_all, As == []) :-
    findall(A, poss(A, s0), As).

test(already_true, S == s0) :-
    find_plan((1,1), (3,1), S, 5).

% (5,1) has the bishop's shade, but there is no diagonal to slide along.
test(bishop_cannot_move, fail) :-
    find_plan((1,1), (5,1), _, 5).

test(knight_cannot_move, fail) :-
    find_plan((2,1), (3,1), _, 5).

:- end_tests(one_row).
