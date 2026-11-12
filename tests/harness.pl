/*  Test helper: load the solution with any knowledge base.

    The solution starts with  :- include('KB1.pl').  To test it on another
    board we rewrite that one directive while the file is being loaded, so
    the solution itself never has to be edited for testing.

    Each test file loads exactly one KB, and run-tests.ps1 runs every test
    file in its own swipl process, so facts from two boards never mix.
*/

:- module(harness, [load_solution/1, project_dir/1, pieces/3, moves/2,
                    find_plan/4]).

:- use_module(library(time)).

% Folder that holds the solution (the parent of tests/).
project_dir(Root) :-
    source_file(harness:project_dir(_), Here),
    file_directory_name(Here, TestsDir),
    file_directory_name(TestsDir, Root).

% The submission file, whatever member ID it is named after.
solution_path(Path) :-
    project_dir(Root),
    directory_file_path(Root, 'chess_*.pl', Pattern),
    expand_file_name(Pattern, [Path|_]).

% load_solution(+KB): consult the solution into user, with its include
% directive pointing at KB (a path relative to the project folder).
load_solution(KB) :-
    project_dir(Root),
    directory_file_path(Root, KB, KBPath),
    (   exists_file(KBPath) -> true
    ;   format(user_error, "No such knowledge base: ~w~n", [KBPath]), fail
    ),
    solution_path(Solution),
    setup_call_cleanup(
        nb_setval(harness_kb, KBPath),
        load_files(user:Solution, [if(true)]),
        nb_delete(harness_kb)).

% pieces(+S, -Knights, -Bishops): every cell the two fluents report in
% situation S, sorted. msort keeps duplicates, so a cell reported twice
% would show up in a test.
pieces(S, Knights, Bishops) :-
    findall((X,Y), user:knight(X, Y, S), Ks),
    findall((X,Y), user:bishop(X, Y, S), Bs),
    msort(Ks, Knights),
    msort(Bs, Bishops).

% moves(+S, -N): S is N actions after s0.
moves(s0, 0).
moves(result(_, S), N) :-
    moves(S, N0),
    N is N0 + 1.

% find_plan(+KnightCell, +BishopCell, -S, +Seconds): ask goal/3 for a plan,
% but give up (and fail the test) after Seconds instead of hanging.
find_plan(KnightCell, BishopCell, S, Seconds) :-
    call_with_time_limit(Seconds, user:goal(KnightCell, BishopCell, S)).

:- multifile user:term_expansion/2.
:- dynamic user:term_expansion/2.

user:term_expansion((:- include(_)), (:- include(KBPath))) :-
    nb_current(harness_kb, KBPath).
