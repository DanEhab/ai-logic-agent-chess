/*  Test helper: load the solution with any knowledge base.

    The solution starts with  :- include('KB1.pl').  To test it on another
    board we rewrite that one directive while the file is being loaded, so
    the solution itself never has to be edited for testing.

    Each test file loads exactly one KB, and run-tests.ps1 runs every test
    file in its own swipl process, so facts from two boards never mix.
*/

:- module(harness, [load_solution/1, project_dir/1]).

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

:- multifile user:term_expansion/2.
:- dynamic user:term_expansion/2.

user:term_expansion((:- include(_)), (:- include(KBPath))) :-
    nb_current(harness_kb, KBPath).
