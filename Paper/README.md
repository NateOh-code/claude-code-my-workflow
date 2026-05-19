# Paper/

The manuscript. `main.tex` is the single source of truth for the paper body; sections live under `sections/` and are pulled in via `\input{}`. Tables and figures are produced by Stata into `../Tables/` and `../Figures/` and consumed via `\input{../Tables/...}` and `\includegraphics{../Figures/...}` — no table or figure should ever be hand-edited in this directory.

## Structure

```
Paper/
├── main.tex          # title, abstract, \input{sections/...}, bibliography
├── sections/         # narrative sections (01_introduction.tex, ...)
├── appendix/         # appendix sections (A_additional_tables.tex, ...)
└── README.md         # this file
```

## Compile

From `Paper/`:

```bash
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode main.tex
```

Or use the `/compile-latex Paper/main.tex` skill, which runs the 3-pass cycle automatically.

The `TEXINPUTS=../Preambles` part lets `\input{header}` find `Preambles/header.tex`, which carries the project color palette and macros (`\good`, `\bad`, `\key`, `\muted`).

## Submission format

The working draft uses the generic `article` class. Before submitting to JEEM:

1. Switch to `\documentclass[review,12pt,authoryear]{elsarticle}` (Elsevier-supplied).
2. Replace `\title{}` / `\author{}` with `elsarticle` equivalents (`\title{} \author{} \address{}`).
3. Remove `\usepackage[margin=1in]{geometry}` and `\doublespacing` (elsarticle handles spacing via the `review` option).
4. Sanity-check that `\input{header}` still works (it does — the palette is class-agnostic).

See JEEM's author instructions at the Elsevier journal page for the latest format requirements.

## Wiring tables and figures from Stata

Tables (`esttab` output):

```latex
\begin{table}[t]
  \centering
  \caption{Hedonic farmland value regression — main specification.}
  \label{tab:main}
  \input{../Tables/tab_main.tex}
  \footnotesize
  \textit{Notes:} ...
\end{table}
```

Figures (`graph export` to PDF):

```latex
\begin{figure}[t]
  \centering
  \includegraphics[width=\linewidth]{../Figures/fig_event_study.pdf}
  \caption{Event-study estimates around the climate shock.}
  \label{fig:event-study}
\end{figure}
```

Tables and figures live outside `Paper/` so the do-files in `Stata/do/` can write to them without reaching into the manuscript directory.

## Pre-submission checklist

- [ ] `/proofread Paper/main.tex` — typos, grammar, overflow.
- [ ] `/validate-bib` — every `\cite{key}` resolves; no unused entries.
- [ ] `/audit-reproducibility Paper/main.tex Tables/` — every numeric claim matches the Stata outputs within tolerance.
- [ ] `/review-paper --peer JEEM Paper/main.tex` — simulated JEEM peer review.
- [ ] `/seven-pass-review Paper/main.tex` — seven-lens parallel review for submission-ready drafts.
