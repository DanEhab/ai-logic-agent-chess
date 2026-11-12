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
