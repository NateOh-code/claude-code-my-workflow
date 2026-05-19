# Tables/

LaTeX table fragments produced by Stata `esttab` and consumed by `Paper/main.tex` via `\input{../Tables/tab_*.tex}`.

## Contract

- **Producer:** `Stata/do/06_tables.do` (and any do-file that emits a final table).
- **Consumer:** `Paper/main.tex`. Never edit a file in this directory by hand.
- **Naming:** `tab_<short_descriptor>.tex` (e.g., `tab_main.tex`, `tab_hedonic_by_region.tex`, `tab_robustness_se.tex`). Lowercase, snake_case, no spaces.
- **Format:** booktabs, `\input{}`-able fragment (no `\begin{table}` wrapper — the wrapper lives in `main.tex`). Default options set by `$ESTTAB_OPTS` in `Stata/profile.do`.

## Example producer (Stata)

```stata
eststo clear
eststo m1: reghdfe lnvalue $climate $controls, ///
    absorb(county year) cluster(state)
eststo m2: reghdfe lnvalue $climate $controls c.year#i.region, ///
    absorb(county year) cluster(state)

esttab m1 m2 using "$TABLES/tab_main.tex", replace ///
    $ESTTAB_OPTS                                ///
    mtitles("Baseline" "Region trends")         ///
    keep($climate)                              ///
    stats(N r2_within, fmt(0 3) labels("Observations" "Within R\$^2\$"))
```

## Example consumer (LaTeX)

```latex
\begin{table}[t]
  \centering
  \caption{Hedonic farmland value regression --- main specification.}
  \label{tab:main}
  \input{../Tables/tab_main.tex}
  \footnotesize
  \textit{Notes:} County and year fixed effects; SE clustered at state level.
\end{table}
```

## Why this directory exists

Tables drift fast: a fix in `04_analyze.do` changes a coefficient; the LaTeX table in the manuscript still shows the old number. Routing every table through `Tables/*.tex` and `\input{}` makes drift impossible — re-running `Stata/do/06_tables.do` updates every table the paper renders, and `/audit-reproducibility` verifies the manuscript numeric claims still match.
