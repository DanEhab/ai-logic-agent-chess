% Board used by tests/test_random.pl. The facts are dynamic so the test can
% replace them with a new random board before each round. Only the test
% code changes them; the solution itself never uses assert or retract.

:- dynamic grid/2, knight_at/2, bishop_at/2.

grid(4,4).
knight_at(1,1).
bishop_at(4,4).
