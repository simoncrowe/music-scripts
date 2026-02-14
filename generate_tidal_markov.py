#!/usr/bin/env python3
"""
markov_matrix.py — generate Markov transition matrices for bassline scale-degree states.

Outputs a row-stochastic matrix (rows sum to 1.0) formatted as a Haskell/Tidal-friendly
nested list of floats, e.g.:
[
  [0.3, 0.2, ...],
  ...
]

Bias terms (per row i -> col j):
- self_bias:      added when j == i
- adjacent_bias:  added when j is adjacent to i (|i-j|==1, or wrap if --wrap)
- root_bias:      added when j == root index
- jitter:         adds random noise to every cell (uniform in [-jitter, +jitter])
Then the row is clipped to >=0 and normalized.

Example:
  python markov_matrix.py -n 7 --self-bias 3 --adjacent-bias 1.5 --root 0 --root-bias 2 --jitter 0.1 --seed 42
"""

from __future__ import annotations

import argparse
import random
from typing import List


def build_matrix(
    n: int,
    self_bias: float,
    adjacent_bias: float,
    root: int,
    root_bias: float,
    jitter: float,
    wrap: bool,
    base: float,
    seed: int | None,
) -> List[List[float]]:
    if n < 2:
        raise ValueError("n must be >= 2")
    if not (0 <= root < n):
        raise ValueError(f"root must be in [0, {n-1}]")
    for name, v in [
        ("self_bias", self_bias),
        ("adjacent_bias", adjacent_bias),
        ("root_bias", root_bias),
        ("jitter", jitter),
        ("base", base),
    ]:
        if v < 0:
            raise ValueError(f"{name} must be >= 0")

    rng = random.Random(seed)

    def is_adjacent(i: int, j: int) -> bool:
        if abs(i - j) == 1:
            return True
        if wrap and ((i == 0 and j == n - 1) or (i == n - 1 and j == 0)):
            return True
        return False

    mat: List[List[float]] = []
    for i in range(n):
        row = [base for _ in range(n)]
        for j in range(n):
            if j == i:
                row[j] += self_bias
            if is_adjacent(i, j):
                row[j] += adjacent_bias
            if j == root:
                row[j] += root_bias
            if jitter > 0:
                row[j] += rng.uniform(-jitter, jitter)

        # clip and normalize
        row = [max(0.0, x) for x in row]
        s = sum(row)
        if s <= 0.0:
            # fallback to uniform if everything got clipped to 0
            row = [1.0 / n] * n
        else:
            row = [x / s for x in row]
        mat.append(row)

    return mat


def format_matrix(mat: List[List[float]], decimals: int) -> str:
    fmt = f"{{:.{decimals}f}}"
    lines = ["["]
    for r, row in enumerate(mat):
        inner = ", ".join(fmt.format(x) for x in row)
        comma = "," if r != len(mat) - 1 else ""
        lines.append(f"  [{inner}]{comma}")
    lines.append("]")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Generate Markov transition matrices for bassline scale-degree states."
    )
    ap.add_argument("-n", "--states", type=int, default=7, help="number of states (default: 7)")
    ap.add_argument("--root", type=int, default=0, help="root state index (default: 0)")
    ap.add_argument("--self-bias", type=float, default=2.0, help="bias to stay on same note")
    ap.add_argument(
        "--adjacent-bias",
        type=float,
        default=1.0,
        help="bias to move to adjacent scale degrees",
    )
    ap.add_argument(
        "--root-bias",
        type=float,
        default=1.5,
        help="bias to move toward root (applied to root column)",
    )
    ap.add_argument(
        "--jitter",
        type=float,
        default=0.0,
        help="random noise added to each cell before normalization",
    )
    ap.add_argument(
        "--base",
        type=float,
        default=0.2,
        help="baseline weight for all transitions (pre-bias)",
    )
    ap.add_argument(
        "--wrap",
        action="store_true",
        help="treat 0 and n-1 as adjacent (circular adjacency)",
    )
    ap.add_argument("--seed", type=int, default=None, help="random seed for jitter")
    ap.add_argument(
        "--decimals",
        type=int,
        default=2,
        help="decimal places in output (default: 2)",
    )

    args = ap.parse_args()

    mat = build_matrix(
        n=args.states,
        self_bias=args.self_bias,
        adjacent_bias=args.adjacent_bias,
        root=args.root,
        root_bias=args.root_bias,
        jitter=args.jitter,
        wrap=args.wrap,
        base=args.base,
        seed=args.seed,
    )
    print(format_matrix(mat, args.decimals))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
