/*  Referee: an independent way to get the right answers.

    It never calls the solution. A board is just two sorted lists,
    Knights and Bishops, and the move rules are written again here in a
    different way (with abs/1 instead of the solution's offset lists).
    Only the KB facts grid/2, knight_at/2 and bishop_at/2 are shared.

    When two pieces of one type can make the same move, the one that
    comes first in the sorted list moves, which is the same rule the
    solution uses (smaller coordinates first).

      referee_board(-Board)              the board in s0
      referee_replay(+S, -Board)         replay a situation; fails if any
                                         action in it is illegal
      referee_goal(+K, +B, +S)           the goal holds after replaying S
      referee_shortest(+K, +B, -Answer)  breadth-first search over boards:
                                         Answer = moves(N) for the fewest
                                         moves, or none if no board that
                                         can be reached has the goal
      referee_layers(-Layers)            every board that can be reached,
                                         as a list of layers (layer N =
                                         boards first reached after N moves)
      referee_shortest_in(+Layers, +K, +B, -Answer)
                                         the same answer as referee_shortest,
                                         read from precomputed layers
*/

:- module(referee, [referee_board/1, referee_replay/2, referee_goal/3,
                    referee_shortest/3, referee_actions/2,
                    referee_layers/1, referee_shortest_in/4]).

:- use_module(library(assoc)).

referee_board(board(Ks, Bs)) :-
    findall((X,Y), user:knight_at(X, Y), K0), msort(K0, Ks),
    findall((X,Y), user:bishop_at(X, Y), B0), msort(B0, Bs).

inside(X, Y) :-
    user:grid(W, H),
    integer(X), integer(Y),
    X >= 1, X =< W, Y >= 1, Y =< H.

knight_step(X, Y, H, V) :-
    DX is abs(H - X), DY is abs(V - Y),
    ( DX =:= 1, DY =:= 2 ; DX =:= 2, DY =:= 1 ), !.

bishop_step(X, Y, H, V) :-
    DX is abs(H - X), DY is abs(V - Y),
    DX =:= DY, DX > 0.

% apply(+Board, +Action, -Board2): Action is legal on Board and gives Board2.
apply(board(Ks, Bs), k(H, V), board(Ks2, Bs)) :-
    inside(H, V),
    \+ memberchk((H,V), Ks), \+ memberchk((H,V), Bs),
    first_mover(Ks, H, V, knight_step, From),
    swap(Ks, From, (H,V), Ks2).
apply(board(Ks, Bs), b(H, V), board(Ks, Bs2)) :-
    inside(H, V),
    \+ memberchk((H,V), Ks), \+ memberchk((H,V), Bs),
    first_mover(Bs, H, V, bishop_step, From),
    swap(Bs, From, (H,V), Bs2).

first_mover([(X,Y)|Rest], H, V, Step, From) :-
    (   call(Step, X, Y, H, V)
    ->  From = (X,Y)
    ;   first_mover(Rest, H, V, Step, From)
    ).

swap(Cells, Old, New, Sorted) :-
    selectchk(Old, Cells, Rest),
    msort([New|Rest], Sorted).

referee_replay(s0, Board) :-
    referee_board(Board).
referee_replay(result(A, S), Board) :-
    referee_replay(S, Board0),
    apply(Board0, A, Board).

referee_goal(K, B, S) :-
    referee_replay(S, board(Ks, Bs)),
    memberchk(K, Ks),
    memberchk(B, Bs).

% referee_actions(+Board, -Actions): every legal action on Board, sorted.
referee_actions(board(Ks, Bs), Actions) :-
    user:grid(W, H),
    findall(A, ( between(1, W, X), between(1, H, Y),
                 member(A, [k(X,Y), b(X,Y)]),
                 apply(board(Ks, Bs), A, _) ),
            A0),
    sort(A0, Actions).

referee_shortest(K, B, Answer) :-
    referee_board(Start),
    empty_assoc(E),
    put_assoc(Start, E, true, Seen),
    bfs([Start], 0, K, B, Seen, Answer).

bfs([], _, _, _, _, none).
bfs(Layer, D, K, B, Seen, Answer) :-
    Layer \== [],
    (   member(board(Ks, Bs), Layer), memberchk(K, Ks), memberchk(B, Bs)
    ->  Answer = moves(D)
    ;   next_layer(Layer, Seen, [], Next, Seen1),
        D1 is D + 1,
        bfs(Next, D1, K, B, Seen1, Answer)
    ).

next_layer([], Seen, Acc, Acc, Seen).
next_layer([Board|Boards], Seen0, Acc0, Next, Seen) :-
    referee_actions(Board, Actions),
    foldl(add_child(Board), Actions, Acc0-Seen0, Acc1-Seen1),
    next_layer(Boards, Seen1, Acc1, Next, Seen).

referee_layers(Layers) :-
    referee_board(Start),
    empty_assoc(E),
    put_assoc(Start, E, true, Seen),
    all_layers([Start], Seen, Layers).

all_layers([], _, []).
all_layers(Layer, Seen, [Layer|Rest]) :-
    Layer \== [],
    next_layer(Layer, Seen, [], Next, Seen1),
    all_layers(Next, Seen1, Rest).

referee_shortest_in(Layers, K, B, Answer) :-
    (   nth0(D, Layers, Layer),
        member(board(Ks, Bs), Layer), memberchk(K, Ks), memberchk(B, Bs)
    ->  Answer = moves(D)
    ;   Answer = none
    ).

add_child(Board, A, Acc0-Seen0, Acc-Seen) :-
    apply(Board, A, Child),
    (   get_assoc(Child, Seen0, _)
    ->  Acc = Acc0, Seen = Seen0
    ;   Acc = [Child|Acc0], put_assoc(Child, Seen0, true, Seen)
    ).
