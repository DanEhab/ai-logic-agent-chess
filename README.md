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
| `KB1.pl`, `KB2.pl` | The two public knowledge bases (grid size and starting pieces) |
| `tests/samples/` | The sample queries and expected answers given with the assignment |

More files are added as the project grows.

## Requirements

[SWI-Prolog](https://www.swi-prolog.org/) 9 or newer.
