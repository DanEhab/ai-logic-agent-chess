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
% The offsets are written in increasing order, so the targets come out
% in increasing (X2, Y2) order.
knight_jump(X, Y, X2, Y2) :-
    member((DX, DY), [(-2,-1), (-2,1), (-1,-2), (-1,2), (1,-2), (1,2), (2,-1), (2,1)]),
    X2 is X + DX,
    Y2 is Y + DY,
    on_board(X2, Y2).

% bishop_slide(+X, +Y, ?X2, ?Y2): a bishop standing on (X, Y) can slide
% diagonally to (X2, Y2). Pieces in between never block a bishop, so
% the only condition is the same distance D > 0 across and up/down.
% Targets also come out in increasing (X2, Y2) order, like the knight's.
bishop_slide(X, Y, X2, Y2) :-
    grid(W, _),
    between(1, W, X2),
    D is abs(X2 - X),
    D > 0,
    ( Y2 is Y - D ; Y2 is Y + D ),
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


% ------------------------------------------------------------------
% The goal
% ------------------------------------------------------------------

% reached((KX, KY), (BX, BY), S): in situation S some knight stands on
% (KX, KY) and some bishop stands on (BX, BY). This is just the query
% Knight(kx, ky, s) /\ Bishop(bx, by, s) asked through the two fluents.
reached((KX, KY), (BX, BY), S) :-
    knight(KX, KY, S),
    bishop(BX, BY, S).

% goal((KX, KY), (BX, BY), S)
% When S is given (ground), we only check it: the successor-state
% axioms replay the actions from s0, so the answer is false if any
% action in S was illegal or the pieces do not end on the two cells.
goal(KnightCell, BishopCell, S) :-
    ground(S),
    reached(KnightCell, BishopCell, S).

% When S is unknown we search for it with iterative deepening on the
% number of actions: first all plans with 0 actions, then 1, then 2, ...
% Plain depth-first search could follow one branch forever; iterative
% deepening is complete, and the first plan it finds is a shortest one.
% The cut stops at that first plan, so asking for more answers with ;
% just says false instead of searching on.
%
% We count the actions ourselves instead of using call_with_depth_limit/3.
% With call_with_depth_limit, a check like \+ occupied(H, V, S) that hits
% the depth limit counts as "not occupied", so an illegal move could slip
% into a plan. Counting actions has no such limit inside the checks.
goal(KnightCell, BishopCell, S) :-
    \+ ground(S),
    can_be_reached(KnightCell, BishopCell, Dists),
    between(0, inf, Moves),
    extend(s0, Moves, Dists, KnightCell, BishopCell, S),
    !.

% can_be_reached(+KnightCell, +BishopCell, -Dists): quick tests that throw
% out goals no plan can ever reach. Without them, iterative deepening
% would try 1 move, 2 moves, 3 moves, ... forever and never say false.
%   - the two cells must differ (two pieces never share a cell),
%   - both cells must be on the board,
%   - some knight must be able to get to KnightCell and some bishop to
%     BishopCell, even if the board were empty. This uses the same
%     distances as the lower bound below. It fails when no bishop has the
%     shade of BishopCell (a bishop never changes shade), when no knight
%     can ever land on KnightCell (like the centre of a 3x3 board), and
%     when bishops cannot move at all (a board only one cell wide).
% Dists is dists(KnightDist, BishopDist), the two distance tables.
can_be_reached((KX, KY), (BX, BY), dists(KnightDist, BishopDist)) :-
    (KX, KY) \== (BX, BY),
    on_board(KX, KY),
    on_board(BX, BY),
    distances(knight_jump, (KX, KY), KnightDist),
    distances(bishop_slide, (BX, BY), BishopDist),
    moves_needed(s0, dists(KnightDist, BishopDist), (KX, KY), (BX, BY), _).

% extend(+S0, +Moves, +Dists, +KnightCell, +BishopCell, -S): S is S0 followed
% by exactly Moves more allowed actions, and the goal holds in S.
% Actions are tried in sorted order (setof): every b move before every
% k move, each by increasing target cell. With this order the plans
% found for the public examples are exactly the sample answers.
extend(S, 0, _, KnightCell, BishopCell, S) :-
    reached(KnightCell, BishopCell, S).
extend(S0, Moves, Dists, KnightCell, BishopCell, S) :-
    Moves > 0,
    moves_needed(S0, Dists, KnightCell, BishopCell, Needed),
    Needed =< Moves,
    setof(A, poss(A, S0), Actions),
    member(A, Actions),
    Left is Moves - 1,
    extend(result(A, S0), Left, Dists, KnightCell, BishopCell, S).

% moves_needed(+S, +Dists, +KnightCell, +BishopCell, -N): at least N more
% actions are needed from S before the goal can hold. Every action moves
% one piece, and the knight and the bishop of the goal are different
% pieces, so N = (knight moves needed) + (bishop moves needed).
% The counts use the empty-board distances, plus one thing we know for
% sure: a knight standing on the bishop's cell has to leave it, and so
% does a bishop standing on the knight's cell (see fewest_moves/4).
% N is never more than the real number of moves, so a branch with
% N > Moves can be skipped without losing a plan, and the first plan
% found is still a shortest one. If no knight or no bishop can ever get
% to its cell, fewest_moves/4 fails and so does this.
moves_needed(S, dists(KnightDist, BishopDist), (KX, KY), (BX, BY), N) :-
    findall((X, Y)-D, ( knight(X, Y, S), memberchk((X, Y)-D, KnightDist) ), Knights),
    findall((X, Y)-D, ( bishop(X, Y, S), memberchk((X, Y)-D, BishopDist) ), Bishops),
    ( knight(BX, BY, S) -> KnightInTheWay = true ; KnightInTheWay = false ),
    ( bishop(KX, KY, S) -> BishopInTheWay = true ; BishopInTheWay = false ),
    fewest_moves(Knights, KnightInTheWay, (BX, BY), NK),
    fewest_moves(Bishops, BishopInTheWay, (KX, KY), NB),
    N is NK + NB.

% fewest_moves(+Pieces, +InTheWay, +Cell, -N): Pieces lists Cell-D for every
% piece of one type that can reach its target in D moves. When InTheWay is
% true, a piece of this type stands on Cell (the other piece's target) and
% must move. Either that piece is the one that reaches the target (D moves
% for it), or it steps aside and another piece makes the trip (1 + D).
fewest_moves(Pieces, false, _, N) :-
    findall(D, member(_-D, Pieces), Ds),
    min_list(Ds, N).
fewest_moves(Pieces, true, Cell, N) :-
    findall(D, member(Cell-D, Pieces), Own),
    findall(D1, ( member(C-D, Pieces), C \== Cell, D1 is D + 1 ), Others),
    append(Own, Others, Ds),
    min_list(Ds, N).

% distances(+Move, +Cell, -Dist): Dist is a list of Cell2-D pairs, where D
% is the fewest moves of one piece type (Move is knight_jump or
% bishop_slide) between Cell and Cell2 on an empty board. Both kinds of
% move can be made in reverse, so D is also the fewest moves from Cell2
% to Cell. Cells the piece can never get to are not in the list; for a
% bishop that includes every cell of the other shade.
% It is a breadth-first search over cells, one layer of moves at a time.
distances(Move, Cell, Dist) :-
    layers(Move, [Cell], [Cell-0], 0, Dist).

layers(_, [], Dist, _, Dist).
layers(Move, Layer, Seen, D, Dist) :-
    Layer \== [],
    D1 is D + 1,
    findall((X2, Y2),
            ( member((X, Y), Layer),
              call(Move, X, Y, X2, Y2),
              \+ memberchk((X2, Y2)-_, Seen) ),
            Found),
    sort(Found, Next),
    findall(C-D1, member(C, Next), NextPairs),
    append(Seen, NextPairs, Seen1),
    layers(Move, Next, Seen1, D1, Dist).
