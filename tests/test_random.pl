% Random boards checked against the independent referee (tests/referee.pl).
%
% The board facts live in tests/kbs/random_board.pl and are dynamic, so
% this file replaces them with a new random board before each round
% (assert/retract are used here in the test code only, never in the
% solution). The random seed is fixed, so every run checks the same boards.

:- use_module(library(plunit)).
:- use_module(library(random)).
:- use_module(library(time)).
:- use_module(harness).
:- use_module(referee).
:- load_solution('tests/kbs/random_board.pl').

set_board(W, H, Knights, Bishops) :-
    retractall(grid(_, _)),
    retractall(knight_at(_, _)),
    retractall(bishop_at(_, _)),
    assertz(grid(W, H)),
    forall(member((X,Y), Knights), assertz(knight_at(X, Y))),
    forall(member((X,Y), Bishops), assertz(bishop_at(X, Y))).

% A random board between Min x Min and Max x Max with 1-2 knights and
% 1-2 bishops, every piece on its own cell.
random_board(Min, Max) :-
    random_between(Min, Max, W),
    random_between(Min, Max, H),
    random_between(1, 2, NK),
    random_between(1, 2, NB),
    findall((X,Y), ( between(1, W, X), between(1, H, Y) ), Cells),
    random_permutation(Cells, Shuffled),
    length(Knights, NK),
    length(Bishops, NB),
    append(Knights, Rest, Shuffled),
    append(Bishops, _, Rest),
    set_board(W, H, Knights, Bishops).

random_cell((X,Y)) :-
    grid(W, H),
    random_between(1, W, X),
    random_between(1, H, Y).

random_goal(K, B) :-
    repeat,
    random_cell(K),
    random_cell(B),
    K \== B, !.

% What our goal/3 says for an unknown S, as found(S), false or timeout.
our_answer(K, B, Seconds, Answer) :-
    catch(( call_with_time_limit(Seconds, goal(K, B, S))
          -> Answer = found(S)
          ;  Answer = false ),
          time_limit_exceeded,
          Answer = timeout).

% Our answer agrees with the referee's breadth-first search: a plan that
% the referee accepts with exactly the fewest moves, or false when the
% referee finds no board with the goal at all.
agrees(moves(N), found(S), K, B) :-
    referee_goal(K, B, S),
    moves(S, N).
agrees(none, false, _, _).

check_boards(Seed, Boards, Min, Max, GoalsPerBoard, Seconds) :-
    set_random(seed(Seed)),
    forall(between(1, Boards, _),
           ( random_board(Min, Max),
             referee_layers(Layers),
             forall(between(1, GoalsPerBoard, _),
                    ( random_goal(K, B),
                      referee_shortest_in(Layers, K, B, Expected),
                      our_answer(K, B, Seconds, Ours),
                      (   agrees(Expected, Ours, K, B)
                      ->  true
                      ;   board_facts(Facts),
                          format(user_error, "~nboard ~w, goal ~w ~w: referee ~w, ours ~w~n",
                                 [Facts, K, B, Expected, Ours]),
                          fail
                      ) )) )).

board_facts(g(W,H)-Ks-Bs) :-
    grid(W, H),
    findall((X,Y), knight_at(X, Y), Ks),
    findall((X,Y), bishop_at(X, Y), Bs).

% A random situation: up to Max actions, each one either an allowed
% action (picked from the referee's list) or a random, maybe illegal one,
% sometimes even with a cell just off the board.
random_situation(Max, S) :-
    random_between(0, Max, N),
    referee_board(Board),
    random_actions(N, Board, s0, S).

random_actions(0, _, S, S) :- !.
random_actions(N, Board, S0, S) :-
    grid(W, H),
    referee_actions(Board, Legal),
    (   Legal \== [], random(R), R < 0.7
    ->  random_member(A, Legal)
    ;   W1 is W + 1, H1 is H + 1,
        random_between(0, W1, X), random_between(0, H1, Y),
        random_member(F, [k, b]),
        A =.. [F, X, Y]
    ),
    (   referee_replay(result(A, S0), Board1)
    ->  true
    ;   Board1 = Board
    ),
    N1 is N - 1,
    random_actions(N1, Board1, result(A, S0), S).

% Goal cells: half the time taken from the final board (so the answer
% can be true), otherwise random.
random_goal_for(S, K, B) :-
    (   random(R), R < 0.5,
        referee_replay(S, board(Ks, Bs))
    ->  random_member(K, Ks),
        random_member(B, Bs)
    ;   random_goal(K, B)
    ).

check_given_plans(Seed, Cases) :-
    set_random(seed(Seed)),
    forall(between(1, Cases, _),
           ( random_board(3, 5),
             random_situation(5, S),
             random_goal_for(S, K, B),
             (   goal(K, B, S)
             ->  Ours = true
             ;   Ours = false
             ),
             (   referee_goal(K, B, S)
             ->  Expected = true
             ;   Expected = false
             ),
             (   Ours == Expected
             ->  true
             ;   format(user_error, "~ngiven plan ~w, goal ~w ~w: referee ~w, ours ~w~n",
                        [S, K, B, Expected, Ours]),
                 fail
             ) )).

:- begin_tests(random_boards).

% 30 boards from 3x3 to 5x5, 4 goals each: same answer as the referee,
% including the length of the plan.
test(search_matches_referee) :-
    check_boards(2026, 30, 3, 5, 4, 30).

% 40 tiny boards (2x2 to 3x3), where pieces often block each other for
% good: every goal the referee calls impossible must answer false.
test(tiny_boards_match_referee) :-
    check_boards(7, 40, 2, 3, 4, 30).

% 400 random given situations, many with illegal actions in them: the
% true/false answer of goal/3 matches the referee's replay.
test(given_plans_match_referee) :-
    check_given_plans(11, 400).

:- end_tests(random_boards).
