% Our own board: both knights can jump to (2,3) and both bishops can
% slide to (3,3), so the "lower piece moves" rule matters here.
%
%   5  B . . . B
%   4  . . . . .
%   3  . . . . .
%   2  . . . . .
%   1  N . N . .
%      1 2 3 4 5

grid(5,5).
knight_at(1,1).
knight_at(3,1).
bishop_at(1,5).
bishop_at(5,5).
