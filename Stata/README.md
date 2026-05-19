# Stata/

Analysis code for *Climate Change and Agriculture: Evidence from Farmland Transactions*. All do-files write tables to `../Tables/` and figures to `../Figures/`, which are then consumed by `Paper/main.tex` via `\input{}` / `\includegraphics{}`. Single source of truth — never hand-edit a table or figure that came out of Stata.

## Structure

```
Stata/
├── profile.do        # project init: paths, seed, version, grstyle palette, esttab defaults
├── do/               # numbered do-files (00_run_all.do, 01_clean.do, 02_analyze.do, ...)
├── ado/              # project-local ado/ — pinned package versions for reproducibility
└── log/              # session logs (gitignored)
```

## Naming convention

Do-files are zero-padded and numbered so the order in `dir` matches execution order:

| File | Purpose |
|---|---|
| `00_run_all.do` | Sources `profile.do`, then runs 01..NN in order. Single entry point. |
| `01_load.do` | Read raw data from `Data/raw/`, write intermediate to `Data/derived/`. |
| `02_clean.do` | Clean, merge, construct variables. |
| `03_descriptive.do` | Sample selection table, summary statistics, maps. |
| `04_analyze.do` | Main hedonic / panel regressions. |
| `05_robustness.do` | Alternative specifications, placebo tests, sub-samples. |
| `06_tables.do` | `esttab` all final tables to `Tables/`. |
| `07_figures.do` | `graph export` all final figures to `Figures/`. |

This is a template — adjust as the analysis evolves. The contract is: numbered, single-entry-point, every output saved to `Tables/` or `Figures/` (never to `Stata/`).

## Running

```stata
* From repo root:
cd Stata
do do/00_run_all.do

* Or for a single step:
do profile.do      // always source first
do do/04_analyze.do
```

Batch (headless) mode for long jobs:

```bash
cd Stata
stata-mp -b do do/00_run_all.do
# results in 00_run_all.log in the cwd; move to log/ if you want it kept
```

## Reproducibility

Per [`.claude/rules/stata-code-conventions.md`](../.claude/rules/stata-code-conventions.md):

- **Seed:** one `set seed YYYYMMDD` per session, in `profile.do`. No re-seeding inside loops.
- **Version:** `version 18` in `profile.do` (pinned).
- **Project-local ado/:** `sysdir set PERSONAL "$ADO"` plus `ssc install ..., replace` puts package code under version control. Re-install on a fresh clone via `do install_packages.do` (template stub — author this when needed).
- **Type:** `set type double` for precision-critical work.
- **Paths:** every path resolved through a global (`$DATA_RAW`, `$TABLES`, `$FIGURES`, ...) defined in `profile.do`. No absolute paths.

## Code review

- `/review-stata Stata/do/04_analyze.do` — single do-file review.
- `/review-stata all` — every do-file.

The reviewer runs against [`.claude/rules/stata-code-conventions.md`](../.claude/rules/stata-code-conventions.md). Reports go to `quality_reports/[name]_stata_review.md`.

## Reproducibility audit

Before submission:

```bash
/audit-reproducibility ../Paper/main.tex ../Tables
```

Every numeric claim in the paper (coefficients, SEs, p-values, sample sizes) is matched against `Tables/*.tex` (esttab output) and `log/*.log` (regression results). Tolerances in [`.claude/rules/replication-protocol.md`](../.claude/rules/replication-protocol.md).

## Required Stata packages

Install once on a fresh clone (these go into `Stata/ado/` because `profile.do` sets `PERSONAL` there):

```stata
do profile.do
ssc install reghdfe, replace
ssc install ftools, replace
ssc install ivreghdfe, replace
ssc install estout, replace
ssc install grstyle, replace
ssc install palettes, replace
ssc install csdid, replace
ssc install drdid, replace
ssc install eventstudyinteract, replace
```

Pin versions via `ssc copy <pkg>, replace` if exact reproducibility matters.
