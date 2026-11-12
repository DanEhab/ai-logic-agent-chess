% Tests on tests/kbs/three_by_three.pl: 3x3 board, knight (1,1),
% bishop (3,1).

:- use_module(library(plunit)).
:- use_module(harness).
:- load_solution('tests/kbs/three_by_three.pl').

:- begin_tests(three_by_three).

% No knight can ever land on the centre, even though the bishop is
% already where the goal wants it.
test(knight_never_reaches_centre, fail) :-
    find_plan((2,2), (3,1), _, 5).

test(knight_one_jump, S == result(k(3,2), s0)) :-
    find_plan((3,2), (3,1), S, 5).

% The bishop slides over the empty centre to the far corner.
test(bishop_one_slide, S == result(b(1,3), s0)) :-
    find_plan((1,1), (1,3), S, 5).

:- end_tests(three_by_three).
