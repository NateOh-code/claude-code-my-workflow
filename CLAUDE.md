# CLAUDE.MD — Climate Change and Agriculture (Farmland Transactions)

**Project:** Climate Change and Agriculture: Evidence from Farmland Transactions
**Institution:** [YOUR INSTITUTION]
**Target journal:** Journal of Environmental Economics and Management (JEEM)
**Tooling:** LaTeX + Stata
**Branch:** main

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/YYYY-MM-DD_*.md`.
- **Verify after** — compile the paper / re-run the do-file at the end of every analytical task; confirm tables and figures regenerate.
- **Single source of truth** — `Paper/main.tex` is the manuscript; `Stata/do/*.do` is the analysis. Tables and figures flow `Stata → Tables/Figures/ → \input{}` into the paper. **Never** hand-edit a number, table, or figure in `Paper/`.
- **Quality gates** — nothing ships below 80/100 (see thresholds below).
- **Publication-ready visuals** — every committed figure uses the project `grstyle` scheme (matches `Preambles/header.tex`), vector PDF, labeled axes with units.
- **[LEARN] tags** — when corrected, save `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md) so the same mistake doesn't repeat next session.

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, decisions, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
project-root/
├── CLAUDE.md, MEMORY.md            # Project context + cross-session memory
├── .claude/                        # Rules, skills, agents, hooks
├── Paper/                          # Manuscript (main.tex, sections/, appendix/)
├── Stata/                          # Analysis (do/, ado/, log/, profile.do)
├── Tables/                         # esttab output → \input{} into Paper/
├── Figures/                        # graph export output → \includegraphics{}
├── Data/raw/                       # GITIGNORED — proprietary / restricted
├── Data/derived/                   # Committed if small + safe
├── Bibliography_base.bib           # Single bibliography
├── Preambles/header.tex            # Shared LaTeX palette + macros
├── quality_reports/                # Plans, specs, session logs, decisions, audits
├── templates/                      # Session-log, spec, decision-record templates
├── master_supporting_docs/         # Reference papers, prior drafts
└── Slides/, Quarto/, docs/         # (optional) slide infrastructure for future talks
```

---

## Commands

```bash
# Paper compile (3-pass XeLaTeX + bibtex) — from Paper/
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
# (or: /compile-latex Paper/main.tex)

# Stata pipeline (run all)
cd Stata && stata-mp -b do do/00_run_all.do
# Single step:
cd Stata && do profile.do && do do/04_analyze.do

# Quality score
python scripts/quality_score.py Paper/main.tex

# Reproducibility audit (paper ↔ Stata outputs)
/audit-reproducibility Paper/main.tex Tables/

# (Optional) Slide infrastructure for future talks — see Slides/, Quarto/, scripts/sync_to_docs.sh
```

---

## Target Journal: JEEM

- **AERE flagship**, Elsevier.  **Reduced-form-dominant**; structural welcome when motivated.
- **Significance stars allowed** (unlike AEA): `* p<0.10, ** p<0.05, *** p<0.01`.
- **Data-and-code policy** aligned with AEA Data Editor model — replication package required at acceptance.
- **Identification + magnitudes + external validity** are the binding constraints; theory contribution is optional.
- Profile + referee dispositions: see [`.claude/references/journal-profiles.md → JEEM`](.claude/references/journal-profiles.md).
- Dry-run a JEEM peer review: `/review-paper --peer JEEM Paper/main.tex`.

---

## Quality Thresholds (advisory)

| Score | Checkpoint | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for sharing / draft circulation |
| 95 | Excellence | Submission-ready |

Enforced by `/commit` (halts + asks for override); not enforced by a git pre-commit hook.

---

## Skills Quick Reference

**Research workflow (paper-first):**

| Command | What It Does |
|---------|-------------|
| `/interview-me` | Multi-turn interview that formalizes a fuzzy research idea into a spec |
| `/lit-review [topic]` | Structured literature search + synthesis; populates Bibliography_base.bib |
| `/research-ideation [topic]` | Generate research questions, hypotheses, empirical strategies |
| `/preregister [--style osf\|aspredicted\|aea-rct]` | Draft a preregistration from a research spec |
| `/review-paper [paper] [--adversarial \| --peer JEEM]` | Manuscript review — single-pass, critic-fixer, or JEEM peer-review simulation |
| `/seven-pass-review [paper]` | Seven parallel adversarial passes — for submission-ready drafts |
| `/respond-to-referees [report] [manuscript]` | R&R cross-reference + response draft |
| `/proofread [file]` | Grammar / typo / overflow / consistency |
| `/validate-bib` | Bibliography ↔ citation consistency |
| `/verify-claims [file]` | Chain-of-Verification fact-check (fresh-context verifier) |

**Code + reproducibility:**

| Command | What It Does |
|---------|-------------|
| `/review-stata [do-file]` | Stata code review — applied-micro discipline (FE, IV, staggered DiD, clustering) |
| `/review-r [file]` | R code review (for any R helpers; not the primary language here) |
| `/audit-reproducibility [paper] [outputs-dir]` | Paper ↔ Stata-output numeric verification with tolerance |
| `/compile-latex [file]` | 3-pass XeLaTeX + bibtex |

**Workflow + sessions:**

| Command | What It Does |
|---------|-------------|
| `/commit [msg]` | Stage, quality-score, commit, PR, merge |
| `/checkpoint [topic]` | Save a structured state snapshot before stopping or handing off |
| `/context-status` | Show session health + context usage |
| `/learn [skill-name]` | Extract a recurrent discovery into a persistent skill |
| `/deep-audit` | Repository-wide consistency audit |
| `/permission-check` | Diagnose permission layers when prompts fire unexpectedly |

**Optional — future slide/talk infrastructure (Beamer / Quarto):**
`/compile-latex`, `/deploy`, `/extract-tikz`, `/new-diagram`, `/visual-audit`, `/pedagogy-review`, `/qa-quarto`, `/slide-excellence`, `/translate-to-quarto`, `/devils-advocate`, `/create-lecture`. Kept available for the eventual JEEM presentation or job-talk deck; not used for the paper itself.

---

## Paper LaTeX Macros (from `Preambles/header.tex`)

| Macro | Effect | Use Case |
| --- | --- | --- |
| `\muted{text}` | Gray | De-emphasized text in footnotes / appendix notes |
| `\key{text}` | Gold bold | Key terms, headline coefficients |
| `\good{text}` | Green | Beneficial / observed / identified |
| `\bad{text}` | Red | Adverse / biased / counterfactual |
| `\textcolor{primary-blue}{...}` | Project blue | Section accents |

Add project-specific macros to `Preambles/header.tex` (under the convenience-macros block) as the paper develops; update this table to keep CLAUDE.md current.

---

## Current Project State

| Artifact | Status | File |
| --- | --- | --- |
| Paper draft | Skeleton — bootstrapping | `Paper/main.tex` |
| Stata pipeline | Not started — awaits data | `Stata/do/` empty |
| Data | Not loaded yet | `Data/raw/` empty (gitignored) |
| Bibliography | 2 example entries | `Bibliography_base.bib` |
| Preregistration | Not drafted | — |
| JEEM submission | Pre-bootstrap | — |
