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
