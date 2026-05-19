---
paths:
  - "**/*.do"
  - "**/*.ado"
  - "Stata/**/*.do"
  - "Stata/**/*.ado"
---

# Stata Code Standards

**Standard:** Senior Principal Stata Engineer + applied microeconometrician (JEEM / AEJ:EP caliber)

Companion to [`r-code-conventions.md`](r-code-conventions.md). Stata-specific where the languages diverge; the underlying discipline (one seed at top, relative paths, project palette on all figures, single source of truth for tables) is identical.

---

## 1. Reproducibility

- **`set seed YYYYMMDD` called ONCE** at the top of `Stata/profile.do`. Never re-seeded inside loops, programs, or do-files sourced after `profile.do`. (Stata's seed advances deterministically per call; mid-script re-seeding breaks chained reproducibility.)
- **`version 18`** (or current pinned version) at the top of `profile.do`. Pins syntax and behavior even when run under a newer Stata.
- **`set more off`** and **`set type double`** in `profile.do`.
- **All paths via globals** defined in `profile.do` (`$DATA_RAW`, `$DATA_DERIVED`, `$TABLES`, `$FIGURES`, `$LOGS`, `$DO`). No absolute paths in any do-file. No `cd` mid-script.
- **Project-local `ado/`** via `sysdir set PERSONAL "$ADO"` plus `ssc install <pkg>, replace`. Packages live in the repo (or are installed by a documented bootstrap script), not on each user's global Stata profile.
- **Logs:** every do-file opens a log at the top (`log using "$LOGS/<name>.log", replace text`) and closes it at the end. Logs are gitignored but their existence is the audit trail.
- **Deterministic execution.** A fresh clone with `Data/raw/` populated must reproduce `Tables/*.tex` and `Figures/*.pdf` byte-for-byte after `do Stata/do/00_run_all.do`.

## 2. Do-file structure

- **Numbered, single-entry-point.** `00_run_all.do` sources `profile.do` then runs `01_..` through `NN_..` in order. Every analytical do-file is callable in isolation provided `profile.do` was sourced first.
- **Top-of-file header block** with: title, author, purpose, inputs (files + globals), outputs (files), upstream do-files, downstream do-files.
- **Numbered top-level sections** as comment dividers (`* === 1. Load ===`, `* === 2. Clean ===`, ...).
- **No `clear all`** inside numbered analytical do-files (it discards the globals set in `profile.do`). Use `clear` instead. `clear all` only at the top of `00_run_all.do` or `profile.do`.

## 3. Program design

- `capture program drop <name>` immediately before every `program define <name>` — guarantees re-source-ability.
- `snake_case` names, verb-noun pattern (`build_panel`, `run_main_spec`, `make_event_study_plot`).
- Programs that return results use `rclass` or `eclass`; never communicate via globals if a return is possible.
- Document with a top comment block: purpose, syntax, returns. No magic numbers — surface as program arguments or `local`s with comments.

## 4. Domain correctness (applied micro)

- **High-dimensional fixed effects:** `reghdfe` (not `xtreg`, not `areg` for >1 FE). Specify `absorb()` and `cluster()` explicitly. Confirm convergence (`reghdfe` warns; pay attention).
- **IV with FE:** `ivreghdfe` (`ivreg2` if no FE). Report first-stage F (Kleibergen-Paap rk Wald) and AR confidence intervals when first stage is weak.
- **DiD with staggered treatment:** do **not** use vanilla TWFE (`reghdfe Y D, absorb(unit time)`) — it is biased under heterogeneous effects (Goodman-Bacon 2021, de Chaisemartin-D'Haultfœuille 2020, Sun-Abraham 2021, Borusyak-Jaravel-Spiess 2024). Use `csdid` (Callaway-Sant'Anna), `did_imputation` (Borusyak et al.), `eventstudyinteract` (Sun-Abraham), or `did_multiplegt` (de Chaisemartin-D'Haultfœuille). Justify the choice in a comment.
- **Cluster level:** at the unit of treatment assignment. For spatial outcomes, Conley standard errors (`acreg` or `ols_spatial_HAC`) with a stated bandwidth. For panel with cross-sectional dependence, Driscoll-Kraay (`xtscc`).
- **Weights:** specify explicitly (`[aw=w]`, `[pw=w]`, `[fw=w]`). `aw` for analytic, `pw` for survey/sampling, `fw` for frequency. Document the choice.
- **Factor variables:** prefer `i.var` and `c.var#i.var` over manual dummy generation — gives Stata the type information it needs for margins/predictions.
- **Missing data:** explicit handling. `missing()` for the predicate; never `if x == .`. Document sample restrictions with comment + observation counts (`count` before and after each filter).

## 5. Visual identity

Stata figures share the LaTeX paper's palette via the `grstyle` scheme in `Stata/profile.do`. Color values mirror `Preambles/header.tex`:

| Stata series | Hex | Semantic |
|---|---|---|
| 1 | `#012169` (primary-blue) | Main effect / observed |
| 2 | `#B9975B` (primary-gold) | Comparison / alternative |
| 3 | `#F2A900` (highlight-yellow) | Alert / treatment marker |
| 4 | `#15803D` (positive green) | Good / identified |
| 5 | `#B91C1C` (negative red) | Bad / counterfactual / bias |
| 6 | `#525252` (neutral gray) | Reference / context |

**Figure rules (parallel to INV-11 and INV-12 for R figures):**
- Use the project `grstyle` scheme (set by `profile.do`). No Stata default scheme (`s2color`, `s1mono`) in committed figures.
- Vector PDF: `graph export "$FIGURES/fig_<name>.pdf", as(pdf) replace`. PNG only with a stated reason.
- Axis titles: sentence case, units included.
- Legend: `legend(rows(1) position(6))` or comparable; readable at print size.
- No 3D effects, no chart-junk.

## 6. Output discipline

Single source of truth: tables and figures are **written by Stata, read by LaTeX**. No manual numbers in the paper.

- **Tables:** `esttab` (from `estout` package) to `$TABLES/tab_<name>.tex` as an `\input{}`-able fragment. Default options live in `$ESTTAB_OPTS` in `profile.do`. No `outreg2` (deprecated; ill-maintained).
- **Figures:** `graph export` to `$FIGURES/fig_<name>.pdf`.
- **Naming:** `tab_<descriptor>.tex`, `fig_<descriptor>.pdf`. Lowercase, snake_case.
- **Consumed by `Paper/main.tex`** via `\input{../Tables/...}` and `\includegraphics{../Figures/...}`. Re-running the do-file updates the paper automatically.

## 7. Common pitfalls

| Pitfall | Impact | Prevention |
|---|---|---|
| `bysort group: gen seq = _n` without unique sort key | Non-deterministic on ties; results vary across runs | Always include a tie-breaking sort variable (`bysort group (id year)`) |
| Cluster at the wrong level | Over-rejection by 5–20× | Cluster at the unit of treatment assignment, not the unit of observation |
| Vanilla TWFE for staggered DiD | Biased "negative-weighted" estimator | Use `csdid`, `did_imputation`, `eventstudyinteract`, or `did_multiplegt` |
| `replace x = . if x == 0` followed by `summarize x` | Silent sample drop; reported N changes | Always `count` before/after restrictions; document in a comment |
| `merge 1:1 id using ...` without checking `_merge` | Silent data corruption | Always `tab _merge`, drop with reason, never `keep if _merge == 3` without a comment explaining why |
| `local p_value = r(p)` after `regress` without re-running | `r()` invalidated by intervening commands | Use `estimates store` + `estimates restore` for safety on long chains |
| Spatial outcomes with regular cluster SEs | Under-coverage under spatial correlation | Use `acreg`, `ols_spatial_HAC`, or `reghdfe ..., cluster(state)` with state being large enough to absorb spatial dep |
| Missing `version` directive | Future Stata changes break results silently | `version 18` in `profile.do` |
| Re-installing packages from SSC mid-project | Version drift across replications | Pin via `ssc copy`, store in project `ado/` |

## 8. Numerical discipline

- **`set type double`** in `profile.do`. Stata defaults to `float`, which silently loses precision on large datasets.
- **No float comparison.** `if abs(x - y) < 1e-9`, not `if x == y` on doubles.
- **Missing handling.** `if !missing(x)`, never `if x != .` (works but obscures intent). `mi()` / `missing()` in egen and generate.
- **Sample-consistent N.** When running multiple specifications, restrict to the common estimation sample explicitly (`reghdfe ..., absorb(...) ; gen e_sample = e(sample)` then `reghdfe ... if e_sample, ...`) so changes in covariates don't silently change N.
- **Bootstrap seed handling.** `bootstrap, reps(999) seed(...)` — seed argument is mandatory for reproducibility. Match seed across machines.
- **Loops:** prefer `forvalues` over `foreach` when iterating over integers (faster, type-safe). Use `quietly` inside long loops; never print per-iteration status.

## 9. Code quality checklist

```
[ ] profile.do sourced (or running 00_run_all.do)
[ ] set seed YYYYMMDD only in profile.do
[ ] version 18 pinned in profile.do
[ ] All paths via globals ($DATA_RAW, $TABLES, $FIGURES, ...)
[ ] reghdfe / ivreghdfe for FE / IV (not areg / xtreg / ivreg)
[ ] Staggered DiD uses csdid / did_imputation / eventstudyinteract (not vanilla TWFE)
[ ] Cluster at treatment-assignment level (Conley if spatial)
[ ] Every estimation followed by esttab to $TABLES (or stored via eststo)
[ ] Every figure exported via graph export to $FIGURES (vector PDF)
[ ] grstyle scheme active (palette matches Preambles/header.tex)
[ ] No outreg2; no Stata default graph scheme
[ ] No hardcoded N's, p-values, or coefficients written into Paper/*.tex
[ ] Comments explain WHY (identification choice, sample restriction reason)
```

## 10. Cross-references

- [`.claude/rules/replication-protocol.md`](replication-protocol.md) — tolerance contract for paper ↔ Stata-output verification.
- [`.claude/rules/cross-artifact-review.md`](cross-artifact-review.md) — when reviewing a manuscript, auto-invoke `/review-stata` on referenced do-files.
- [`.claude/agents/stata-reviewer.md`](../agents/stata-reviewer.md) — the agent that applies this rule.
- [`.claude/skills/review-stata/SKILL.md`](../skills/review-stata/SKILL.md) — user-facing entry point.
- [`Stata/profile.do`](../../Stata/profile.do) — the canonical project init this rule assumes.
