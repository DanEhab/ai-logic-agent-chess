:- include('KB1.pl').

/*
    CSEN 901 Introduction to Artificial Intelligence, Winter 2026
    Assignment 2: moving knights and bishops with the situation calculus

    Team (name, ID, tutorial):
        to be filled in before submission

    The KB gives the board size grid(W, H) and the starting cells of the
    pieces, knight_at(X, Y) and bishop_at(X, Y). Coordinates start at 1.

    A situation is either s0, the board described by the KB, or
    result(A, S), the situation reached by doing action A in situation S.
    There are two actions:
        k(H, V)   move a knight to cell (H, V)
        b(H, V)   move a bishop to cell (H, V)
    So result(k(4,3), result(b(2,2), s0)) means: from s0 move a bishop to
    (2,2), then move a knight to (4,3).
*/


% ------------------------------------------------------------------
% Board geometry
%
% These predicates have no situation argument. The size of the board
% and the way each piece moves are the same in every situation, so
% they are ordinary predicates, not fluents.
% ------------------------------------------------------------------

% on_board(?X, ?Y): (X, Y) is a cell of the W x H grid. X goes from 1
% to W and Y from 1 to H. Works both to check a cell and to list cells.
on_board(X, Y) :-
    grid(W, H),
    between(1, W, X),
    between(1, H, Y).

% knight_jump(+X, +Y, ?X2, ?Y2): a knight standing on (X, Y) can jump to
% (X2, Y2): two cells in one direction and one cell in the other,
% without leaving the board. With (X2, Y2) unbound it lists the targets.
knight_jump(X, Y, X2, Y2) :-
    member((DX, DY), [(1,2), (2,1), (2,-1), (1,-2), (-1,-2), (-2,-1), (-2,1), (-1,2)]),
    X2 is X + DX,
    Y2 is Y + DY,
    on_board(X2, Y2).

% bishop_slide(+X, +Y, ?X2, ?Y2): a bishop standing on (X, Y) can slide
% diagonally to (X2, Y2). Pieces in between never block a bishop, so
% the only condition is the same distance D > 0 across and up/down.
bishop_slide(X, Y, X2, Y2) :-
    grid(W, _),
    between(1, W, X2),
    D is abs(X2 - X),
    D > 0,
    ( Y2 is Y + D ; Y2 is Y - D ),
    on_board(X2, Y2).


% ------------------------------------------------------------------
% Fluents
%
% We use exactly two fluents. Both describe where the pieces stand,
% and both take the situation as their last argument because the
% answer changes as pieces move.
% ------------------------------------------------------------------

% Fluent 1: knight(X, Y, S)
%   X : column of a cell, 1..W
%   Y : row of a cell, 1..H
%   S : a situation, either s0 or result(A, S1)
% True when a knight stands on cell (X, Y) in situation S. Knights have
% no names: the fluent only says that some knight is on that cell.
% In the initial situation s0 the KB facts knight_at/2 decide it.
knight(X, Y, s0) :-
    knight_at(X, Y).

% Successor-state axiom for knight:
%
%   forall x, y, a, s:
%     Knight(x, y, Result(a, s))  <=>
%         Poss(a, s) /\
%         (   a = K(x, y)
%          \/ ( Knight(x, y, s) /\
%               ~exists h, v [ a = K(h, v) /\ KnightMover(x, y, h, v, s) ] ) )
%
% In words: after doing A in S, a knight stands on (X, Y) exactly when A
% was allowed in S and either
%   - A was k(X, Y), so a knight has just jumped onto (X, Y), or
%   - a knight already stood on (X, Y) and A did not move that knight
%     away. Only a k action can move a knight, and only the knight that
%     knight_mover/5 picks for it, so b actions never change knights.
% If A was not allowed, both cases fail and no knight is anywhere after
% it. That makes any plan with an illegal move false, as in sample 5.
knight(X, Y, result(A, S)) :-
    (   A = k(X, Y),
        poss(A, S)
    ;   knight(X, Y, S),
        poss(A, S),
        \+ ( A = k(H, V), knight_mover(X, Y, H, V, S) )
    ).

% Fluent 2: bishop(X, Y, S)
%   X : column of a cell, 1..W
%   Y : row of a cell, 1..H
%   S : a situation, either s0 or result(A, S1)
% True when a bishop stands on cell (X, Y) in situation S. As with the
% knights, bishops have no names.
% In the initial situation s0 the KB facts bishop_at/2 decide it.
bishop(X, Y, s0) :-
    bishop_at(X, Y).

% Successor-state axiom for bishop (same shape as the knight one):
%
%   forall x, y, a, s:
%     Bishop(x, y, Result(a, s))  <=>
%         Poss(a, s) /\
%         (   a = B(x, y)
%          \/ ( Bishop(x, y, s) /\
%               ~exists h, v [ a = B(h, v) /\ BishopMover(x, y, h, v, s) ] ) )
%
% After doing A in S, a bishop stands on (X, Y) exactly when A was
% allowed in S and either A was b(X, Y), or a bishop already stood on
% (X, Y) and A was not the b action that bishop_mover/5 gives to it.
bishop(X, Y, result(A, S)) :-
    (   A = b(X, Y),
        poss(A, S)
    ;   bishop(X, Y, S),
        poss(A, S),
        \+ ( A = b(H, V), bishop_mover(X, Y, H, V, S) )
    ).

% occupied(X, Y, S): some piece, knight or bishop, stands on (X, Y) in S.
% This is not a third fluent. It has no successor-state axiom of its
% own; it is only a short name for "knight(X,Y,S) or bishop(X,Y,S)",
% the same way ClearTop is defined from On in Problem Set 6.
% Call it with X and Y bound when it is used under \+ (otherwise
% \+ occupied(X, Y, S) would mean "the whole board is empty").
occupied(X, Y, S) :-
    knight(X, Y, S)
    ;
    bishop(X, Y, S).


% ------------------------------------------------------------------
% Which piece moves, and when a move is allowed
%
% Like occupied/3, the predicates in this section are defined from the
% two fluents. They have no successor-state axioms, so they are not
% extra fluents.
% ------------------------------------------------------------------

% knight_mover(X, Y, H, V, S): the knight on (X, Y) is the one that
% carries out k(H, V) in situation S.
% The action k(H, V) only names the target cell. If two knights could
% both jump to (H, V), we still need exactly one of them to move, so we
% pick the knight with the smaller coordinates (compared with @<, so by
% X first and then by Y). With a single candidate this changes nothing.
knight_mover(X, Y, H, V, S) :-
    knight(X, Y, S),
    knight_jump(X, Y, H, V),
    \+ ( knight(X2, Y2, S),
         (X2, Y2) @< (X, Y),
         knight_jump(X2, Y2, H, V) ).

% bishop_mover(X, Y, H, V, S): the same rule for b(H, V) and bishops.
bishop_mover(X, Y, H, V, S) :-
    bishop(X, Y, S),
    bishop_slide(X, Y, H, V),
    \+ ( bishop(X2, Y2, S),
         (X2, Y2) @< (X, Y),
         bishop_slide(X2, Y2, H, V) ).

% poss(A, S): action A can be done in situation S.
% k(H, V) needs a knight that can jump to (H, V), and b(H, V) needs a
% bishop that can slide to (H, V). In both cases (H, V) must be empty,
% since there are no captures. A bishop's path may cross other pieces,
% so only the target cell is checked.
% Going through the mover means every allowed action is found once,
% even when two pieces could make it.
poss(k(H, V), S) :-
    knight_mover(_, _, H, V, S),
    \+ occupied(H, V, S).

poss(b(H, V), S) :-
    bishop_mover(_, _, H, V, S),
    \+ occupied(H, V, S).
