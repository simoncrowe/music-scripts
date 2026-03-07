# AGENTS.md

This file guides agentic coding tools working in this repository.

## Scope

- Repository: `music-scripts`
- Primary purpose: small utilities for TidalCycles, SuperDirt, SuperCollider, and sample handling
- Project shape: script collection, not a packaged application
- Treat this repo as a manual, script-driven toolkit

## Tooling Reality Check

- There is no `Makefile`
- There is no `package.json`
- There is no `pyproject.toml`
- There is no Python lockfile or virtualenv config checked in
- There is no Cabal, Stack, or Haskell build config checked in
- There is no CI workflow checked in
- There is no test directory or test framework configuration checked in
- Do not invent a formal build, lint, or test pipeline unless the user asks for one

## Supported Commands

### Python CLIs

- Show help for the Markov generator:
  - `python3 generate_tidal_markov.py --help`
- Example Markov generator invocation:
  - `python3 generate_tidal_markov.py -n 7 --self-bias 3 --adjacent-bias 1.5 --root 0 --root-bias 2 --jitter 0.1 --seed 42`
- Show help for the sample renamer:
  - `python3 number_pitch_classed_samples.py --help`
- Example sample renamer invocation:
  - `python3 number_pitch_classed_samples.py /path/to/source /path/to/destination`

### Python Sanity Checks

- There is no configured linter
- There is no configured formatter
- There is no configured unit test runner
- The safest built-in Python check currently available is syntax compilation:
  - `python3 -m py_compile generate_tidal_markov.py number_pitch_classed_samples.py`
- Prefer running `--help` on CLI scripts after changing argument parsing or usage text

## Default Verification Strategy

- For Python changes, run `python3 -m py_compile` on changed Python files
- For Python CLI changes, also run the script with `--help`
- For shell changes, verify the script still runs with its documented flags when feasible
- For SuperCollider or Tidal changes, prefer minimal-impact verification and avoid claiming runtime audio behavior unless you actually exercised it
- If you cannot run a meaningful runtime verification because the environment lacks audio tooling, say so clearly

## General Coding Style

- Preserve the repo's script-first character
- Prefer focused changes over broad refactors
- Keep dependencies minimal
- Avoid introducing a framework, package manager, or build system unless requested
- Match the style of the file you are editing rather than forcing a repo-wide rewrite
- Preserve executable scripts as scripts
- Use descriptive names, but keep live-coding aliases and music-domain terms intact where they are already established

## Naming Conventions

- Python: `snake_case` functions, variables, and filenames
- Python constants: `UPPER_CASE`
- Shell variables: lower-case unless exporting an environment variable
- SuperCollider synth names: lower-case symbols
- Preserve established music-domain words like `orbit`, `hush`, `panic`, `chainsaw`, and `tapepipe`

## Change Management for Agents

- Before editing, inspect nearby code and match its local style
- Prefer direct, narrow edits over repo-wide churn
- Do not add a dependency just to satisfy a preferred tool workflow
- Do not add tests, formatters, or linters unless the user asks for them or the change clearly requires them
- If you introduce a new command that future agents should run, document it in this file
- If you add a test framework, include both the full-suite command and the exact single-test command

## Practical Agent Checklist

- Confirm whether the target file is Python, shell, Haskell/Tidal, or SuperCollider
- Use the lightest reasonable verification command for that language
- State clearly when no automated tests exist
- Do not overstate runtime validation for audio code
- Keep edits compatible with the repository's current lightweight workflow
