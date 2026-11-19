# Knights and Bishops: a situation calculus agent in Prolog

CSEN 901 (Introduction to AI), Assignment 2, GUC, Winter 2026.

A logic-based agent that moves knights and bishops on a W x H board. The board is described
with two fluents, `knight(X, Y, S)` and `bishop(X, Y, S)`, each defined by a successor-state
axiom. A plan is found by asking Prolog for a situation in which some knight and some bishop
stand on given cells.

```prolog
?- goal((4,3), (2,2), S).
S = result(k(4,3), result(b(2,2), s0)).

?- goal((4,3), (2,2), result(k(4,3), result(b(1,2), s0))).
false.            % b(1,2) is not a legal bishop move
```

## How it works

- **Fluents.** `knight(X, Y, S)` and `bishop(X, Y, S)`. In `s0` they come from the KB; after
  `result(A, S)` their successor-state axioms say a piece is on a cell if the action was
  allowed and either moved a piece there, or the piece was already there and did not move.
- **Preconditions.** `poss(A, S)`: a piece of the right type can reach the target and the target
  is empty. When two pieces could make the same move, the one with the smaller coordinates moves.
- **Checking a plan.** With `S` given, `goal/3` asks the two fluents about the final situation.
- **Finding a plan.** With `S` unknown, `goal/3` runs iterative deepening on the number of
  actions, so the first plan found is a shortest one. A lower bound on the moves still needed
  (knight distance plus bishop slides) skips branches that cannot reach the goal in time.
- **Impossible goals** answer `false`: two pieces on one cell, cells off the board, a bishop cell
  of the wrong shade, a cell no knight can reach, or boards where pieces block each other.

## Files

| Path | What it is |
|---|---|
| `chess_58-3825.pl` | The solution (the only file that is submitted) |
| `KB1.pl`, `KB2.pl` | The two public knowledge bases (grid size and starting pieces) |
| `run-tests.ps1` | Runs every test file, each in its own SWI-Prolog process |
| `make-submission.ps1` | Last checks, then copies the solution into `submission/` |
| `tests/harness.pl` | Loads the solution with any knowledge base, without editing it |
| `tests/referee.pl` | An independent checker: replays plans and searches all boards with plain lists, never calling the solution |
| `tests/test_*.pl` | plunit tests, one file per knowledge base |
| `tests/test_random.pl` | Random boards (fixed seed) checked against the referee |
| `tests/kbs/` | Our own small boards for cases the public KBs do not cover |
| `tests/samples/` | The sample queries and expected answers given with the assignment |

## Running

Requires [SWI-Prolog](https://www.swi-prolog.org/) 9 or newer.

```powershell
swipl chess_58-3825.pl          # then ask e.g.  ?- goal((4,3), (2,2), S).
.\run-tests.ps1                 # all tests
.\run-tests.ps1 kb2             # only test files whose name contains "kb2"
.\make-submission.ps1           # checks, then writes submission\chess_58-3825.pl
```

To try the agent on another board, change the first line of `chess_58-3825.pl` to include
that knowledge base, for example `:- include('KB2.pl').`
