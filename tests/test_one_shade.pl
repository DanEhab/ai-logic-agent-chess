% Tests on tests/kbs/one_shade.pl: 5x5 board, knight (1,1),
% bishops (3,3) and (5,1), both on the shade where X+Y is even.

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('tests/kbs/one_shade.pl').

:- begin_tests(one_shade).

% (1,2) has X+Y odd: no bishop can ever get there.
test(bishop_wrong_shade, fail) :-
    find_plan((2,3), (1,2), _, 5).

% The same knight cell with a bishop cell of the right shade works.
test(bishop_right_shade, S == result(k(2,3), result(b(2,2), s0))) :-
    find_plan((2,3), (2,2), S, 5).

% (1,3) is the right shade but on no bishop's diagonal: two slides.
test(two_slides, nondet) :-
    find_plan((2,3), (1,3), S, 5),
    moves(S, 3),
    goal((2,3), (1,3), S).

:- end_tests(one_shade).
