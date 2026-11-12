% Our own board: on a 3x3 board a knight can never land on the centre
% (2,2), because every jump from there leaves the board.
%
%   3  . . .
%   2  . . .
%   1  N . B
%      1 2 3

grid(3,3).
knight_at(1,1).
bishop_at(3,1).
