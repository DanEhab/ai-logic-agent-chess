# Knights and Bishops: a situation calculus agent in Prolog

CSEN 901 (Introduction to AI), Assignment 2, GUC, Winter 2026.

A logic-based agent that moves knights and bishops on a W x H board. The state of the
board is described with two fluents and their successor-state axioms, and a plan is found
by asking Prolog for a situation in which some knight and some bishop sit on given cells.

```prolog
?- goal((4,3), (2,2), S).
S = result(k(4,3), result(b(2,2), s0)).
```

## Files

| Path | What it is |
|---|---|
| `chess_58-3825.pl` | The solution (the only file that is submitted) |
| `KB1.pl`, `KB2.pl` | The two public knowledge bases (grid size and starting pieces) |
| `run-tests.ps1` | Runs every test file, each in its own SWI-Prolog process |
| `tests/harness.pl` | Loads the solution with any knowledge base, without editing it |
| `tests/test_*.pl` | plunit tests, one file per knowledge base |
| `tests/samples/` | The sample queries and expected answers given with the assignment |

## Running

Requires [SWI-Prolog](https://www.swi-prolog.org/) 9 or newer.

```powershell
swipl chess_58-3825.pl          # then ask e.g.  ?- goal((4,3), (2,2), S).
.\run-tests.ps1                 # all tests
.\run-tests.ps1 kb2             # only test files whose name contains "kb2"
```
