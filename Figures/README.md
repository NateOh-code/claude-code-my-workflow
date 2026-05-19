# Figures/

Vector PDF figures produced by Stata `graph export` and consumed by `Paper/main.tex` via `\includegraphics{../Figures/fig_*.pdf}`.

## Contract

- **Producer:** `Stata/do/07_figures.do` (and any do-file that emits a final figure).
- **Consumer:** `Paper/main.tex`. Hand-edited figures don't belong here — they go in `Figures/manual/` (gitignored or documented separately).
- **Naming:** `fig_<short_descriptor>.pdf` (e.g., `fig_event_study.pdf`, `fig_map_treatment.pdf`, `fig_pretrends.pdf`). Lowercase, snake_case.
- **Format:** vector PDF preferred (`graph export ..., as(pdf) replace`). Raster only if there's a genuine reason (orthophoto base layer, dense scatter); use 300+ DPI PNG, `as(png)`.

## Palette

Stata figures share the LaTeX paper's palette via the `grstyle` scheme initialized in `Stata/profile.do`. The 9 series colors match `Preambles/header.tex`:

| Series | Color | Hex | Semantic |
|---|---|---|---|
| 1 | primary-blue | `#012169` | Main effect |
| 2 | primary-gold | `#B9975B` | Comparison |
| 3 | highlight-yellow | `#F2A900` | Alert / treatment |
| 4 | positive (green) | `#15803D` | Good / observed |
| 5 | negative (red) | `#B91C1C` | Bad / counterfactual |
| 6 | neutral (gray) | `#525252` | Reference |
| 7 | hi-slate | `#314F4F` | Accent |
| 8 | hi-green | `#2E8B57` | Accent |
| 9 | hi-red | `#C41E3A` | Accent |

## Dimensions

Default for a single-column figure in a JEEM-formatted paper:

```stata
graph export "$FIGURES/fig_main.pdf", as(pdf) replace
// implicit size: ~ 5.5 x 4 inches at 96 dpi
```

For two-panel figures or full-width figures, set explicitly:

```stata
graph export "$FIGURES/fig_event_study.pdf", as(pdf) replace ///
    width(2400) height(1600)
```

## Example consumer (LaTeX)

```latex
\begin{figure}[t]
  \centering
  \includegraphics[width=\linewidth]{../Figures/fig_event_study.pdf}
  \caption{Event-study estimates of farmland value around the climate shock.}
  \label{fig:event-study}
  \footnotesize
  \textit{Notes:} Coefficients from a panel hedonic regression; \ldots.
\end{figure}
```

## Quality checklist

- [ ] Vector PDF (not PNG/JPG)
- [ ] Palette from project `grstyle` scheme (no Stata defaults leaking)
- [ ] Axis labels in sentence case, units included
- [ ] Legend readable at print size
- [ ] No 3D effects, no chart-junk
- [ ] If presenting confidence intervals: shaded band or explicit caps, not bare error bars without caps

Run `/visual-audit Paper/main.tex` for an adversarial pass on layout and figure quality.
