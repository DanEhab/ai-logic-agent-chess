% Our own board: both bishops stand on the same square shade
% ((X+Y) even), so no bishop can ever reach a cell where X+Y is odd.
%
%   5  . . . . .
%   4  . . . . .
%   3  . . B . .
%   2  . . . . .
%   1  N . . . B
%      1 2 3 4 5

grid(5,5).
knight_at(1,1).
bishop_at(3,3).
bishop_at(5,1).
